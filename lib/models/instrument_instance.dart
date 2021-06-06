import 'package:cloud_firestore/cloud_firestore.dart';

class InstrumentInstance {
  String id;
  final String instrumentId;
  final String serial;
  String currentSiteId = 'Main';
  String currentRoomId = '';
  int nextMaintenance; //timestamp - millisecondsSinceEpoch
  int warranty; //timestamp - millisecondsSinceEpoch
  String imgUrl;

  InstrumentInstance({this.instrumentId, this.serial});

  InstrumentInstance.newInstrument({this.instrumentId, this.serial});

  Map<String, dynamic> toJson() => {
        'instrumentId': instrumentId,
        'currentSiteId': currentSiteId,
        'currentRoomId': currentRoomId,
        'nextMaintenance': nextMaintenance,
        'warranty': warranty,
        'serial': serial,
        'imgUrl': imgUrl,
      };

  InstrumentInstance.fromJson(Map<String, dynamic> data, String id)
      : id = id,
        instrumentId = data['instrumentId'],
        currentSiteId = data['currentSiteId'],
        currentRoomId = data['currentRoomId'],
        nextMaintenance = data['nextMaintenance'],
        warranty = data["warranty"],
        serial = data['serial'],
        imgUrl = data['imgUrl'];

  factory InstrumentInstance.fromFirestore(DocumentSnapshot documentSnapshot) {
    return InstrumentInstance.fromJson(
        documentSnapshot.data(), documentSnapshot.id);
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
