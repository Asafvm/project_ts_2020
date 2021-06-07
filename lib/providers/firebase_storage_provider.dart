import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:teamshare/helpers/firebase_paths.dart';
import 'package:teamshare/providers/applogger.dart';
import 'package:teamshare/providers/team_provider.dart';

class FirebaseStorageProvider {
  static Future<String> uploadFile(File file, String path,
      [String fileName]) async {
    Reference ref = FirebaseStorage.instance.ref().child(path).child(
        fileName == null ? basenameWithoutExtension(file.path) : fileName);
    UploadTask task = ref.putFile(
      file,
      SettableMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'version': '1'},
      ),
    );

    task.snapshotEvents.listen((TaskSnapshot snapshot) {
      Applogger.consoleLog(MessegeType.info,
          'Snapshot state: ${snapshot.state}'); // paused, running, complete
      Applogger.consoleLog(MessegeType.info,
          'Progress: ${snapshot.totalBytes / snapshot.bytesTransferred}');
    }, onError: (Object e) {
      print(e); // FirebaseException
    }).onDone(() {
      Applogger.consoleLog(MessegeType.info, "done");
    });

    return task.then((TaskSnapshot snapshot) async {
      return snapshot.ref.getDownloadURL();
    }).catchError((Object e) {
      return e.toString();
    });
  }

  static Future<String> downloadFile(String path) async {
    Reference ref = FirebaseStorage.instance.ref().child(path);

    final Directory systemTempDir =
        await Directory('${(await FirebasePaths.rootTeamFolder())}')
            .create(recursive: true);
    final File tempFile = await File(
            '${systemTempDir.path}/${basenameWithoutExtension(path)}.pdf')
        .create();

    if (tempFile.existsSync()) {
      tempFile.writeAsBytes((await ref.getData()));
      // final DownloadTask task = ref.writeToFile(tempFile);
      // await task.whenComplete(() => null);
      return tempFile.path;
    }
    return null;
  }

  static Future<String> downloadFileFromUrl(String url) async {
    Reference ref = FirebaseStorage.instance.refFromURL(url);
    Future<Directory> dir = Directory(
            '${(await getTemporaryDirectory()).path}/${TeamProvider().getCurrentTeam.name}')
        .create(recursive: true);
    final Directory systemTempDir = await dir;

    final File tempFile =
        await File('${systemTempDir.path}/${DateTime.now()}.pdf').create();

    if (tempFile.existsSync()) {
      tempFile.writeAsBytes((await ref.getData()));
      return tempFile.path;
    }
    return null;
  }
}
