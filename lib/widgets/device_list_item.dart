import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:teamshare/models/device.dart';
import 'package:teamshare/models/field.dart';
import 'package:teamshare/screens/device_list_screen.dart';
import 'package:teamshare/screens/pdf_viewer_page.dart';

class DeviceListItem extends StatefulWidget {
  final IconData icon;
  final BuildContext ctx;
  final Device device;
  DeviceListItem(this.icon, this.ctx, this.device);

  @override
  _DeviceListItemState createState() => _DeviceListItemState();
}

class _DeviceListItemState extends State<DeviceListItem> {
  Color _bgcolor = Colors.white;
  bool _selected = false;

  void _setSelected() {
    setState(() {
      _selected = !_selected;
      _bgcolor = _selected ? Theme.of(context).accentColor : Colors.white;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        GestureDetector(
          onTap: _setSelected,
          child: Card(
            color: _bgcolor,
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(widget.icon),
              ),
              title: Text(widget.device.getCodeName()),
              subtitle: Text(widget.device.getReference()),
              trailing: FittedBox(
                child: Row(
                  //buttons
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.add_to_queue),
                      tooltip: 'Add new device',
                      onPressed: () {
                        //TODO: build add device form
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.picture_as_pdf),
                      tooltip: 'Add new form',
                      onPressed: () async {
                        String filePath = await FilePicker.getFilePath(
                            type: FileType.custom, allowedExtensions: ['pdf']);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PDFScreen(
                                filePath,
                                widget.device.getCodeName(),
                                widget.device.getCodeName(),
                                null), //documentID = device document id
                          ),
                        );
                      },
                    ),
                    IconButton(
                        tooltip: 'Show All',
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed: () {
                          //TODO: build devices list screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeviceListScreen(
                                widget.device,
                              ), //documentID = device document id
                            ),
                          );
                        })
                  ],
                ),
              ),
            ),
          ),
        ),
        StreamBuilder<List<DocumentSnapshot>>(
          stream: Firestore.instance
              .document(widget.device.getCodeName())
              .collection('reports')
              .snapshots()
              .map((list) => list.documents),
          builder: (context, snapshot) {
            if (snapshot == null || snapshot.data == null) {
              return Container();
            } else {
              int items = snapshot.data.length; //for height calculation
              return AnimatedContainer(
                height: _selected ? items * 50.0 : 0, //50 = height of listtile
                child: ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (ctx, index) => ListTile(
                    leading: Icon(Icons.picture_as_pdf),
                    title: Text(snapshot.data[index].documentID),
                    trailing: FittedBox(
                      child: Row(
                        children: <Widget>[
                          IconButton(
                              icon: Icon(Icons.file_upload),
                              onPressed: () {}), //TODO: replace file at storage
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PDFScreen(
                                    snapshot.data[index].documentID +
                                        ".pdf", //TODO: get file path from device automaticly,
                                    widget.device.getCodeName(),
                                    widget.device.getCodeName(),
                                    snapshot.data[index].data.entries
                                        .map((e) => Field.fromJson(
                                            e.value.cast<String, dynamic>()))
                                        .toList()),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  itemCount: items,
                ),
                duration: Duration(milliseconds: 300),
              );
            }
          },
        ),
      ],
    );
  }
}
