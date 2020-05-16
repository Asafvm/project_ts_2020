import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/widgets/device_list_item.dart';
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
          key: new Key(randomString(20)),
          itemBuilder: (ctx, index) =>
              DeviceListItem(Icons.computer, ctx, deviceList[index]),
          itemCount: deviceList == null ? 0 : deviceList.length,
        ),
      ),
    );
  }

  String randomString(int length) {
    var rand = new Random();
    var codeUnits = new List.generate(length, (index) {
      return rand.nextInt(33) + 89;
    });
    return new String.fromCharCodes(codeUnits);
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
