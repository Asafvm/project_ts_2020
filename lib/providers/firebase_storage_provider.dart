import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:teamshare/providers/applogger.dart';
import 'package:teamshare/providers/authentication.dart';
import 'package:teamshare/providers/team_provider.dart';

class FirebaseStorageProvider {
  static Future<void> uploadFile(File file, String path) async {
    await FirebaseStorage.instance
        .ref()
        .child(Authentication().userId)
        .child(TeamProvider().getCurrentTeam.getTeamId)
        .child("instruments")
        .child(path)
        .child(basenameWithoutExtension(file.path))
        .putFile(
          file,
          StorageMetadata(
            contentLanguage: 'en',
            customMetadata: <String, String>{'version': '1'},
          ),
        )
        .onComplete
        .then((value) async => {
              Applogger.consoleLog(MessegeType.info, 'file uploaded'),
            })
        .catchError((e) => Applogger.consoleLog(
            MessegeType.error, "Error uploading: " + e.toString()));
  }
}
