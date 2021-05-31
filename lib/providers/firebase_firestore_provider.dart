import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamshare/models/contact.dart';
import 'package:teamshare/models/entry.dart';
import 'package:teamshare/models/field.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/models/part.dart';
import 'package:teamshare/models/report.dart';
import 'package:teamshare/models/site.dart';
import 'package:teamshare/models/team.dart';
import 'package:teamshare/providers/authentication.dart';
import '../helpers/firebase_paths.dart';

///*** class changed to static ***///

class FirebaseFirestoreProvider {
//Get from Firebase

  static Stream<List<String>> getUserTeamList() {
    return FirebaseFirestore.instance
        .collection(FirebasePaths.teamsRef)
        .snapshots()
        .map(
          (query) => query.docs.map((doc) => doc.id).toList(),
        );
  }

  static Stream<List<Part>> getCatalogParts() {
    return FirebaseFirestore.instance
        .collection(FirebasePaths.partsStorageCatalogRef)
        .snapshots()
        .map(
          (query) => query.docs
              .map(
                (doc) => Part.fromFirestore(doc),
              )
              .toList(),
        );
  }

  static Stream<List<MapEntry<String, dynamic>>> getInventoryParts(
      String member) {
    return FirebaseFirestore.instance
        .collection(FirebasePaths.partsInventoryRef(member))
        .snapshots()
        .map((query) => query.docs
            .map((doc) => MapEntry(doc.id, doc.data()["count"]))
            .toList());
  }

  static Stream<List<Instrument>> getInstruments() {
    return FirebaseFirestore.instance
        .collection(FirebasePaths.instrumentRef)
        .orderBy("codeName", descending: true)
        .snapshots()
        .map(
          (query) => query.docs
              .map(
                (doc) => Instrument.fromFirestore(doc),
              )
              .toList(),
        );
  }

  static Stream<List<DocumentSnapshot>> getInstrumentReports(
      String instrumentId) {
    return FirebaseFirestore.instance
        .collection(FirebasePaths.instrumentReportRef(instrumentId))
        .snapshots()
        .map((query) => query.docs);
  }

  static Stream<List<InstrumentInstance>> getInstrumentsInstances(
      String instrumentId) {
    return FirebaseFirestore.instance
        .collection("${FirebasePaths.instanceRef(instrumentId)}")
        .snapshots()
        .map(
          (query) => query.docs
              .map(
                (doc) => InstrumentInstance.fromFirestore(doc),
              )
              .toList(),
        );
  }

  // static Stream<List<InstrumentInstance>> getSiteInstances(String siteId) {
  //   return FirebaseFirestore.instance
  //       .collection('${FirebasePaths.roomRef(siteId)}}')
  //       .snapshots()
  //       .map(
  //         (query) => query.docs
  //             .map(
  //               (room) => room.id,
  //             )
  //             .toList(),
  //       );
  // }

  static Future<InstrumentInstance> getInstanceInfo(
      String instrumentId, String instanceId) async {
    return InstrumentInstance.fromFirestore(await FirebaseFirestore.instance
        .doc("${FirebasePaths.instanceRef(instrumentId)}/$instanceId")
        .get());
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
    return FirebaseFirestore.instance
        .collection(FirebasePaths.sitesRef)
        .snapshots()
        .map(
          (query) => query.docs
              .map(
                (doc) => Site.fromFirestore(doc),
              )
              .toList(),
        );
  }

  static Future<Site> getSiteInfo(String siteId) async {
    return Site.fromFirestore(await FirebaseFirestore.instance
        .doc('${FirebasePaths.sitesRef}/$siteId')
        .get());
  }

  static Stream<List<Room>> getRooms(String siteId) {
    return FirebaseFirestore.instance
        .collection(FirebasePaths.roomRef(siteId))
        .snapshots()
        .map(
          (query) => query.docs
              .map(
                (doc) => Room.fromFirestore(doc),
              )
              .toList(),
        );
  }

  static Stream<List<Contact>> getContacts() {
    return FirebaseFirestore.instance
        .collection(FirebasePaths.contactRef)
        .snapshots()
        .map(
          (query) => query.docs
              .map(
                (doc) => Contact.fromFirestore(doc),
              )
              .toList(),
        );
  }

  static Stream<List<String>> getContactsAtSite(String siteId, String roomId) {
    return FirebaseFirestore.instance
        .collection(FirebasePaths.siteContactRef(siteId, roomId))
        .snapshots()
        .map(
          (query) => query.docs
              .map(
                (doc) => doc.id,
              )
              .toList(),
        );
  }

  static Stream<Iterable<MapEntry<String, bool>>> getTeamMembers() {
    return FirebaseFirestore.instance
        .collection(FirebasePaths.membersRef)
        .snapshots()
        .map((query) => query.docs.map<MapEntry<String, bool>>(
              (doc) => MapEntry(doc.id, doc.data()["admin"] as bool),
            ));
  }

  static Future<bool> getPermissions() async {
    return await FirebaseFirestore.instance
        .doc('${FirebasePaths.membersRef}/${Authentication().userEmail}')
        .get()
        .then((value) => value.data()['admin']);
  }

  static Stream<List<Entry>> getEntries(InstrumentInstance instance,
      [bool descending = true]) {
    return FirebaseFirestore.instance
        .collection(
            "${FirebasePaths.instanceEntriesRef(instance.instrumentId, instance.serial)}")
        .orderBy("timestamp", descending: descending) //newest first
        .snapshots()
        .map(
          (query) => query.docs
              .map(
                (doc) => Entry.fromFirestore(doc),
              )
              .toList(),
        );
  }

  static Stream<List<Entry>> getTeamEntries() {
    return FirebaseFirestore.instance
        .collection("${FirebasePaths.teamEntriesRef}")
        .orderBy("timestamp", descending: true) //newest first
        .snapshots()
        .map(
          (query) => query.docs
              .map(
                (doc) => Entry.fromFirestore(doc),
              )
              .toList(),
        );
  }

  static Future<List<Field>> getReportFields(
      {String instrumentId, String instanceId, String reportId}) async {
    DocumentSnapshot result = await FirebaseFirestore.instance
        .doc(
            "${FirebasePaths.instanceReportRef(instrumentId, instanceId, reportId)}")
        .get();

    return result
        .data()
        .values
        .map((values) => Field.fromJson(values["fields"]))
        .toList();
  }

  static Stream<List<Report>> getAllReportFields(
      {String instrumentId, String instanceId, String reportId}) {
    return FirebaseFirestore.instance
        .collection(
            "${FirebasePaths.instanceReportRef(instrumentId, instanceId, "")}")
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((query) =>
            query.docs.map((doc) => Report.fromFirestore(doc)).toList());
  }
}
