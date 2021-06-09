import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamshare/models/field.dart';

class Report {
  String id;
  final int timestampOpen;
  int timestampClose;
  final String name;
  final String instrumentId;
  final String instanceId;
  final String siteId;
  final String creatorId;
  final String index;
  final String downloadUrl;
  String status;
  final List<Field> fields;

  Report(
      {this.index,
      this.fields,
      this.timestampOpen,
      this.timestampClose,
      this.name,
      this.downloadUrl,
      this.status,
      this.instrumentId,
      this.instanceId,
      this.siteId,
      this.creatorId});

  Report.fromJson(Map<String, dynamic> data, String id)
      : id = id,
        index = data['index'],
        timestampOpen = data['timestampOpen'],
        timestampClose = data['timestampClose'],
        downloadUrl = data['downloadUrl'],
        name = data['name'],
        instrumentId = data['instrumentId'],
        instanceId = data['instanceId'],
        siteId = data['siteId'],
        creatorId = data['creatorId'],
        status = data['status'],
        fields = data['fields'] == null
            ? List<Field>.empty()
            : List<Field>.from(
                (data['fields'] as List).map((e) => Field.fromJson(e)));

  factory Report.fromFirestore(DocumentSnapshot documentSnapshot) {
    return Report.fromJson(documentSnapshot.data(), documentSnapshot.id);
  }

  Map<String, dynamic> toJson() => {
        'timestampClose': timestampClose,
        'name': name,
        'downloadUrl': downloadUrl,
        'instrumentId': instrumentId,
        'instanceId': instanceId,
        'siteId': siteId,
        'creatorId': creatorId,
        'status': status,
        'index': index,
        'fields': fields.map((e) => e.toJson()).toList()
      };
}
