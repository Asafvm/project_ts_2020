import 'package:cloud_firestore/cloud_firestore.dart';

enum ENTRY_TYPE { INFO, WARNING }

class Entry {
  final int timestamp;
  final int type;
  final String details;

  Entry({this.timestamp, this.type, this.details});

  int get getTimestamp {
    return timestamp;
  }

  int get getType {
    return type;
  }

  String get getDetails {
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
        details = data['details'];

  factory Entry.fromFirestore(DocumentSnapshot documentSnapshot) {
    return Entry.fromJson(documentSnapshot.data());
  }
}
