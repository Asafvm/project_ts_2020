import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

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
      print('Snapshot state: ${snapshot.state}'); // paused, running, complete
      print('Progress: ${snapshot.totalBytes / snapshot.bytesTransferred}');
    }, onError: (Object e) {
      print(e); // FirebaseException
    });

    task.then((TaskSnapshot snapshot) async {
      return await snapshot.ref.getDownloadURL();
    }).catchError((Object e) {
      print(e); // FirebaseException
      return null;
    });
    return null;
  }
}
