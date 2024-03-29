import 'package:flutter/material.dart';
import 'package:teamshare/helpers/picker_helper.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/models/team.dart';
import 'package:teamshare/providers/firebase_firestore_cloud_functions.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/helpers/firebase_paths.dart';
import 'package:teamshare/providers/team_provider.dart';
import 'package:teamshare/widgets/forms/add_instrument_instance_form.dart';
import 'package:teamshare/widgets/list_items/instrument_instance_list_item.dart';

class InstrumentListScreen extends StatefulWidget {
  final Instrument instrument;
  InstrumentListScreen(this.instrument);

  @override
  _InstrumentListScreenState createState() => _InstrumentListScreenState();
}

class _InstrumentListScreenState extends State<InstrumentListScreen> {
  Team curTeam;
  final scaffoldState = GlobalKey<ScaffoldState>();

  bool _loading = false;

  @override
  void initState() {
    curTeam = TeamProvider().getCurrentTeam;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
      appBar: AppBar(
        title: Text(widget.instrument.getCodeName()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddInstrumentInstance(context),
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildInstanceList(),
          ],
        ),
      ),
    );
  }

  void _openAddInstrumentInstance(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (_) {
          return AddInstrumentInstanceForm(widget.instrument.id);
        }).whenComplete(() => setState(() {}));
  }

  _buildHeader(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Card(
        elevation: 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            InkWell(
              child: _loading
                  ? Center(child: CircularProgressIndicator())
                  : Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: widget.instrument.imgUrl == null
                                ? AssetImage('assets/pics/unknown.jpg')
                                : NetworkImage(widget.instrument.imgUrl),
                            fit: BoxFit.fitHeight),
                      ),
                    ),
              onTap: () async {
                String pic = await PickerHelper.takePicture(
                    context: context,
                    uploadPath:
                        FirebasePaths.instrumentImagePath(widget.instrument.id),
                    fileName: 'instrumentImg');
                if (pic != null || pic.isNotEmpty) {
                  setState(() {
                    _loading = true;
                    widget.instrument.imgUrl = pic;
                  });

                  await FirebaseFirestoreCloudFunctions.uploadInstrument(
                      instrument: widget.instrument,
                      operation: Operation.UPDATE);
                  setState(() {
                    _loading = false;
                  });
                }
              },
            ),
            Positioned(
                top: 10,
                left: 10,
                child: Text(
                  "${widget.instrument.getManifacturer()}\n${widget.instrument.getCodeName()}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )),
          ],
        ),
      ),
    );
  }

  _buildInstanceList() {
    return Expanded(
      flex: 5,
      child: StreamBuilder<List<InstrumentInstance>>(
        stream: FirebaseFirestoreProvider.getInstrumentsInstances(
            widget.instrument.id),
        builder: (context, snapshot) {
          if (snapshot == null || snapshot.data == null) {
            return Container();
          } else {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (ctx, index) => InstrumentInstanceListItem(
                instance: snapshot.data[index],
                instrument: widget.instrument,
              ),
            );
          }
        },
      ),
    );
  }
}
