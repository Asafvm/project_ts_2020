import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/models/part.dart';
import 'package:teamshare/providers/team_provider.dart';

import 'authentication.dart';

class FirebaseFirestoreProvider {
  final instrumentRef =
      "teams/${TeamProvider().getCurrentTeam.getTeamId}/instruments";

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

  getInstruments() {
    return Firestore.instance
        .collection(instrumentRef)
        .getDocuments()
        .then(
            (value) => value.documents.map((e) => Instrument.fromFirestore(e)))
        .asStream();
  }

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
        .call(
          <String, dynamic>{
            "instrument": _newInstrument.toJson(),
            "teamId": TeamProvider().getCurrentTeam.getTeamId
          },
        )
        .then(
          (value) => print("Upload Finished: ${value.data}"),
        )
        .catchError(
          (e) =>
              throw new Exception("Error uploading: ${e.details["message"]}"),
        );
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

  getTeamList() {
    return Firestore.instance
        .collection("users")
        .document(Authentication().userEmail)
        .collection("teams")
        .getDocuments()
        .then((value) => value.documents)
        .asStream();
  }

  getInstrumentsInstances(String ref) {
    return Firestore.instance
        .collection("$instrumentRef/$ref/instances")
        .snapshots()
        .map((list) => list.documents);
  }
}
