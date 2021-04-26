import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamshare/models/contact.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/models/part.dart';
import 'package:teamshare/models/site.dart';
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
  static const String parts = "parts";
//Get from Firebase

  static Stream<QuerySnapshot> getUserTeamList() {
    String teamsRef = "$users/${Authentication().userEmail}/$teams";
    return FirebaseFirestore.instance.collection(teamsRef).snapshots();
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
}
