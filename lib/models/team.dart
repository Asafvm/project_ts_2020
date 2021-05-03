import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  String id;
  String name;
  String description;
  String logoUrl;
  String creatorEmail;

  Team({this.name});

  //void setTeamId(String id) => id = id;
  String get getTeamId => this.id;
  String get getTeamName => this.name;

  factory Team.fromFirebase(DocumentSnapshot teamDoc) {
    return Team.fromJson(teamDoc.data(), teamDoc.id);
  }

  Team.fromJson(Map<String, dynamic> data, String id)
      : id = id,
        name = data['name'].toString().trim(),
        description = data['description'].toString().trim(),
        logoUrl = data['logoUrl'],
        creatorEmail = data['creatorEmail'].toString().trim();
}
