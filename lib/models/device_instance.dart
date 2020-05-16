import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceInstance {
  final String _serial;

  DeviceInstance(this._serial);

  String get serial {
    return _serial;
  }

  Map<String, dynamic> toJson() => {
        'serial': _serial,
      };

  DeviceInstance.fromJson(Map<String, dynamic> data) : _serial = data['serial'];

  factory DeviceInstance.fromFirestore(DocumentSnapshot documentSnapshot) {
    return DeviceInstance.fromJson(documentSnapshot.data);
  }
}
