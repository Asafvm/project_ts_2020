import 'package:cloud_functions/cloud_functions.dart';
import 'package:teamshare/models/device.dart';
import 'package:teamshare/models/device_instance.dart';

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
        .call(<String, dynamic>{"device": _newDevice.toJson()});
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
}
