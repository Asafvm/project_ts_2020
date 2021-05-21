import 'package:cloud_firestore/cloud_firestore.dart';

enum ENTRY_TYPE { INFO, TRANSPORT, REPORT }

class Entry {
  final int timestamp;
  final int type;
  final Map<String, String> details;

  Entry({this.timestamp, this.type, this.details});

  int get getTimestamp {
    return timestamp;
  }

  int get getType {
    return type;
  }

  Map<String, String> get getDetails {
    return details;
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'type': type,
        'details': details,
      };

  Entry.fromJson(Map<String, dynamic> data)
      : timestamp = data['timestamp'],
        type = data['type'],
        details = Map<String, String>.from(data['details']);

  factory Entry.fromFirestore(DocumentSnapshot documentSnapshot) {
    return Entry.fromJson(documentSnapshot.data());
  }
}
