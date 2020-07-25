import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/models/device.dart';
import 'package:teamshare/widgets/add_device_instance_form.dart';

class DeviceListScreen extends StatefulWidget {
  final Device deviceDoc;
  DeviceListScreen(this.deviceDoc);

  @override
  _DeviceListScreenState createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  @override
  Widget build(BuildContext context) {
    final deviceList = Provider.of<List<Device>>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deviceDoc.getCodeName()),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _openAddDeviceInstance(context))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemBuilder: (ctx, index) =>
              Container(), //DeviceInstanceListItem(Icons.computer, ctx, deviceList[index]),
          itemCount: deviceList == null ? 0 : deviceList.length,
        ),
      ),
    );
  }

  void _openAddDeviceInstance(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (_) {
          return AddDeviceInstanceForm(widget.deviceDoc.getCodeName());
        });
    setState(() {});
  }
}
