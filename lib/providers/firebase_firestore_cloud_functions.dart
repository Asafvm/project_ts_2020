import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:teamshare/models/contact.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/models/part.dart';
import 'package:teamshare/models/site.dart';
import 'package:teamshare/providers/applogger.dart';
import 'package:teamshare/providers/firebase_storage_provider.dart';
import 'package:teamshare/providers/team_provider.dart';

import 'authentication.dart';

///*** class changed to static ***///

class FirebaseFirestoreCloudFunctions {
  static const String instruments = "instruments";
  static const String teams = "teams";
  static const String sites = "sites";
  static const String rooms = "rooms";
//Get from Firebase

  static Future<HttpsCallableResult> addTeam(String name, String description,
      [List<String> members = const [], String picUrl]) async {
    //step 1: upload team and get id
    HttpsCallableResult teaminfo = await FirebaseFunctions.instance
        .httpsCallable("addTeam")
        .call(<String, dynamic>{
      "teamInfo": {
        "name": name,
        "description": description,
        "creatorEmail": Authentication().userEmail.toLowerCase(),
      },
      "members": members,
    });

    //check status
    var response = teaminfo.data;
    if (response["status"] == "success") {
      String teamid = response["teamId"];
      Applogger.consoleLog(MessegeType.info,
          "Team created successfuly without logo. teamid: $teamid\n");
      //step 2: user team id to upload pic to team folder
      if (picUrl != null) {
        return updateTeamLogo(url: picUrl, teamid: teamid);
      }
      return teaminfo;
    } else {
      return teaminfo;
    }
  }

  static Future<HttpsCallableResult> addTeamMember(
      String teamid, List<String> members) async {
    //step 1: upload team and get id
    return await FirebaseFunctions.instance
        .httpsCallable("addTeamMember")
        .call(<String, dynamic>{
      'teamId': teamid,
      "members": members,
    });
  }

  static Future<HttpsCallableResult> updateTeamLogo(
      {String url, String teamid}) async {
    String firestoragePicUrl = await FirebaseStorageProvider.uploadFile(
        File(url), '$teamid', 'logoUrl');
    return await updateTeam(
        teamid: teamid, data: {'logoUrl': firestoragePicUrl});
  }

  static Future<HttpsCallableResult> updateTeam(
      {String teamid, Map<String, dynamic> data}) async {
    return await FirebaseFunctions.instance
        .httpsCallable("updateTeam")
        .call(<String, dynamic>{
      'teamid': teamid,
      'data': data,
    });
  }

  static Future<void> uploadPart(Part _newPart) async {
    await FirebaseFunctions.instance
        .httpsCallable("addPart")
        .call(<String, dynamic>{
      "teamID": TeamProvider().getCurrentTeam.getTeamId,
      "part": _newPart.toJson()
    });
  }

  static Future<void> uploadInstrumentInstance(
      InstrumentInstance _newInstrument) async {
    await FirebaseFunctions.instance
        .httpsCallable("addInstrumentInstance")
        .call(<String, dynamic>{
      "teamID": TeamProvider().getCurrentTeam.getTeamId,
      "instrumentID": _newInstrument.instrumentCode,
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

  static uploadRoom(String siteId, Room newRoom) async {
    await FirebaseFunctions.instance
        .httpsCallable("addRoom")
        .call(<String, dynamic>{
      "teamId": TeamProvider().getCurrentTeam.getTeamId,
      "siteId": siteId,
      "room": newRoom.toJson(),
    });
  }

  static Future<void> linkInstruments(
      List<InstrumentInstance> selected, String siteId, String roomId) async {
    await FirebaseFunctions.instance
        .httpsCallable("linkInstruments")
        .call(<String, dynamic>{
      "teamId": TeamProvider().getCurrentTeam.getTeamId,
      "instruments": selected
          .map((e) =>
              {"instrumentCode": e.instrumentCode, "instanceSerial": e.serial})
          .toList(),
      "siteId": siteId,
      "roomId": roomId,
    }).then((value) => print(value.data));
  }

  static Future<HttpsCallableResult> uploadContact(
      String siteId, Contact newContact) async {
    return await FirebaseFunctions.instance
        .httpsCallable("addContact")
        .call(<String, dynamic>{
      "teamId": TeamProvider().getCurrentTeam.getTeamId,
      "siteId": siteId,
      "contact": newContact.toJson(),
    });
  }

  static Future<HttpsCallableResult> linkContacts(
      List<Contact> selected, String siteId, String roomId) async {
    return await FirebaseFunctions.instance
        .httpsCallable("linkContacts")
        .call(<String, dynamic>{
      "teamId": TeamProvider().getCurrentTeam.getTeamId,
      "siteId": siteId,
      "roomId": roomId,
      "contacts": selected.map((contact) => {"contactId": contact.id}).toList(),
    });
  }
}
