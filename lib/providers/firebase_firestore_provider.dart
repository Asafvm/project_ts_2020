import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/models/part.dart';
import 'package:teamshare/models/site.dart';
import 'package:teamshare/providers/team_provider.dart';

import 'authentication.dart';

///*** class changed to static ***///

class FirebaseFirestoreProvider {
  static const String instruments = "instruments";
  static const String teams = "teams";
  static const String sites = "sites";
  static const String rooms = "rooms";
//Get from Firebase

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

  static Stream<List<InstrumentInstance>> getInstrumentsInstances(
      String instrumentCode) {
    String instrumentRef =
        "$teams/${TeamProvider().getCurrentTeam.getTeamId}/$instruments/$instrumentCode/instances";
    return FirebaseFirestore.instance
        .collection("$instrumentRef")
        .snapshots()
        .map((list) => list.docs
            .map((item) => InstrumentInstance.fromFirestore(item))
            .toList());
  }

  static Stream<List<InstrumentInstance>> getAllInstrumentsInstances() {
    return FirebaseFirestore.instance
        .collectionGroup("instances")
        .snapshots()
        .map((list) => list.docs
            .map((item) => InstrumentInstance.fromFirestore(item))
            .toList());
  }

  static Stream<Map<String, dynamic>> getTeamInfo(String teamDocId) {
    return FirebaseFirestore.instance
        .collection("teams")
        .doc(teamDocId)
        .get()
        .then((value) => value.data())
        .asStream();
  }

  static Stream<List<Site>> getSites() {
    String sitesRef =
        "$teams/${TeamProvider().getCurrentTeam.getTeamId}/$sites";
    return FirebaseFirestore.instance
        .collection(sitesRef)
        .get()
        .then((value) =>
            value.docs.map((site) => Site.fromFirestore(site)).toList())
        .asStream();
  }

  static Future<List<Room>> getRooms(String siteId) async {
    String roomRef =
        "$teams/${TeamProvider().getCurrentTeam.getTeamId}/$sites/$siteId/$rooms";

    List<Room> roomList = await FirebaseFirestore.instance
        .collection(roomRef)
        .get()
        .then((value) =>
            value.docs.map((room) => Room.fromFirestore(room)).toList());

    return roomList;
  }
}
