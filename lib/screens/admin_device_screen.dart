import 'dart:math';

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
    var deviceList = Provider.of<List<Device>>(context, listen: true) ?? [];
    //var partList = Provider.of<List<Part>>(context, listen: true);

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
              ?

              //  StreamBuilder<List<Device>>(
              //     stream: Firestore.instance
              //         .collection("teams")
              //         .document(TeamProvider().getCurrentTeam.getTeamId)
              //         .collection("devices")
              //         .snapshots()
              //         .map(
              //           (query) => query.documents
              //               .map(
              //                 (doc) => Device.fromFirestore(doc),
              //               )
              //               .toList(),
              //         ),
              //     builder: (context, snapshot) {
              //       if (snapshot != null && snapshot.data != null)
              ListView.builder(
                  key: new Key(randomString(20)),
                  itemBuilder: (ctx, index) => DeviceListItem(
                      Icons.computer, ctx, deviceList.elementAt(index)),
                  itemCount: deviceList.length,
                )
              : Container()),
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
        enableDrag: false,
        isDismissible: true,
        context: ctx,
        builder: (_) {
          return AddDeviceForm();
        }); //.whenComplete(() => setState(() {}));
  }
}
