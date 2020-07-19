import 'package:cloud_functions/cloud_functions.dart';
import 'package:teamshare/models/device.dart';
import 'package:teamshare/models/device_instance.dart';
import 'package:teamshare/models/part.dart';

class FirebaseFirestoreProvider {
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

  Future<void> uploadDevice(Device _newDevice) async {
    await CloudFunctions.instance
        .getHttpsCallable(functionName: "addDevice")
        .call(<String, dynamic>{"device": _newDevice.toJson()})
        .then((value) => print("Upload Finished: ${value.data}"))
        .catchError((e) => throw new Exception("${e.details["message"]}"));
  }

  Future<void> uploadDeviceInstance(
      DeviceInstance _newDevice, String deviceId) async {
    await CloudFunctions.instance
        .getHttpsCallable(functionName: "addDeviceInstance")
        .call(<String, dynamic>{
      "device_id": deviceId,
      "device": _newDevice.toJson()
    });
  }

  Future<void> uploadPart(Part _newPart) async {
    // await CloudFunctions.instance
    //     .getHttpsCallable(functionName: "addPart")
    //     .call(<String, dynamic>{"part": _newPart.toJson()});
  }
}
