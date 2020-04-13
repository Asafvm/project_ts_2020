import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'pdf_viewer_page.dart';
import 'package:teamshare/models/device.dart';
import 'package:teamshare/widgets/add_device_form.dart';
import 'package:teamshare/widgets/custom_appbar.dart';

class AdminDeviceScreen extends StatefulWidget {
  @override
  _AdminDeviceScreenState createState() => _AdminDeviceScreenState();
}

class _AdminDeviceScreenState extends State<AdminDeviceScreen> {
  List<Device> devices = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          'Manage Devices', Icon(Icons.add), () => _openAddDevice(context)),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: StreamBuilder(
            stream: Firestore.instance.collection("test").snapshots(),
            builder: (context, snapshot) {
              return (!snapshot.hasData)
                  ? Text('No devices registered yet!')
                  : ListView.builder(
                      itemBuilder: (ctx, index) =>
                          _buildListItem(ctx, snapshot.data.documents[index]),
                      itemCount: snapshot.data.documents.length,
                    );
            }),
      ),
    );
  }

  void _openAddDevice(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (_) {
          return AddDeviceForm();
        });
  }

  Widget _buildListItem(BuildContext ctx, document) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text('TBA'),
        ),
        title: Text(document['codeName']),
        subtitle: Text(document['codeNumber']),
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
                        builder: (context) => PDFScreen(filePath)),

                    //print(filePath);
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
    );
  }
}
