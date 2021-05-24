import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:teamshare/helpers/pdf_handler.dart';
import 'package:teamshare/models/field.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;

import 'firebase_paths.dart';

class PdfHelper {
  static Future<String> createPdf(
      {List<Field> fields,
      String instrumentId,
      String instanceId,
      bool isNew,
      String pdfPath,
      String siteName,
      Uint8List signature}) async {
    //open pdf file
    PdfMutableDocument doc = await PdfMutableDocument.path(pdfPath);

    //add field to pages
    for (Field field in fields) {
      var page = doc.getPage(field.page - 1);
      if (signature != null)
        page.add(
            item: pdfWidgets.Positioned(
                left: page.size.width - 200,
                top: page.size.height - 200,
                child: pdfWidgets.SizedBox(
                    height: 100,
                    width: 200,
                    child: pdfWidgets.Center(
                        child: pdfWidgets.Image(
                            pdfWidgets.MemoryImage(signature))))));

      page.add(
        item: pdfWidgets.Positioned(
          left: field.offset.dx * page.size.width,
          top: field.offset.dy * page.size.height,
          child: pdfWidgets.Padding(
            padding: const pdfWidgets.EdgeInsets.all(5),
            child: pdfWidgets.Text(
              field.defaultValue,
              style: pdfWidgets.TextStyle(
                fontSize: field.size.height,
              ),
            ),
          ),
        ),
      );
    } //save modified pdf
    String dest = await FirebasePaths.rootTeamFolder();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    File result = await doc.save(
        filename:
            '${formatter.format(DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch))}_${instrumentId}_$instanceId.pdf');
    //move to team folder
    Directory dir = await Directory('$dest/$siteName').create(recursive: true);
    result.copy('${dir.path}/${basename(result.path)}');
    return result.path;
  }
}
