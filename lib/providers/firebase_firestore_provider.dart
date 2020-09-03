import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/models/part.dart';
import 'package:teamshare/providers/team_provider.dart';

import 'authentication.dart';

//TODO: fix firebase links

class FirebaseFirestoreProvider {
  Stream<List<Part>> getParts() {
    return Firestore.instance
        .collection('teams')
        .document(TeamProvider().getCurrentTeam.getTeamId)
        .collection("parts")
        .snapshots()
        .map(
          (query) => query.documents
              .map(
                (doc) => Part.fromFirestore(doc),
              )
              .toList(),
        );
  }

  Stream<List<Instrument>> getInstruments() {
    return Firestore.instance
        .collection("teams")
        .document(TeamProvider().getCurrentTeam.getTeamId)
        .collection("Instruments")
        .snapshots()
        .map(
          (query) => query.documents
              .map(
                (doc) => Instrument.fromFirestore(doc),
              )
              .toList(),
        );
  }

  // bool uploadToFirebase(String userEmail) {
  //   const url = 'https://teamshare-2020.firebaseio.com/users/users.json';

  //   http
  //       .post(url, body: json.jsonEncode({'userEmail': userEmail}))
  //       .then((value) => print(value.body));
  // }

  Future<void> addTeam(String name, String description) async {
    return await CloudFunctions.instance
        .getHttpsCallable(functionName: "addTeam")
        .call(<String, dynamic>{
          "name": name,
          "description": description,
          "creatorEmail": Authentication().userEmail,
          //"creatorName": Authentication().userName,
        })
        .then((value) => {print("Team Created")})
        .catchError((e) => print("Failed to create team. ${e.toString()}"));
  }

  Future<void> uploadFields(List<Map<String, dynamic>> fields, String fileName,
      String instrumentId) async {
    await CloudFunctions.instance
        .getHttpsCallable(functionName: "addInstrumentReport")
        .call(<String, dynamic>{
      "Instrument_id": instrumentId,
      "file_name": fileName,
      "fields": fields,
    }).then((_) async => {
              print('fields uploaded'),
            });
  }

  Future<void> uploadInstrument(Instrument _newInstrument) async {
    await CloudFunctions.instance
        .getHttpsCallable(functionName: "addInstrument")
        .call(<String, dynamic>{
          "instrument": _newInstrument.toJson(),
          "teamId": TeamProvider().getCurrentTeam.getTeamId
        })
        .then((value) => print("Upload Finished: ${value.data}"))
        .catchError((e) => throw new Exception("${e.details["message"]}"));
  }

  Future<void> uploadInstrumentInstance(
      InstrumentInstance _newInstrument, String instrumentId) async {
    await CloudFunctions.instance
        .getHttpsCallable(functionName: "addInstrumentInstance")
        .call(<String, dynamic>{
      "teamID": TeamProvider().getCurrentTeam.getTeamId,
      "instrumentID": instrumentId,
      "instrument": _newInstrument.toJson()
    });
  }

  Future<void> uploadPart(Part _newPart) async {
    await CloudFunctions.instance
        .getHttpsCallable(functionName: "addPart")
        .call(<String, dynamic>{"part": _newPart.toJson()});
  }
}
