import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/providers/consts.dart';
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
    var deviceList = Provider.of<List<Device>>(context, listen: true) ?? [];

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
        child: deviceList.length == 0
            ? Center(child: Text("You haven't registered any instruments yet"))
            : ListView.builder(
                key: new Key(randomString(20)),
                itemBuilder: (ctx, index) => DeviceListItem(
                    Icons.computer, ctx, deviceList.elementAt(index)),
                itemCount: deviceList.length,
              ),
      ),
    );
  }

  void _openAddDevice(BuildContext ctx) {
    showModalBottomSheet(
        enableDrag: false,
        isDismissible: true,
        context: ctx,
        builder: (_) {
          return AddDeviceForm();
        }); //.whenComplete(() => setState(() {}));
  }
}
