import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamshare/models/contact.dart';
import 'package:teamshare/models/entry.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/models/part.dart';
import 'package:teamshare/models/site.dart';
import 'package:teamshare/models/team.dart';
import 'firebase_paths.dart';

///*** class changed to static ***///

class FirebaseFirestoreProvider {
//Get from Firebase

  static Stream<List<String>> getUserTeamList() {
    Stream<List<String>> stream = FirebaseFirestore.instance
        .collection(FirebasePaths.teamsRef)
        .snapshots()
        .map(
          (query) => query.docs.map((doc) => doc.id).toList(),
        );
    return stream;
  }

  static Stream<List<Part>> getStorageParts() {
    return FirebaseFirestore.instance
        .collection(FirebasePaths.partsStorageRef)
        .snapshots()
        .map(
          (query) => query.docs
              .map(
                (doc) => Part.fromFirestore(doc),
              )
              .toList(),
        );
  }

  static Stream<List<String>> getPersonalParts() {
    return FirebaseFirestore.instance
        .collection(FirebasePaths.partsPersonalRef)
        .snapshots()
        .map(
          (query) => query.docs
              .map(
                (doc) => doc.id,
              )
              .toList(),
        );
  }

  static Stream<List<String>> getMemberParts(String memberId) {
    return FirebaseFirestore.instance
        .collection(FirebasePaths.partsMemberRef(memberId))
        .snapshots()
        .map(
          (query) => query.docs
              .map(
                (doc) => doc.id,
              )
              .toList(),
        );
  }

  static Stream<List<Instrument>> getInstruments() {
    return FirebaseFirestore.instance
        .collection(FirebasePaths.instrumentRef)
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
        .collection(FirebasePaths.instanceReportRef(instrumentId))
        .snapshots()
        .map((query) => query.docs);
  }

  static Stream<List<InstrumentInstance>> getInstrumentsInstances(
      String instrumentCode) {
    return FirebaseFirestore.instance
        .collection("${FirebasePaths.instanceRef(instrumentCode)}")
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
    // String sitesRef =
    //     "$teams/${TeamProvider().getCurrentTeam.getTeamId}/$sites";
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

  static Stream<List<Room>> getRooms(String siteId) {
    // String roomRef =
    //     "$teams/${TeamProvider().getCurrentTeam.getTeamId}/$sites/$siteId/$rooms";

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
    // String contactRef =
    //     '$teams/${TeamProvider().getCurrentTeam.getTeamId}/$contacts';

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
    // String contactRef =
    //     '$teams/${TeamProvider().getCurrentTeam.getTeamId}/$sites/$siteId/$rooms/$roomId/$contacts';

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

  static Stream<List<String>> getTeamMembers() {
    // String membersRef =
    //     '$teams/${TeamProvider().getCurrentTeam.getTeamId}/$members';

    return FirebaseFirestore.instance
        .collection(FirebasePaths.membersRef)
        .snapshots()
        .map(
          (query) => query.docs
              .map(
                (doc) => doc.id,
              )
              .toList(),
        );
  }

  static Stream<List<Entry>> getEntries(InstrumentInstance instance,
      [bool descending = true]) {
    return FirebaseFirestore.instance
        .collection(
            "${FirebasePaths.instanceEntriesRef(instance.instrumentCode, instance.serial)}")
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
}
