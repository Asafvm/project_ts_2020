import 'package:cloud_firestore/cloud_firestore.dart';

class InstrumentInstance {
  final String _serial;

  InstrumentInstance(this._serial);

  String get serial {
    return _serial;
  }

  Map<String, dynamic> toJson() => {
        'serial': _serial,
      };

  InstrumentInstance.fromJson(Map<String, dynamic> data)
      : _serial = data['serial'];

  factory InstrumentInstance.fromFirestore(DocumentSnapshot documentSnapshot) {
    return InstrumentInstance.fromJson(documentSnapshot.data());
  }
}
