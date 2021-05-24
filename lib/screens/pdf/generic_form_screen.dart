import 'dart:ffi';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:teamshare/helpers/pdf_helper.dart';
import 'package:teamshare/helpers/signature.dart';
import 'package:teamshare/models/field.dart';
import 'package:teamshare/providers/applogger.dart';
import 'package:teamshare/providers/firebase_firestore_cloud_functions.dart';
import 'package:teamshare/screens/pdf/pdf_viewer_page.dart';

class GenericFormScreen extends StatefulWidget {
  final String pdfPath;
  final List<Field> fields;
  final String instrumentId;
  final String instanceId;
  final String siteName;
  const GenericFormScreen(
      {this.fields,
      this.pdfPath,
      this.siteName,
      this.instrumentId,
      this.instanceId});

  @override
  _GenericFormScreenState createState() => _GenericFormScreenState();
}

class _GenericFormScreenState extends State<GenericFormScreen> {
  Uint8List image;
  var controllersArray = List<TextEditingController>.empty();
  @override
  void initState() {
    super.initState();

    controllersArray = List<TextEditingController>.generate(
        widget.fields.length, (index) => TextEditingController());
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
              for (Field field in widget.fields) _buildGenericField(field),
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
              controller: controllersArray[widget.fields.indexOf(field)],
              maxLength: (field.size.width / (field.size.height / 2.50))
                  .round(), //width of field / width of character
              decoration: InputDecoration(
                hintStyle: TextStyle(color: Colors.grey),
                hintText: field.defaultValue,
                labelText: field.hint,
                labelStyle: TextStyle(color: Colors.black),
              ),
              validator: (value) {
                if (value.isEmpty && field.isMandatory)
                  return 'Password cannot be empty';
                return null;
              },
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
      //get signature
      Uint8List imagedata = await Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => SignatureHelper()));
      //compose pdf
      String resultPath = await PdfHelper.createPdf(
        fields: widget.fields,
        instanceId: widget.instanceId,
        instrumentId: widget.instrumentId,
        pdfPath: widget.pdfPath,
        siteName: widget.siteName,
        signature: imagedata,
      );

      //display result
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PDFScreen(
          fields: [],
          pathPDF: resultPath,
          onlyFields: true,
          instrumentID: widget.instrumentId,
        ),
      ));
    } catch (e, s) {
      Applogger.consoleLog(MessegeType.error, "Failed filling form\n$e\n$s");
      Navigator.of(context).pop(false); //formFilled = false

    }
  }

  Future<void> _submit(BuildContext context) async {
    //update default values
    widget.fields.forEach((field) {
      field.defaultValue =
          controllersArray.elementAt(widget.fields.indexOf(field)).text;
    });
    //upload fields
    var result = await FirebaseFirestoreCloudFunctions.uploadInstanceReport(
        widget.fields,
        widget.instrumentId,
        widget.instanceId,
        basenameWithoutExtension(widget.pdfPath));
    print(result.data);
    if (result.data["status"] == "success") {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Uploaded seccessfuly')));
      Navigator.of(context).pop();
    }
  }

  Size calcTextSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaleFactor: WidgetsBinding.instance.window.textScaleFactor,
    )..layout();
    return textPainter.size;
  }
}
