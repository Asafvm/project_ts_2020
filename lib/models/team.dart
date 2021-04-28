import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  String _id;
  String name;
  String description;
  String logoUrl;
  String creatorEmail;

  Team({this.name});

  void setTeamId(String id) => _id = id;
  String get getTeamId => this._id;
  String get getTeamName => this.name;

  factory Team.fromFirebase(DocumentSnapshot teamDoc) {
    return Team.fromJson(teamDoc.data());
  }

  Team.fromJson(Map<String, dynamic> data)
      : name = data['name'].toString().trim(),
        description = data['description'].toString().trim(),
        logoUrl = data['logoUrl'],
        creatorEmail = data['creatorEmail'].toString().trim();
}
