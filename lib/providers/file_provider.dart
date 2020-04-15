import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class FileProvider {
  static Future<String> _localPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static void writeFile(File file) async {
    _localPath().then((onValue) => print(onValue + "/" + basename(file.path)));

    await CloudFunctions.instance
        .getHttpsCallable(functionName: "generateThumbnail")
        .call(<String, dynamic>{});
  }
}
