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
  static List<Instrument> _instrumentImage = [];
  static List<InstrumentInstance> _instanceImage = [];
  static List<Site> _siteImage = [];
  static List<Part> _partImage = [];
  static List<Report> _teamReportsImage = [];

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
      (query) {
        _partImage = query.docs
            .map(
              (doc) => Part.fromFirestore(doc),
            )
            .toList();
        return _partImage;
      },
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
      (query) {
        _instrumentImage = query.docs
            .map(
              (doc) => Instrument.fromFirestore(doc),
            )
            .toList();
        return _instrumentImage;
      },
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
      (query) {
        _instanceImage = query.docs
            .map(
              (doc) => InstrumentInstance.fromFirestore(doc),
            )
            .toList();
        return _instanceImage;
      },
    );
  }

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
      (query) {
        _siteImage = query.docs
            .map(
              (doc) => Site.fromFirestore(doc),
            )
            .toList();
        return _siteImage;
      },
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

  static Stream<List<Report>> getTeamReport({bool decending = false}) {
    return FirebaseFirestore.instance
        .collection("${FirebasePaths.teamReportRef}")
        .orderBy("index", descending: decending)
        .snapshots()
        .map((values) {
      _teamReportsImage =
          values.docs.map((e) => Report.fromFirestore(e)).toList();
      return _teamReportsImage;
    });
  }

  static Instrument getInstrumentById(String instrumentId) {
    return _instrumentImage.firstWhere((element) => element.id == instrumentId);
  }

  static InstrumentInstance getInstanceById(String instanceId) {
    return _instanceImage.firstWhere((element) => element.serial == instanceId);
  }

  static Site getSiteById(String siteId) {
    return siteId == "Main"
        ? Site(name: 'Main')
        : _siteImage.firstWhere((element) => element.id == siteId);
  }

  static Part getPartById(String partId) {
    return _partImage.firstWhere((element) => element.id == partId);
  }

  static Report getReportById(String reportId) {
    return _teamReportsImage.firstWhere((element) => element.id == reportId);
  }
}
