import 'package:cloud_firestore/cloud_firestore.dart';

import 'entry.dart';

class InstrumentInstance {
  final String serial;
  List<Entry> entries;

  InstrumentInstance({this.serial, this.entries});
  InstrumentInstance.newInstrument({this.serial}) {
    this.entries = new List<Entry>();
    this.entries.add(Entry(
        timestamp: Timestamp.now().millisecondsSinceEpoch,
        details: "New Instrument Create",
        type: ENTRY_TYPE.INFO.index));
  }

  void addEntry(Entry e) {
    entries.add(e);
  }

  Map<String, dynamic> toJson() => {
        'serial': serial,
      };

  InstrumentInstance.fromJson(Map<String, dynamic> data)
      : serial = data['serial'],
        entries = (data['entries'] as Map)
            .values
            .map((e) => Entry.fromJson(e))
            .toList();

  factory InstrumentInstance.fromFirestore(DocumentSnapshot documentSnapshot) {
    return InstrumentInstance.fromJson(documentSnapshot.data());
  }
}
