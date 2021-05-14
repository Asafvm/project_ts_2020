import 'package:cloud_firestore/cloud_firestore.dart';

class InstrumentInstance {
  final String instrumentCode;
  final String serial;
  String currentSiteId = 'Main';
  String currentRoomId = '';
  String imgUrl;

  InstrumentInstance({this.instrumentCode, this.serial});

  InstrumentInstance.newInstrument({this.instrumentCode, this.serial});

  Map<String, dynamic> toJson() => {
        'instrumentCode': instrumentCode,
        'currentSiteId': currentSiteId,
        'currentRoomId': currentRoomId,
        'serial': serial,
        'imgUrl': imgUrl,
      };

  InstrumentInstance.fromJson(Map<String, dynamic> data)
      : instrumentCode = data['instrumentCode'],
        currentSiteId = data['currentSiteId'],
        currentRoomId = data['currentRoomId'],
        serial = data['serial'],
        imgUrl = data['imgUrl'];

  factory InstrumentInstance.fromFirestore(DocumentSnapshot documentSnapshot) {
    return InstrumentInstance.fromJson(documentSnapshot.data());
  }

  String get getCurrentLocation {
    return currentSiteId;
  }
}
