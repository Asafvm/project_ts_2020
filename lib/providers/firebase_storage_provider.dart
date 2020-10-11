import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class FirebaseStorageProvider {
  static Future<String> uploadFile(File file, String path,
      [String fileName]) async {
    StorageTaskSnapshot snapshot = await FirebaseStorage.instance
        .ref()
        .child(path)
        .child(
            fileName == null ? basenameWithoutExtension(file.path) : fileName)
        .putFile(
          file,
          StorageMetadata(
            contentLanguage: 'en',
            customMetadata: <String, String>{'version': '1'},
          ),
        )
        .onComplete;

    String url = await snapshot.ref.getDownloadURL();
    return url;

    // .then((StorageTaskSnapshot value) async => {
    //       Applogger.consoleLog(MessegeType.info, 'file uploaded'),
    //       Applogger.consoleLog(
    //           MessegeType.info, value.storageMetadata.path),
    //     })
    // .catchError((e) => Applogger.consoleLog(
    //     MessegeType.error, "Error uploading: " + e.toString()));
  }
}
