import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:teamshare/models/field.dart';
import 'package:teamshare/providers/applogger.dart';
import 'package:teamshare/providers/authentication.dart';
import 'package:teamshare/providers/consts.dart';
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
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _focalPoint = Offset(0, 0);

  @override
  void initState() {
    super.initState();

    // File(widget.pathPDF).exists().catchError((e) async => {
    //       await showDialog(
    //               context: context,
    //               builder: (_) => _buildAlertDialog("Error opening file"))
    //           .then((_) => Navigator.of(context).pop())
    //     });
    setState(() {
      if (widget.fields != null)
        _fields = List.from(widget.fields, growable: true);
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
      appBar: AppBar(
        title: Text('Creating Form'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.save), onPressed: _savePDF)
        ],
      ),
      body: _uploading
          ? Center(
              child: CircularProgressIndicator(
              valueColor: _progressColor,
              strokeWidth: 5,
              backgroundColor: Colors.grey,
              value: _progressValue,
            ))
          : Container(
              decoration: BoxDecoration(
                color: Colors.grey,
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.deferToChild,
                onDoubleTap: () {},
                onScaleStart: (details) {
                  _scale = _previousScale;
                  _focalPoint = details.localFocalPoint;
                  setState(() {});
                },
                onScaleUpdate: (details) {
                  if (_previousScale * details.scale < 1.0)
                    _scale = 1.0;
                  else
                    _scale = _previousScale * details.scale;
                  setState(() {});
                },
                onScaleEnd: (_) {
                  _previousScale = _scale;
                  setState(() {});
                },
                child: Column(
                  children: <Widget>[
                    Stack(
                      clipBehavior: Clip.hardEdge,
                      children: <Widget>[
                        AspectRatio(
                          aspectRatio: a4Width / a4Height,
                          child: PDFView(
                            key: _keyPDF,
                            filePath: widget.pathPDF,
                            defaultPage: 0,
                            //enableSwipe: true,
                            swipeHorizontal: true,
                            onPageChanged: _updateLists,
                            gestureRecognizers: Set()
                              ..add(Factory<ScaleGestureRecognizer>(() =>
                                  ScaleGestureRecognizer(
                                      kind: PointerDeviceKind.touch)
                                    ..onStart = (details) {
                                      print('Start');
                                    }
                                    ..onUpdate = (details) {
                                      print('Update');
                                    }
                                    ..onEnd = (_) {
                                      print('End');
                                    }))
                              ..add(Factory<LongPressGestureRecognizer>(
                                  () => LongPressGestureRecognizer()
                                    ..onLongPressStart = (details) {
                                      _addField(Offset(details.localPosition.dx,
                                          details.localPosition.dy));
                                    })),
                            onRender: (_pages) {
                              setState(() {
                                // pages = _pages;
                                // isReady = true;
                              });
                            },
                            onError: (err) {
                              Applogger.consoleLog(
                                  MessegeType.error, 'PDF Error::$err');
                            },
                          ),
                        ),
                        // DragTarget<CustomField>(
                        //   builder: (BuildContext context,
                        //       List<CustomField> candidateData,
                        //       List<dynamic> rejectedData) {
                        //     return Container();
                        //   },
                        // ),
                        if (pdfBox != null)
                          for (Field i
                              in _fieldsInPage) //put each field in a customfield wrapper
                            CustomField(i, MediaQuery.of(context), _editField,
                                pdfBox.size, _scale, _focalPoint),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _addField(Offset pos) async {
    final Field f = await showModalBottomSheet(
        context: context,
        builder: (_) {
          return AddFieldForm(
            Field.basic(
              index: _fieldIndex,
              page: _pageIndex,
              initialPos: Offset(pos.dx / pdfBox.size.width,
                  pos.dy / pdfBox.size.height), //save offset as ratio
            ),
          );
        });
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
      List<Field> fields = [];
      _fields.forEach((f) => fields.add(f));
      File file = File(widget.pathPDF);

      if (file != null && Authentication().isAuth) {
        final String instrumentPath = TeamProvider().getCurrentTeam.getTeamId +
            "/instruments/" +
            widget.instrumentID +
            "/";
        if (!widget.onlyFields) {
          Applogger.consoleLog(MessegeType.info, "Saving File");
          await FirebaseStorageProvider.uploadFile(file, instrumentPath)
              .catchError((e) => e.toString());
        }

        _updateProgress(50);
        Applogger.consoleLog(MessegeType.info, "Saving Fields");
        await FirebaseFirestoreCloudFunctions.uploadFields(fields,
                path.basenameWithoutExtension(file.path), widget.instrumentID)
            .catchError((_) => {
                  _showDialog("Failed to upload fields"),
                });
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
