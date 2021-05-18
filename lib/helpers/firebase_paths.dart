import 'package:path_provider/path_provider.dart';
import 'package:teamshare/providers/authentication.dart';
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/providers/team_provider.dart';

class FirebasePaths {
  //Firestore Refs
  static String get teamsRef => '$users/${Authentication().userEmail}/$teams';
  static String get membersRef =>
      '$teams/${TeamProvider().getCurrentTeam.getTeamId}/$members';
  static String get instrumentRef =>
      '$teams/${TeamProvider().getCurrentTeam.getTeamId}/$instruments';
  static String instanceRef(String instrumentId) =>
      '$teams/${TeamProvider().getCurrentTeam.getTeamId}/$instruments/$instrumentId/$instances';
  static String instanceEntriesRef(String instrumentId, String instanceId) =>
      '$teams/${TeamProvider().getCurrentTeam.getTeamId}/$instruments/$instrumentId/$instances/$instanceId/$entries';
  static String instanceReportRef(String instrumentId) =>
      '$teams/${TeamProvider().getCurrentTeam.getTeamId}/$instruments/$instrumentId/$reports';
  static String get partsStorageRef =>
      '$teams/${TeamProvider().getCurrentTeam.getTeamId}/$parts';
  static String get partsPersonalRef =>
      '$teams/${TeamProvider().getCurrentTeam.getTeamId}/$members/${Authentication().userEmail}/$inventory';
  static String partsMemberRef(String memberId) =>
      '$teams/${TeamProvider().getCurrentTeam.getTeamId}/$members/$memberId/$inventory';
  static String get sitesRef =>
      '$teams/${TeamProvider().getCurrentTeam.getTeamId}/$sites';
  static String get contactRef =>
      '$teams/${TeamProvider().getCurrentTeam.getTeamId}/$contacts';
  static String roomRef(String siteId) =>
      '$teams/${TeamProvider().getCurrentTeam.getTeamId}/$sites/$siteId/$rooms';
  static String siteContactRef(String siteId, String roomId) =>
      '$teams/${TeamProvider().getCurrentTeam.getTeamId}/$sites/$siteId/$rooms/$roomId/$contacts';

//Cloud Storage Paths
  static String instrumentReportTemplatePath(String instrumentId) =>
      '${TeamProvider().getCurrentTeam.getTeamId}/$instruments/$instrumentId/$report_templates';
  static String instanceReportPath(String instrumentId, String instanceId) =>
      '${TeamProvider().getCurrentTeam.getTeamId}/$instruments/$instrumentId/$instanceId/$reports';
  static String instanceReportImagePath(
          String instrumentId, String instanceId) =>
      '${TeamProvider().getCurrentTeam.getTeamId}/$instruments/$instrumentId/$instanceId/$reports/$images';
  static String instrumentImagePath(String instrumentId) =>
      '${TeamProvider().getCurrentTeam.getTeamId}/$instruments/$instrumentId/$images';
  static String instanceImagePath(String instrumentId, String instanceId) =>
      '${TeamProvider().getCurrentTeam.getTeamId}/$instruments/$instrumentId/$instanceId/$images';
  static String partImagePath(String partId) =>
      '${TeamProvider().getCurrentTeam.getTeamId}/$parts/$partId/$images';
  static String siteImagePath(String siteId) =>
      '${TeamProvider().getCurrentTeam.getTeamId}/$sites/$siteId/$images';

  static Future<String> rootTeamFolder() async =>
      '${(await getTemporaryDirectory()).path}/${TeamProvider().getCurrentTeam.name}';
}
