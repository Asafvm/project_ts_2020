import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:path_provider/path_provider.dart';
import 'package:teamshare/providers/authentication.dart';
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/providers/team_provider.dart';

class FirebasePaths {
  static String get teamId => TeamProvider().getCurrentTeam.getTeamId;

  //Firestore Refs
  static String get teamsRef => '$users/${Authentication().userEmail}/$teams';
  static String get membersRef => '$teams/$teamId/$members';
  static String get instrumentRef => '$teams/$teamId/$instruments';
  static String instanceRef(String instrumentId) =>
      '$teams/$teamId/$instruments/$instrumentId/$instances';
  static String instanceEntriesRef(String instrumentId, String instanceId) =>
      '$teams/$teamId/$instruments/$instrumentId/$instances/$instanceId/$entries';
  static String get teamEntriesRef => '$teams/$teamId/$entries';
  static String instrumentReportRef(String instrumentId) =>
      '$teams/$teamId/$instruments/$instrumentId/$reports';
  static instanceReportRef(
          String instrumentId, String instanceId, String reportId) =>
      '$teams/$teamId/$instruments/$instrumentId/$instances/$instanceId/$reports/$reportId';
  static String get partsStorageCatalogRef => '$teams/$teamId/$parts';
  static String partsInventoryRef(String memberId) =>
      '$teams/$teamId/$members/$memberId/$inventory';

  static String get sitesRef => '$teams/$teamId/$sites';
  static String get contactRef => '$teams/$teamId/$contacts';
  static String roomRef(String siteId) =>
      '$teams/$teamId/$sites/$siteId/$rooms';
  static String siteContactRef(String siteId, String roomId) =>
      '$teams/$teamId/$sites/$siteId/$rooms/$roomId/$contacts';

//Cloud Storage Paths
  static String instrumentReportTemplatePath(String instrumentId) =>
      '$teamId/$instruments/$instrumentId/$report_templates';
  static String instanceReportPath(String instrumentId, String instanceId) =>
      '$teamId/$instruments/$instrumentId/$instanceId/$reports';
  static String instanceReportImagePath(
          String instrumentId, String instanceId) =>
      '$teamId/$instruments/$instrumentId/$instanceId/$reports/$images';
  static String instrumentImagePath(String instrumentId) =>
      '$teamId/$instruments/$instrumentId/$images';
  static String instanceImagePath(String instrumentId, String instanceId) =>
      '$teamId/$instruments/$instrumentId/$instanceId/$images';
  static String partImagePath(String partId) =>
      '$teamId/$parts/$partId/$images';
  static String siteImagePath(String siteId) =>
      '$teamId/$sites/$siteId/$images';

//System files
  static Future<String> rootTeamFolder() async {
    if (kIsWeb) {
      return null; //no supoort yet
    }
    if (Platform.isAndroid || Platform.isIOS)
      return '${(await getTemporaryDirectory()).path}/${TeamProvider().getCurrentTeam.name}';
    return '${(await getDownloadsDirectory()).path}/${TeamProvider().getCurrentTeam.name}';
  }
}
