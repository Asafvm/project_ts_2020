import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class FirebaseStorageProvider {
  Future<void> uploadFile(File file, String path) async {
    await FirebaseStorage.instance
        .ref()
        .child('username')
        .child("company")
        .child("Instruments")
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
              print('file uploaded'),
            })
        .catchError((e) => print("Error uploading: " + e.toString()));
  }
}
