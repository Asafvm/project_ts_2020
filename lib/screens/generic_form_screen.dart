import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:teamshare/helpers/pdf_handler.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:teamshare/models/field.dart';
import 'package:teamshare/providers/applogger.dart';

class GenericFormScreen extends StatefulWidget {
  final String pdfPath;
  final Map<String, dynamic> fields;

  const GenericFormScreen({this.fields, this.pdfPath});
  @override
  _GenericFormScreenState createState() => _GenericFormScreenState();
}

class _GenericFormScreenState extends State<GenericFormScreen> {
  Uint8List image;
  List<Field> fields = [];
  @override
  void initState() {
    super.initState();

    fields = widget.fields.values.map((e) => Field.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Insert Form Name here"),
        ),
        body: Column(
          children: [
            for (Field field in fields) _buildGenericField(field),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FlatButton.icon(
                  icon: Icon(Icons.preview),
                  onPressed: _preview,
                  color: Theme.of(context).primaryColor.withAlpha(180),
                  label: Text("Preview"),
                ),
                FlatButton.icon(
                  icon: Icon(Icons.send),
                  onPressed: () {},
                  color: Theme.of(context).primaryColor.withAlpha(180),
                  label: Text("Submit"),
                )
              ],
            ),
          ],
        ));
  }

  _buildGenericField(Field field) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (field.prefix.isNotEmpty)
            Flexible(
                flex: 3,
                fit: FlexFit.tight,
                child: Text(
                  field.prefix,
                  textAlign: TextAlign.start,
                )),
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: TextFormField(
              decoration: InputDecoration(
                hintStyle: TextStyle(color: Colors.grey),
                hintText: field.defaultValue,
                labelText: field.hint,
                labelStyle: TextStyle(color: Colors.black),
                // validator: (value) {
                //   if (value.isEmpty) return 'Password cannot be empty';
                //   return null;
                // },
                // onSaved: (val) {
                //   _authData['password'] = val;
                // },
              ),
            ),
          ),
          if (field.suffix.isNotEmpty)
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Text(
                field.suffix,
                textAlign: TextAlign.start,
              ),
            )
          else
            Flexible(flex: 1, fit: FlexFit.tight, child: SizedBox()),
        ],
      ),
    );
  }

  Future<void> _preview() async {
    try {
      PdfMutableDocument doc = await PdfMutableDocument.path(widget.pdfPath);

      // PdfMutableDocument doc =
      //     await PdfMutableDocument.asset("assets/pdf/blank.pdf");

      for (Field field in fields) {
        var page = doc.getPage(field.page);
        page.add(
          item: pdfWidgets.Positioned(
            left: field.offset.dx,
            top: field.offset.dy,
            child: pdfWidgets.Text(
              field.defaultValue,
              // style:
              //     pdfWidgets.TextStyle(fontSize: 32, color: pdf.PdfColors.red),
            ),
          ),
        );
      }

      File result =
          await doc.save(filename: '${DateTime.now().toIso8601String()}.pdf');
      Applogger.consoleLog(MessegeType.info, "PDF Editing Done");

      result.copy((await getExternalCacheDirectories()).first.path);
      Navigator.of(context).pop(true); //formFilled = true
    } catch (e, s) {
      Applogger.consoleLog(MessegeType.error, "Failed filling form\n$e\n$s");
      Navigator.of(context).pop(false); //formFilled = false

    }
  }
}
