import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:teamshare/providers/applogger.dart';

class FirebaseStorageProvider {
  static Future<String> uploadFile(File file, String path,
      [String fileName]) async {
    UploadTask task = FirebaseStorage.instance
        .ref()
        .child(path)
        .child(
            fileName == null ? basenameWithoutExtension(file.path) : fileName)
        .putFile(
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
      return e;
    });
  }
}
