import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:teamshare/helpers/firebase_paths.dart';
import 'package:teamshare/helpers/pdf_helper.dart';
import 'package:teamshare/helpers/signature.dart';
import 'package:teamshare/models/field.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/models/report.dart';
import 'package:teamshare/providers/applogger.dart';
import 'package:teamshare/providers/authentication.dart';
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/providers/firebase_firestore_cloud_functions.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/providers/firebase_storage_provider.dart';
import 'package:teamshare/screens/pdf/pdf_viewer_page.dart';

class GenericFormScreen extends StatefulWidget {
  final String pdfId;
  final List<Field> fields;
  final InstrumentInstance instance;
  final String siteId;
  final String reportId;
  final String reportIndex;
  const GenericFormScreen(
      {this.fields,
      this.pdfId,
      this.siteId,
      this.instance,
      this.reportId,
      this.reportIndex});

  @override
  _GenericFormScreenState createState() => _GenericFormScreenState();
}

class _GenericFormScreenState extends State<GenericFormScreen> {
  Uint8List image;
  var controllersArray = List<TextEditingController>.empty();

  bool _loading = false;
  @override
  void initState() {
    super.initState();
    widget.fields.sort((f1, f2) => f1.index < f2.index ? -1 : 1);
    controllersArray = List<TextEditingController>.generate(
        widget.fields.length, (index) => TextEditingController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Insert Form Name here"),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (Field field in widget.fields) _buildGenericField(field),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          kIsWeb
              ? TextButton.icon(
                  icon:
                      _loading ? CircularProgressIndicator() : Icon(Icons.send),
                  onPressed: _loading ? null : () => _submit(context),
                  label: Text("Submit"),
                )
              : TextButton.icon(
                  icon: _loading
                      ? CircularProgressIndicator()
                      : Icon(Icons.preview),
                  onPressed: _loading ? null : () => _preview(context),
                  label: Text("Preview"),
                )
        ],
      ),
    );
  }

  _buildGenericField(Field field) {
    switch (field.type) {
      case FieldType.Text:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
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
                  enabled: !_loading,
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
                      return 'Cannot be empty';
                    return null;
                  },
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
        break;
      case FieldType.Num:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
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
                  enabled: !_loading,
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
                      return 'Cannot be empty';
                    return null;
                  },
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
        break;
      case FieldType.Date:
        return Container();
        break;
      case FieldType.Check:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (field.prefix.isNotEmpty)
                Expanded(
                    flex: 3,
                    child: Text(
                      field.prefix,
                      textAlign: TextAlign.start,
                    )),
              Expanded(
                flex: 1,
                child: Checkbox(
                    value: field.isMandatory,
                    onChanged: _loading
                        ? null
                        : (value) {
                            setState(() {
                              field.isMandatory = value;
                            });
                          }),
              ),
            ],
          ),
        );
        break;
      case FieldType.Signature:
        return Container();
        break;
    }
  }

  Future<void> _preview(BuildContext context) async {
    try {
      setState(() {
        _loading = true;
      });

      //download report template
      String downloadedPdfPath = await FirebaseStorageProvider.downloadFile(
          '${FirebasePaths.instrumentReportTemplatePath(widget.instance.instrumentId)}/${widget.pdfId}');
      if (downloadedPdfPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Could not download report. Please check your internet connection.')));
        return;
      }

      //update default values
      widget.fields
          .where((field) =>
              field.type == FieldType.Text || field.type == FieldType.Num)
          .forEach((field) {
        String userValue =
            controllersArray.elementAt(widget.fields.indexOf(field)).text;
        if (userValue.isNotEmpty)
          field.defaultValue =
              controllersArray.elementAt(widget.fields.indexOf(field)).text;
        // else if (userValue.isEmpty &&
        //     field.isMandatory &&
        //     field.defaultValue.isEmpty)
        //   controllersArray.elementAt(widget.fields.indexOf(field)).text =
        //       'Error';
      });

      //get signature if needed
      Uint8List imagedata;
      if (widget.fields
          .where((element) => element.type == FieldType.Signature)
          .isNotEmpty)
        imagedata = await Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => SignatureHelper()));
      //compose pdf
      String reportPath = await PdfHelper.createPdf(
        fields: widget.fields,
        instanceId: widget.instance.serial,
        instrumentId: widget.instance.instrumentId,
        pdfPath: downloadedPdfPath,
        siteName: FirebaseFirestoreProvider.getSiteById(widget.siteId).name,
        signature: imagedata,
      );

      //display result
      bool approved = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PDFScreen(
          viewOnly: true,
          approveMode: true,
          pathPDF: reportPath,
        ),
      ));

      if (approved) {
        //submit file
        String uploadedReport = await FirebaseStorageProvider.uploadFile(
            File(reportPath),
            FirebasePaths.instanceReportPath(
                widget.instance.instrumentId, widget.instance.serial));

        Report report = Report(
          timestampClose: DateTime.now().millisecondsSinceEpoch,
          index: widget.reportIndex,
          creatorId: Authentication().userEmail,
          fields: widget.fields,
          instanceId: widget.instance.serial,
          instrumentId: widget.instance.instrumentId,
          reportId: widget.reportId,
          reportName: basenameWithoutExtension(widget.pdfId),
          status: 'Closed',
          siteId: widget.siteId,
        );
        //upload fields
        var result = await FirebaseFirestoreCloudFunctions.uploadInstanceReport(
          report: report,
          reportFilePath: uploadedReport,
          reportId: widget.reportId,
        );
        setState(() {
          _loading = false;
        });
        if (result.data["status"] == "success") {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Uploaded seccessfuly')));
        }
        Navigator.of(context).pop();
      } else {
        setState(() {
          _loading = false;
        });
      }
    } catch (e, s) {
      Applogger.consoleLog(MessegeType.error, "Failed filling form\n$e\n$s");
      // Navigator.of(context).pop(false); //formFilled = false

    }
  }

  Future<void> _submit(BuildContext context) async {
    setState(() {
      _loading = true;
    });

    //update default values
    widget.fields
        .where((field) =>
            field.type == FieldType.Text || field.type == FieldType.Num)
        .forEach((field) {
      if (controllersArray
          .elementAt(widget.fields.indexOf(field))
          .text
          .isNotEmpty)
        field.defaultValue =
            controllersArray.elementAt(widget.fields.indexOf(field)).text;
    });

    Report report = Report(
        timestampClose: DateTime.now().millisecondsSinceEpoch,
        index: widget.reportIndex,
        creatorId: Authentication().userEmail,
        fields: widget.fields,
        instanceId: widget.instance.serial,
        instrumentId: widget.instance.instrumentId,
        reportId: widget.reportId,
        reportName: basenameWithoutExtension(widget.pdfId),
        status: 'Closed',
        siteId: widget.siteId);
    //upload fields
    var result = await FirebaseFirestoreCloudFunctions.uploadInstanceReport(
      report: report,
      reportId: widget.reportId,
    );
    setState(() {
      _loading = false;
    });
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
