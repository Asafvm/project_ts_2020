import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:teamshare/providers/applogger.dart';

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
    // String url = await ref.getDownloadURL();
    // final http.Response downloadData = await http.get(url);
    final Directory systemTempDir = Directory.systemTemp;
    final File tempFile =
        File('${systemTempDir.path}/${basenameWithoutExtension(path)}.pdf');
    if (tempFile.existsSync()) {
      await tempFile.delete();
    }
    await tempFile.create();
    final DownloadTask task = ref.writeToFile(tempFile);
    await task.whenComplete(() => null);
    return tempFile.path;
    // final int byteCount = task.snapshot.totalBytes;
    // var bodyBytes = downloadData.bodyBytes;
    // final String name = await ref.getName();
    //final String path = await ref.getPath();
  }
}
