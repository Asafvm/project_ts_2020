import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:teamshare/helpers/pdf_handler.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:teamshare/models/field.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/providers/applogger.dart';
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/providers/firebase_firestore_cloud_functions.dart';
import 'package:teamshare/providers/team_provider.dart';
import 'package:teamshare/screens/pdf/pdf_viewer_page.dart';

class GenericFormScreen extends StatefulWidget {
  final String pdfPath;
  final Map<String, dynamic> fields;
  final InstrumentInstance instance;
  const GenericFormScreen({this.fields, this.pdfPath, this.instance});
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              for (Field field in fields) _buildGenericField(field),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    icon: Icon(Icons.preview),
                    onPressed: () => _preview(context),
                    label: Text("Preview"),
                  ),
                  TextButton.icon(
                    icon: Icon(Icons.send),
                    onPressed: () => _submit(context),
                    label: Text("Submit"),
                  )
                ],
              ),
            ],
          ),
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
          if (field.suffix != null)
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

  Future<void> _preview(BuildContext context) async {
    try {
      PdfMutableDocument doc = await PdfMutableDocument.path(widget.pdfPath);

      // PdfMutableDocument doc =
      //     await PdfMutableDocument.asset("assets/pdf/blank.pdf");

      //add field to pages
      for (Field field in fields) {
        var page = doc.getPage(field.page);
        page.add(
          item: pdfWidgets.Positioned(
            left: field.offset.dx * page.size.width,
            top: field.offset.dy * page.size.height,
            child: pdfWidgets.Text(field.defaultValue ?? '!!!',
                style: pdfWidgets.TextStyle(fontSize: field.size.height)),
          ),
        );
      }
      String dest =
          '${(await getTemporaryDirectory()).path}/${TeamProvider().getCurrentTeam.name}';

      File result = await doc
          .save(filename: '${DateTime.now().toIso8601String()}.pdf')
          .then((value) => value.copy('$dest/${basename(value.path)}'));
      Applogger.consoleLog(MessegeType.info, "PDF Editing Done");

      //result = await result.copy();

      Navigator.of(context)
          .push(MaterialPageRoute(
            builder: (context) => PDFScreen(
              fields: [],
              pathPDF: result.path,
              onlyFields: true,
              instrumentID: widget.instance.instrumentCode,
            ),
          ))
          .then(
              (value) => Navigator.of(context).pop(true)); //formFilled = true);

    } catch (e, s) {
      Applogger.consoleLog(MessegeType.error, "Failed filling form\n$e\n$s");
      Navigator.of(context).pop(false); //formFilled = false

    }
  }

  Future<void> _submit(BuildContext context) async {
    var result = await FirebaseFirestoreCloudFunctions.uploadInstanceReport(
        fields, widget.instance.instrumentCode, widget.instance.serial);
    print(result.data);
    if (result.data["status"] == "success") Navigator.of(context).pop();
  }
}