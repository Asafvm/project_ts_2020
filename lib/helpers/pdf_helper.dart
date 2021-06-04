import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:teamshare/helpers/pdf_handler.dart';
import 'package:teamshare/models/field.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:teamshare/providers/consts.dart';

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
    DateFormat formatter = DateFormat('dd-MM-yyyy');

    //add field to pages
    for (Field field in fields) {
      var page = doc.getPage(field.page - 1);
      if (field.type == FieldType.Signature && signature != null)
        page.add(
          item: pdfWidgets.Positioned(
            left: field.offset.dx * page.size.width,
            top: field.offset.dy * page.size.height,
            child: pdfWidgets.SizedBox(
              height: field.size.height,
              width: field.size.width,
              child: pdfWidgets.FittedBox(
                fit: pdfWidgets.BoxFit.contain,
                child: pdfWidgets.Image(
                  pdfWidgets.MemoryImage(signature),
                ),
              ),
            ),
          ),
        );
      else if (field.type == FieldType.Date)
        page.add(
          item: pdfWidgets.Positioned(
            left: field.offset.dx * page.size.width,
            top: field.offset.dy * page.size.height,
            child: pdfWidgets.Padding(
              padding: const pdfWidgets.EdgeInsets.all(3),
              child: pdfWidgets.Text(
                formatter.format(DateTime.fromMillisecondsSinceEpoch(
                    DateTime.now().millisecondsSinceEpoch)),
                style: pdfWidgets.TextStyle(
                  fontSize: field.size.height,
                ),
              ),
            ),
          ),
        );
      else if (field.type == FieldType.Check)
        page.add(
          item: pdfWidgets.Positioned(
            left: field.offset.dx * page.size.width,
            top: field.offset.dy * page.size.height,
            child: pdfWidgets.Center(
              child: pdfWidgets.Text(
                field.isMandatory ? 'X' : '',
                overflow: pdfWidgets.TextOverflow.visible,
                textAlign: pdfWidgets.TextAlign.center,
                style: pdfWidgets.TextStyle(
                  fontSize: field.size.height + 2,
                ),
              ),
            ),
          ),
        );
      else
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
    formatter = DateFormat('yyyy-MM-dd');
    File result = await doc.save(
        filename:
            '${formatter.format(DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch))}_${instrumentId}_$instanceId.pdf');
    //move to team folder
    Directory dir = await Directory('$dest/$siteName').create(recursive: true);
    result.copy('${dir.path}/${basename(result.path)}');
    return result.path;
  }
}
