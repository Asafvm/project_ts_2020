import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/models/part.dart';
import 'package:teamshare/providers/team_provider.dart';

import 'authentication.dart';

///*** class changed to static ***///

class FirebaseFirestoreProvider {
  static const String instruments = "instruments";
  static const String teams = "teams";

//Get from Firebase

//Extracted from FirebaseFirestoreProvider class
  static Stream<List<DocumentSnapshot>> getTeamList() {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(Authentication().userEmail)
        .collection("teams")
        .get()
        .then((value) => value.docs)
        .asStream();
  }

  static Stream<List<Part>> getParts() {
    return FirebaseFirestore.instance
        .collection('teams')
        .doc(TeamProvider().getCurrentTeam.getTeamId)
        .collection("parts")
        .snapshots()
        .map(
          (query) => query.docs
              .map(
                (doc) => Part.fromFirestore(doc),
              )
              .toList(),
        );
  }

  static Stream<List<Instrument>> getInstruments() {
    String instrumentRef =
        "$teams/${TeamProvider().getCurrentTeam.getTeamId}/$instruments";
    return FirebaseFirestore.instance
        .collection(instrumentRef)
        .get()
        .then((value) =>
            value.docs.map((e) => Instrument.fromFirestore(e)).toList())
        .asStream();
  }

  static getInstrumentsInstances(String ref) {
    String instrumentRef =
        "$teams/${TeamProvider().getCurrentTeam.getTeamId}/$instruments";
    return FirebaseFirestore.instance
        .collection("$instrumentRef/$ref/instances")
        .snapshots()
        .map((list) => list.docs);
  }

  //Cloud Functions

  static Future<void> uploadPart(Part _newPart) async {
    await CloudFunctions.instance
        .getHttpsCallable(functionName: "addPart")
        .call(<String, dynamic>{"part": _newPart.toJson()});
  }

  static Future<void> uploadInstrumentInstance(
      InstrumentInstance _newInstrument, String instrumentId) async {
    await CloudFunctions.instance
        .getHttpsCallable(functionName: "addInstrumentInstance")
        .call(<String, dynamic>{
      "teamID": TeamProvider().getCurrentTeam.getTeamId,
      "instrumentID": instrumentId,
      "instrument": _newInstrument.toJson()
    });
  }

  static Future<void> uploadInstrument(Instrument _newInstrument) async {
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

  //Cloud Storage

  static Future<void> uploadFields(List<Map<String, dynamic>> fields,
      String fileName, String instrumentId) async {
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
}
