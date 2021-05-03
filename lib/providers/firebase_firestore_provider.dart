import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamshare/models/contact.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/models/part.dart';
import 'package:teamshare/models/site.dart';
import 'package:teamshare/models/team.dart';
import 'package:teamshare/providers/team_provider.dart';

import 'authentication.dart';

///*** class changed to static ***///

class FirebaseFirestoreProvider {
  static const String instruments = "instruments";
  static const String instances = "instances";
  static const String users = "users";
  static const String teams = "teams";
  static const String sites = "sites";
  static const String rooms = "rooms";
  static const String contacts = "contacts";
  static const String members = "members";
  static const String parts = "parts";
//Get from Firebase

  static Stream<List<String>> getUserTeamList() {
    String teamsRef = "$users/${Authentication().userEmail}/$teams";
    Stream<List<String>> stream =
        FirebaseFirestore.instance.collection(teamsRef).snapshots().map(
              (query) => query.docs.map((doc) => doc.id).toList(),
            );
    return stream;
  }

  static Stream<List<Part>> getParts() {
    String partsRef =
        "$teams/${TeamProvider().getCurrentTeam.getTeamId}/$parts";
    return FirebaseFirestore.instance.collection(partsRef).snapshots().map(
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
    return FirebaseFirestore.instance.collection(instrumentRef).snapshots().map(
          (query) => query.docs
              .map(
                (doc) => Instrument.fromFirestore(doc),
              )
              .toList(),
        );
  }

  static Stream<List<InstrumentInstance>> getInstrumentsInstances(
      String instrumentCode) {
    String instrumentRef =
        "$teams/${TeamProvider().getCurrentTeam.getTeamId}/$instruments/$instrumentCode/$instances";
    return FirebaseFirestore.instance
        .collection("$instrumentRef")
        .snapshots()
        .map(
          (query) => query.docs
              .map(
                (doc) => InstrumentInstance.fromFirestore(doc),
              )
              .toList(),
        );
  }

  static Stream<List<InstrumentInstance>> getAllInstrumentsInstances() {
    return FirebaseFirestore.instance
        .collectionGroup("instances")
        .snapshots()
        .map(
          (list) => list.docs
              .map(
                (item) => InstrumentInstance.fromFirestore(item),
              )
              .toList(),
        );
  }

  static Future<Team> getTeamInfo(String teamDocId) async {
    return Team.fromFirebase(await FirebaseFirestore.instance
        .collection("teams")
        .doc(teamDocId)
        .get());
  }

  static Stream<List<Site>> getSites() {
    String sitesRef =
        "$teams/${TeamProvider().getCurrentTeam.getTeamId}/$sites";
    return FirebaseFirestore.instance.collection(sitesRef).snapshots().map(
          (query) => query.docs
              .map(
                (doc) => Site.fromFirestore(doc),
              )
              .toList(),
        );
  }

  static Stream<List<Room>> getRooms(String siteId) {
    String roomRef =
        "$teams/${TeamProvider().getCurrentTeam.getTeamId}/$sites/$siteId/$rooms";

    return FirebaseFirestore.instance.collection(roomRef).snapshots().map(
          (query) => query.docs
              .map(
                (doc) => Room.fromFirestore(doc),
              )
              .toList(),
        );
  }

  static Stream<List<Contact>> getContacts() {
    String contactRef =
        '$teams/${TeamProvider().getCurrentTeam.getTeamId}/$contacts';

    return FirebaseFirestore.instance.collection(contactRef).snapshots().map(
          (query) => query.docs
              .map(
                (doc) => Contact.fromFirestore(doc),
              )
              .toList(),
        );
  }

  static Stream<List<String>> getContactsAtSite(String siteId, String roomId) {
    String contactRef =
        '$teams/${TeamProvider().getCurrentTeam.getTeamId}/$sites/$siteId/$rooms/$roomId/$contacts';

    return FirebaseFirestore.instance.collection(contactRef).snapshots().map(
          (query) => query.docs
              .map(
                (doc) => doc.id,
              )
              .toList(),
        );
  }

  static Stream<List<String>> getTeamMembers(String getTeamId) {
    String membersRef =
        '$teams/${TeamProvider().getCurrentTeam.getTeamId}/$members';

    return FirebaseFirestore.instance.collection(membersRef).snapshots().map(
          (query) => query.docs
              .map(
                (doc) => doc.id,
              )
              .toList(),
        );
  }
}
