import 'package:cloud_firestore/cloud_firestore.dart';

class InstrumentInstance {
  final String instrumentCode;
  final String serial;
  String currentSiteId = 'Main';
  String currentRoomId = '';
  int nextMaintenance; //timestamp - millisecondsSinceEpoch
  int warranty; //timestamp - millisecondsSinceEpoch
  String imgUrl;

  InstrumentInstance({this.instrumentCode, this.serial});

  InstrumentInstance.newInstrument({this.instrumentCode, this.serial});

  Map<String, dynamic> toJson() => {
        'instrumentCode': instrumentCode,
        'currentSiteId': currentSiteId,
        'currentRoomId': currentRoomId,
        'nextMaintenance': nextMaintenance,
        'warranty': warranty,
        'serial': serial,
        'imgUrl': imgUrl,
      };

  InstrumentInstance.fromJson(Map<String, dynamic> data)
      : instrumentCode = data['instrumentCode'],
        currentSiteId = data['currentSiteId'],
        currentRoomId = data['currentRoomId'],
        nextMaintenance = data['nextMaintenance'],
        warranty = data["warranty"],
        serial = data['serial'],
        imgUrl = data['imgUrl'];

  factory InstrumentInstance.fromFirestore(DocumentSnapshot documentSnapshot) {
    return InstrumentInstance.fromJson(documentSnapshot.data());
  }

  String get getCurrentLocation {
    return currentSiteId;
  }

  bool get isUnderWarranty {
    return warranty == null
        ? false
        : DateTime.now().millisecondsSinceEpoch - warranty < 0
            ? true
            : false;
  }
}
