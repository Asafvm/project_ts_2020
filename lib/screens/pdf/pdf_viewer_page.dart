import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:teamshare/models/field.dart';
import 'package:teamshare/providers/applogger.dart';
import 'package:teamshare/providers/authentication.dart';
import 'package:teamshare/providers/firebase_firestore_cloud_functions.dart';
import 'package:teamshare/providers/firebase_storage_provider.dart';
import 'package:teamshare/providers/team_provider.dart';
import 'package:teamshare/widgets/forms/add_field_form.dart';
import 'package:teamshare/widgets/custom_field.dart';
import 'package:path/path.dart' as path;
//import 'package:after_layout/after_layout.dart';

class PDFScreen extends StatefulWidget {
  final List<Field> fields;
  final String pathPDF;
  final String instrumentID;
  final bool onlyFields; // upload field data only (update exisiting report)
  PDFScreen(
      {this.pathPDF,
      this.instrumentID,
      this.fields = const [],
      this.onlyFields = false});

  @override
  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  bool _uploading = false;
  double _progressValue = 0.0;
  AlwaysStoppedAnimation<Color> _progressColor;
  int _fieldIndex = 0;
  int _pageIndex = 0;
  List<Field> _fields = [];
  List<Field> _fieldsInPage = [];
  GlobalKey _keyPDF = GlobalKey();
  RenderBox pdfBox;
  Size pdfSize;
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _focalPoint = Offset(0, 0);
  PdfController _pdfController;
  static final int _initialPage = 1;
  int _actualPageNumber = _initialPage;
  int _allPagesCount = 0;

  final appbar = AppBar(
    title: Text('Creating Form'),
  );

  @override
  void initState() {
    super.initState();
    _pdfController = PdfController(
      document: PdfDocument.openFile(widget.pathPDF),
      initialPage: _initialPage,
    );
    pdfSize = Size(612, 792);
    setState(() {
      if (widget.fields != null) {
        _fields = List.from(widget.fields, growable: true);
        _fieldIndex = _fields.length;
      }
    });
    _updateLists(0, 0);

    //set function to run once after first frame
    WidgetsBinding.instance
        .addPostFrameCallback((_) => afterFirstLayout(context));
  }

  void afterFirstLayout(BuildContext context) {
    // Calling the same function "after layout" to resolve the issue.
    if (_keyPDF.currentContext != null)
      setState(() {
        pdfBox = _keyPDF.currentContext.findRenderObject() as RenderBox;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: appbar,
      floatingActionButton: FloatingActionButton(
        onPressed: _savePDF,
        child: Icon(
          Icons.save,
          color: Colors.white,
        ),
      ),
      body: _uploading
          ? CircularProgressIndicator(
              valueColor: _progressColor,
              strokeWidth: 5,
              backgroundColor: Colors.grey,
              value: _progressValue,
            )
          : AspectRatio(
              aspectRatio: pdfSize.aspectRatio,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onDoubleTap: () {},
                onLongPressStart: (deatils) => _addField(deatils.localPosition),
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: <Widget>[
                    PdfView(
                      key: _keyPDF,
                      documentLoader:
                          Center(child: CircularProgressIndicator()),
                      pageLoader: Center(child: CircularProgressIndicator()),
                      controller: _pdfController,
                      onDocumentLoaded: (document) {
                        setState(() {
                          _allPagesCount = document.pagesCount;
                        });
                      },
                      onPageChanged: (page) {
                        setState(() {
                          _actualPageNumber = page;
                        });
                        _updateLists(page, page);
                      },
                    ),
                    if (pdfBox != null)
                      for (Field field
                          in _fieldsInPage) //put each field in a customfield wrapper
                        CustomField(
                          field: field,
                          mqd: MediaQuery.of(context),
                          editFunction: _editField,
                          pdfSizeOnScreen: pdfBox.size,
                          appbarHeight: appbar.preferredSize.height,
                        ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _addField(Offset pos) async {
    final Field f = Field.basic(
      index: _fieldIndex,
      page: _pageIndex,
      initialPos: Offset(pos.dx / pdfBox.size.width,
          pos.dy / pdfBox.size.height), //save offset as ratio
    );
    if (f != null) {
      setState(() {
        _fields.add(f);
        _fieldsInPage.add(f);
        _fieldIndex++;
      });
    }
  }

  Future<void> _editField(BuildContext context, Field field) async {
    final Field f = await showModalBottomSheet(
        context: context,
        builder: (_) {
          return AddFieldForm(field);
        });
    if (f != null)
      setState(() {
        _fields.removeWhere((rm) => rm.index == f.index);
        _fields.add(f);
      });
  }

  void _updateLists(int page, _) {
    // update view when switching pages
    setState(() {
      _pageIndex = page;
      _fieldsInPage.clear();
      _fieldsInPage.addAll(_fields.where((f) => f.page == page));
    });
  }

  _buildAlertDialog(String msg) {
    return AlertDialog(
      title: Text("Status Update"),
      content: Text(msg),
      actions: <Widget>[
        TextButton(
          child: Text("Confirm"),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Future<void> _savePDF() async {
    Applogger.consoleLog(MessegeType.info, "Saving");
    _updateProgress(0);
    try {
      setState(() {
        _uploading = true;
      });
      File file = File(widget.pathPDF);

      if (file != null && Authentication().isAuth) {
        final String instrumentPath =
            '${TeamProvider().getCurrentTeam.getTeamId}/instruments/${widget.instrumentID}';
        if (!widget.onlyFields) {
          Applogger.consoleLog(MessegeType.info, "Saving File");
          await FirebaseStorageProvider.uploadFile(file, instrumentPath)
              .catchError((e) => e.toString());
        }

        _updateProgress(50);
        Applogger.consoleLog(MessegeType.info, "Saving Fields");
        var result = await FirebaseFirestoreCloudFunctions.uploadFields(_fields,
            path.basenameWithoutExtension(widget.pathPDF), widget.instrumentID);

        _updateProgress(100);
        Applogger.consoleLog(MessegeType.info, "Saving Operation Finished");

        _showDialog("Upload Completed Successfully");
      } else {
        _showDialog("Must be logged in to upload files");
      }

      setState(() {
        _uploading = false;
      });
    } catch (e) {
      setState(() {
        _showDialog("Unknown error. Please try again later\n$e");
        _uploading = false;
      });
    }
  }

  //TOOD: finish uploading
  _updateProgress(double p) {
    setState(() {
      _progressValue = p;
    });
  }

  void _showDialog(String messege) async {
    await showDialog(
            context: context, builder: (_) => _buildAlertDialog(messege))
        .then((value) => Navigator.of(context).pop());
  }
}
