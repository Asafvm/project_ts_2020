import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/models/device.dart';
import 'package:teamshare/models/device_instance.dart';
import 'package:teamshare/widgets/add_device_instance_form.dart';
import 'package:teamshare/widgets/device_instance_list_item.dart';

class DeviceListScreen extends StatefulWidget {
  final Device device;
  DeviceListScreen(this.device);

  @override
  _DeviceListScreenState createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.getCodeName()),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _openAddDeviceInstance(context))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: StreamBuilder<List<DocumentSnapshot>>(
          stream: Firestore.instance
              .document(
                  "username/company/devices/${widget.device.getCodeName()}")
              .collection('instances')
              .snapshots()
              .map((list) => list.documents),
          builder: (context, snapshot) {
            if (snapshot == null || snapshot.data == null) {
              return Container();
            } else {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (ctx, index) => DeviceInstanceListItem(
                  Icons.computer,
                  ctx,
                  DeviceInstance.fromFirestore(snapshot.data[index]),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _openAddDeviceInstance(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (_) {
          return AddDeviceInstanceForm(widget.device.getCodeName());
        });
    setState(() {});
  }
}
