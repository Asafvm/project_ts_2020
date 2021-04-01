import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/models/part.dart';
import 'package:teamshare/models/site.dart';
import 'package:teamshare/providers/applogger.dart';
import 'package:teamshare/providers/firebase_storage_provider.dart';
import 'package:teamshare/providers/team_provider.dart';

import 'authentication.dart';

///*** class changed to static ***///

class FirebaseFirestoreProvider {
  static const String instruments = "instruments";
  static const String teams = "teams";
  static const String sites = "sites";
//Get from Firebase

  static Future<void> addTeam(String name, String description,
      [List<String> members = const [], String picUrl]) async {
    //step 1: upload team and get id
    HttpsCallableResult teaminfo = await FirebaseFunctions.instance
        .httpsCallable("addTeam")
        .call(<String, dynamic>{
      "teamInfo": {
        "name": name,
        "description": description,
        "creatorEmail": Authentication().userEmail,
      },
      "members": members,
    }).catchError((err) => Applogger.consoleLog(
            MessegeType.error, 'Failed to create team: ${err.toString()}'));

    String teamid = teaminfo.data;
    Applogger.consoleLog(MessegeType.info,
        "Team created successfuly without logo. teamid: $teamid\n");
    //step 2: user team id to upload pic to team folder
    if (picUrl != null) {
      String firestoragePicUrl = await FirebaseStorageProvider.uploadFile(
          File(picUrl), '$teams/$teamid', 'logoUrl');

      await FirebaseFunctions.instance
          .httpsCallable("updateTeam")
          .call(<String, dynamic>{
            'teamid': teamid,
            'data': {
              'logoUrl': firestoragePicUrl,
            }
          })
          .catchError((err) => Applogger.consoleLog(MessegeType.error,
              'Failed to update team logo path: ${err.toString()}'))
          .then((value) => Applogger.consoleLog(
              MessegeType.info, "Team created successfuly"));
    }
  }

  static Stream<QuerySnapshot> getUserTeamList() {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(Authentication().userEmail)
        .collection("teams")
        .snapshots();
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
        "$teams/${TeamProvider().getCurrentTeam.getTeamId}/$instruments/$ref/instances";
    return FirebaseFirestore.instance
        .collection("$instrumentRef")
        .snapshots()
        .map((list) => list.docs
            .map((item) => InstrumentInstance.fromFirestore(item))
            .toList());
  }

  //Cloud Functions

  static Future<void> uploadPart(Part _newPart) async {
    await FirebaseFunctions.instance
        .httpsCallable("addPart")
        .call(<String, dynamic>{
      "teamID": TeamProvider().getCurrentTeam.getTeamId,
      "part": _newPart.toJson()
    });
  }

  static Future<void> uploadInstrumentInstance(
      InstrumentInstance _newInstrument, String instrumentId) async {
    await FirebaseFunctions.instance
        .httpsCallable("addInstrumentInstance")
        .call(<String, dynamic>{
      "teamID": TeamProvider().getCurrentTeam.getTeamId,
      "instrumentID": instrumentId,
      "instrument": _newInstrument.toJson(),
      "entries": _newInstrument.entries.map((e) => e.toJson()).toList()
    });
  }

  static Future<void> uploadInstrument(Instrument _newInstrument) async {
    await FirebaseFunctions.instance
        .httpsCallable("addInstrument")
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
    String teamId = TeamProvider().getCurrentTeam.getTeamId;

    await FirebaseFunctions.instance
        .httpsCallable("addInstrumentReport")
        .call(<String, dynamic>{
      "team_id": teamId,
      "instrument_id": instrumentId,
      "file": fileName,
      "fields": fields,
    });
  }

  static Stream<Map<String, dynamic>> getTeamInfo(String teamDocId) {
    return FirebaseFirestore.instance
        .collection("teams")
        .doc(teamDocId)
        .get()
        .then((value) => value.data())
        .asStream();
  }

  static removeTeam(String teamDocId) {
    FirebaseFirestore.instance
        .collection("users")
        .doc(Authentication().userEmail)
        .collection("teams")
        .doc(teamDocId)
        .delete();
  }

  static uploadSite(Site newSite) async {
    await FirebaseFunctions.instance
        .httpsCallable("addSite")
        .call(<String, dynamic>{
      "teamId": TeamProvider().getCurrentTeam.getTeamId,
      "site": newSite.toJson(),
    });
  }

  static getSites() {
    String sitesRef =
        "$teams/${TeamProvider().getCurrentTeam.getTeamId}/$sites";
    return FirebaseFirestore.instance
        .collection(sitesRef)
        .get()
        .then((value) => value.docs.map((e) => Site.fromFirestore(e)).toList())
        .asStream();
  }
}
