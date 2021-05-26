import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:teamshare/models/contact.dart';
import 'package:teamshare/models/field.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/models/part.dart';
import 'package:teamshare/models/site.dart';
import 'package:teamshare/providers/applogger.dart';
import 'package:teamshare/providers/firebase_storage_provider.dart';
import 'package:teamshare/providers/team_provider.dart';

import 'authentication.dart';

enum Operation { CREATE, UPDATE, DELETE }

class FirebaseFirestoreCloudFunctions {
  static const String instruments = "instruments";
  static const String teams = "teams";
  static const String sites = "sites";
  static const String rooms = "rooms";

//Get from Firebase

  static Future<HttpsCallableResult> addTeam(String name, String description,
      [Map<String, bool> members, String picUrl]) async {
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
      String teamid, Map<String, bool> members) async {
    //step 1: upload team and get id
    return await FirebaseFunctions.instance
        .httpsCallable("addTeamMember")
        .call(<String, dynamic>{
      'teamId': teamid,
      "members": members,
    });
  }

  static Future<HttpsCallableResult> removeTeamMember(
      String teamid, List<String> members) async {
    //step 1: upload team and get id
    return await FirebaseFunctions.instance
        .httpsCallable("removeTeamMember")
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

  static Future<HttpsCallableResult> uploadPart(
      Part _newPart, Operation operation) async {
    return await FirebaseFunctions.instance
        .httpsCallable("addPart")
        .call(<String, dynamic>{
      "operation": operation.index,
      "teamId": TeamProvider().getCurrentTeam.getTeamId,
      "part": _newPart.toJson(),
      "partId": _newPart.id,
    });
  }

  static Future<HttpsCallableResult> uploadInstrumentInstance(
      InstrumentInstance _newInstrument, Operation operation) async {
    return await FirebaseFunctions.instance
        .httpsCallable("addInstrumentInstance")
        .call(<String, dynamic>{
      "operation": operation.index,
      "teamId": TeamProvider().getCurrentTeam.getTeamId,
      "instrumentId": _newInstrument.instrumentCode,
      "instrument": _newInstrument.toJson(),
    });
  }

  static Future<HttpsCallableResult> uploadInstrument(
      {Instrument instrument, Operation operation}) async {
    return await FirebaseFunctions.instance.httpsCallable("addInstrument").call(
      <String, dynamic>{
        "operation": operation.index,
        "instrument": instrument.toJson(),
        "instrumentId": instrument.id,
        "teamId": TeamProvider().getCurrentTeam.getTeamId
      },
    );
  }

  //Cloud Storage

  static Future<HttpsCallableResult> uploadFields(
      List<Field> fields, String fileName, String instrumentId) async {
    String teamId = TeamProvider().getCurrentTeam.getTeamId;

    return await FirebaseFunctions.instance
        .httpsCallable("addInstrumentReport")
        .call(<String, dynamic>{
      "teamId": teamId,
      "instrumentId": instrumentId,
      "file": fileName,
      "fields": fields.map((field) => field.toJson()).toList(),
    });
  }

  static Future<HttpsCallableResult> uploadInstanceReport(List<Field> fields,
      String instrumentId, String instanceId, String reportName) async {
    String teamId = TeamProvider().getCurrentTeam.getTeamId;

    return await FirebaseFunctions.instance
        .httpsCallable("addInstanceReport")
        .call(<String, dynamic>{
      "teamId": teamId,
      "instrumentId": instrumentId,
      "instanceId": instanceId,
      "reportName": reportName,
      "fields": fields.map((field) => field.toJson()).toList(),
    });
  }

  static Future<HttpsCallableResult> removeTeam(String teamDocId) {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(Authentication().userEmail)
        .collection("teams")
        .doc(teamDocId)
        .delete();
  }

  static Future<HttpsCallableResult> uploadSite(
      Site newSite, Operation operation) async {
    return await FirebaseFunctions.instance
        .httpsCallable("addSite")
        .call(<String, dynamic>{
      "operation": operation.index,
      "teamId": TeamProvider().getCurrentTeam.getTeamId,
      "site": newSite.toJson(),
      "siteId": newSite.id,
    });
  }

  static Future<HttpsCallableResult> uploadRoom(
      String siteId, Room newRoom) async {
    return await FirebaseFunctions.instance
        .httpsCallable("addRoom")
        .call(<String, dynamic>{
      "teamId": TeamProvider().getCurrentTeam.getTeamId,
      "siteId": siteId,
      "room": newRoom.toJson(),
    });
  }

  static Future<HttpsCallableResult> linkInstruments(
      List<InstrumentInstance> selected, String siteId, String roomId) async {
    return await FirebaseFunctions.instance
        .httpsCallable("linkInstruments")
        .call(<String, dynamic>{
      "teamId": TeamProvider().getCurrentTeam.getTeamId,
      "instruments": selected
          .map((e) =>
              {"instrumentCode": e.instrumentCode, "instanceSerial": e.serial})
          .toList(),
      "siteId": siteId,
      "roomId": roomId,
    });
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

  static Future<HttpsCallableResult> transferParts(
      String origin, String destination, Part part, int amount) async {
    return await FirebaseFunctions.instance
        .httpsCallable("transferParts")
        .call(<String, dynamic>{
      "teamId": TeamProvider().getCurrentTeam.getTeamId,
      "origin": origin,
      "destination": destination,
      "partId": part.id,
      "amount": amount,
    });
  }
}
