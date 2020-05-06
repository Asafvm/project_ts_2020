import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/models/field.dart';
import 'pdf_viewer_page.dart';
import 'package:teamshare/models/device.dart';
import 'package:teamshare/widgets/add_device_form.dart';

class AdminDeviceScreen extends StatefulWidget {
  @override
  _AdminDeviceScreenState createState() => _AdminDeviceScreenState();
}

class _AdminDeviceScreenState extends State<AdminDeviceScreen> {
  List<Device> devices = [];

  @override
  Widget build(BuildContext context) {
    final deviceList =
        Provider.of<List<DocumentSnapshot>>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Devices"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add), onPressed: () => _openAddDevice(context))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemBuilder: (ctx, index) =>
              _buildListItem(Icons.computer, ctx, deviceList[index]),
          itemCount: deviceList == null ? 0 : deviceList.length,
        ),
      ),
    );
  }

  void _openAddDevice(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (_) {
          return AddDeviceForm();
        });
    setState(() {});
  }

  Widget _buildListItem(IconData icon, BuildContext ctx, document) {
    var deviceDoc = document.data;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Icon(icon),
            ),
            title: Text(deviceDoc['codeName']),
            subtitle: Text(deviceDoc['codeNumber']),
            trailing: FittedBox(
              child: Row(
                //buttons
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.add_to_queue),
                    tooltip: 'Add new device',
                    onPressed: () {},
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
                              document.documentID,
                              null), //documentID = device document id
                        ),
                      );
                    },
                  ),
                  IconButton(
                      tooltip: 'Show All',
                      icon: Icon(Icons.arrow_forward_ios),
                      onPressed: () {})
                ],
              ),
            ),
          ),
        ),
        StreamBuilder<List<DocumentSnapshot>>(
          stream: Firestore.instance
              .collection('test')
              .document(document.documentID)
              .collection('reports')
              .snapshots()
              .map((list) => list.documents),
          builder: (context, snapshot) {
            return snapshot == null
                ? Container()

                : ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (ctx, index) => ListTile(
                      leading: Icon(Icons.picture_as_pdf),
                      title: Text(snapshot.data[index].documentID),
                      trailing: FittedBox(
                        child: Row(
                          children: <Widget>[
                            IconButton(
                                icon: Icon(Icons.file_upload),
                                onPressed:
                                    () {}), //TODO: replace file at storage
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PDFScreen(
                                      snapshot.data[index].documentID +
                                          ".pdf", //TODO: get file path from device automaticly,
                                      document.documentID,
                                      snapshot.data[index].data.entries.map((e) => Field.fromJson(e.value.cast<String,dynamic>())).toList()),
                                          
                                ),
                              ),
                            ), //TODO: edit fields
                          ],
                        ),
                      ),
                    ),
                    itemCount: snapshot.data == null ? 0 : snapshot.data.length,
                  );
          },
        ),
      ],
    );
  }
}
