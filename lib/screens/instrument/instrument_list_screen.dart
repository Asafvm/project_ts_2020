import 'package:flutter/material.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/models/team.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/providers/team_provider.dart';
import 'package:teamshare/screens/instrument/instrument_info_screen.dart';
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
  @override
  void initState() {
    curTeam = TeamProvider().getCurrentTeam;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.instrument.getCodeName()),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _openAddInstrumentInstance(context))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildHeader(),
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
          return AddInstrumentInstanceForm(widget.instrument.getCodeName());
        }).whenComplete(() => setState(() {}));
  }

  _buildHeader() {
    return Expanded(
      flex: 1,
      child: Card(
        elevation: 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Icon(Icons.computer),
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
            widget.instrument.getCodeName()),
        builder: (context, snapshot) {
          if (snapshot == null || snapshot.data == null) {
            return Container();
          } else {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (ctx, index) => GestureDetector(
                onTap: () => _switchToInstrumentView(snapshot.data[index]),
                child: InstrumentInstanceListItem(
                  Icons.computer,
                  ctx,
                  snapshot.data[index].serial,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  _switchToInstrumentView(InstrumentInstance instance) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => InstrumentInfoScreen(
          instrument: widget.instrument,
          instance: instance,
        ),
      ),
    );
  }
}
