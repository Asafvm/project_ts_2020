import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/helpers/image_helper.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/part.dart';
import 'package:teamshare/providers/firebase_firestore_cloud_functions.dart';
import 'package:teamshare/providers/firebase_paths.dart';
import 'package:teamshare/widgets/forms/add_part_form.dart';

class PartInfoScreen extends StatefulWidget {
  final Part part;

  const PartInfoScreen({this.part});

  @override
  _PartInfoScreenState createState() => _PartInfoScreenState();
}

class _PartInfoScreenState extends State<PartInfoScreen>
    with SingleTickerProviderStateMixin {
  MediaQueryData mediaQuery;
  final scaffoldState = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    List<Instrument> instruments = Provider.of<List<Instrument>>(context);
    mediaQuery = MediaQuery.of(context);

    return Scaffold(
      key: scaffoldState,
      appBar: AppBar(
        title: Text('Manage Parts'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                InkWell(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: widget.part.imgUrl == null
                              ? AssetImage('assets/pics/unknown.jpg')
                              : NetworkImage(widget.part.imgUrl),
                          fit: BoxFit.fitHeight),
                    ),
                  ),
                  onTap: () async => {
                    widget.part.imgUrl = await ImageHelper.takePicture(
                        context: context,
                        uploadPath: FirebasePaths.partImagePath(widget.part.id),
                        fileName: 'partImg'),
                    FirebaseFirestoreCloudFunctions.uploadPart(
                        widget.part, Operation.UPDATE)
                  },
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Text(
                    widget.part.reference,
                    style: TextStyle(fontSize: 26),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _editPart(context),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Container(
                color: Colors.black12,
                padding: const EdgeInsets.all(15),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.part.description,
                    overflow: TextOverflow.ellipsis,
                    // maxLines: _isExpanded ? null : _maxLines,
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            CheckboxListTile(
                              title: Text("Track Serials"),
                              value: widget.part.serialTracking,
                              onChanged: null,
                            ),
                            CheckboxListTile(
                              title: Text("Active"),
                              value: widget.part.active,
                              onChanged: null,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child: Text("Alternative Reference")),
                            Expanded(child: Text(widget.part.altreference)),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child: Text("Main Storage Minimum")),
                            Expanded(
                                child:
                                    Text(widget.part.mainStockMin.toString())),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child: Text("Personal Storage Minimum")),
                            Expanded(
                                child: Text(
                                    widget.part.personalStockMin.toString())),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child: Text("Manifacturer")),
                            Expanded(child: Text(widget.part.manifacturer)),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child: Text("Model")),
                            Expanded(child: Text(widget.part.model)),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child: Text("Price")),
                            Expanded(child: Text(widget.part.price.toString())),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: instruments.length,
                  itemBuilder: (BuildContext context, int index) {
                    return CheckboxListTile(
                      value: widget.part.instrumentId
                          .contains(instruments[index].codeName),
                      onChanged: null,
                      title: Text(instruments[index].codeName),
                      subtitle: Text(instruments[index].reference),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _editPart(BuildContext context) {
    scaffoldState.currentState.showBottomSheet(
      (context) => AddPartForm(
        part: widget.part,
      ),
    );
  }
}
