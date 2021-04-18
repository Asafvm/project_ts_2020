import 'package:cloud_firestore/cloud_firestore.dart';

import 'entry.dart';

class InstrumentInstance {
  final String instrumentCode;
  final String serial;
  List<Entry> entries = [];

  InstrumentInstance({this.instrumentCode, this.serial, this.entries});

  InstrumentInstance.newInstrument({this.instrumentCode, this.serial}) {
    this.entries = new List<Entry>.empty(growable: true);
    this.entries.add(Entry(
        timestamp: Timestamp.now().millisecondsSinceEpoch,
        details: "New Instrument Create",
        type: ENTRY_TYPE.INFO.index));
  }

  void addEntry(Entry e) {
    entries.add(e);
  }

  Map<String, dynamic> toJson() => {
        'instrumentCode': instrumentCode,
        'serial': serial,
      };

  InstrumentInstance.fromJson(Map<String, dynamic> data)
      : instrumentCode = data['instrumentCode'],
        serial = data['serial'],
        entries = (data['entries'] as Map)
            .values
            .map((e) => Entry.fromJson(e))
            .toList();

  factory InstrumentInstance.fromFirestore(DocumentSnapshot documentSnapshot) {
    return InstrumentInstance.fromJson(documentSnapshot.data());
  }

  String get getCurrentLocation {
    return 'Default Location';
  }
}
