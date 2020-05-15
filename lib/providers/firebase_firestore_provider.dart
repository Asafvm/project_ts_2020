import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class FirebaseFirestoreProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Future<void> uploadFields(List<Map<String, dynamic>> fields, String fileName,
      String deviceId) async {
    await CloudFunctions.instance
        .getHttpsCallable(functionName: "addDeviceReport")
        .call(<String, dynamic>{
      "device_id": deviceId,
      "file_name": fileName,
      "fields": fields,
    }).then((_) async => {
              print('fields uploaded'),
            });
  }
}
