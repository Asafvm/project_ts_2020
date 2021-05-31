import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamshare/models/field.dart';

class Report {
  String id;
  final int timestamp;
  final String reportId;
  final String reportName;
  final List<Field> fields;

  Report(this.fields, this.timestamp, this.reportId, this.reportName);

  Report.fromJson(Map<String, dynamic> data, String id)
      : id = id,
        timestamp = data['timestamp'],
        reportId = data['reportid'],
        reportName = data['reportName'],
        fields = List<Field>.from(
            data['fields'].values.map((e) => Field.fromJson(e)));

  factory Report.fromFirestore(DocumentSnapshot documentSnapshot) {
    return Report.fromJson(documentSnapshot.data(), documentSnapshot.id);
  }
}
