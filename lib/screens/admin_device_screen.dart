import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/models/field.dart';
import 'package:teamshare/widgets/device_list_item.dart';
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
              DeviceListItem(Icons.computer, ctx, deviceList[index]),
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
}
