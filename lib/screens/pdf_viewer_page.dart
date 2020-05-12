import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:positioned_tap_detector/positioned_tap_detector.dart';
import 'package:teamshare/models/field.dart';
import 'package:teamshare/widgets/add_field_form.dart';
import 'package:teamshare/widgets/custom_field.dart';

class PDFScreen extends StatefulWidget {
  final List<Field> _fields;
  final String pathPDF;
  final String deviceID;
  final String devCode;
  PDFScreen(this.pathPDF, this.deviceID, this.devCode, this._fields);

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
  Completer<PDFViewController> _controller = Completer<PDFViewController>();

  @override
  void initState() {
    setState(() {
      _fields = widget._fields == null ? [] : widget._fields;
    });
    _updateLists(0, 0);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    setState(() {
      _controller = new Completer<PDFViewController>();
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
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
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  flex: 9,
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.black)),
                    child: Stack(
                      children: <Widget>[
                        PositionedTapDetector(
                          behavior: HitTestBehavior.opaque,
                          onLongPress: (pos) => _addField(context, pos),
                          child: PDFView(
                            filePath: widget.pathPDF,
                            onError: (error) {
                              print(error.toString());
                            },
                            onPageError: (page, error) {
                              print('$page: ${error.toString()}');
                            },
                            onViewCreated:
                                (PDFViewController pdfViewController) {
                              _controller.complete(pdfViewController);
                            },
                            onPageChanged: _updateLists,
                            onRender: (_pages) {
                              setState(() {
                                // pages = _pages;
                                // isReady = true;
                              });
                            },
                          ),
                        ),

                        DragTarget<CustomField>(
                          builder: (BuildContext context,
                              List<CustomField> candidateData,
                              List<dynamic> rejectedData) {
                            return Container();
                          },
                        ),
                        //add rects here
                        for (Field i in _fieldsInPage)
                          CustomField(i, MediaQuery.of(context), _editField),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FlatButton.icon(
                          onPressed: () {
                            setState(() {
                              //_pageIndex--;
                            });
                          },
                          icon: Icon(Icons.keyboard_arrow_left),
                          label: const Text('Previous')),
                      FlatButton.icon(
                          onPressed: () {
                            setState(() {
                              //_pageIndex++;
                            });
                          },
                          icon: Icon(Icons.keyboard_arrow_right),
                          label: const Text('Next')),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _addField(BuildContext context, TapPosition pos) async {
    final Field f = await showModalBottomSheet(
        context: context,
        builder: (_) {
          return AddFieldForm(_fieldIndex, _pageIndex, pos.relative);
        });
    if (f != null)
      setState(() {
        _fields.add(f);
        _fieldsInPage.add(f);
        _fieldIndex++;
      });
  }

  Future<void> _editField(BuildContext context, Field field) async {
    final Field f = await showModalBottomSheet(
        context: context,
        builder: (_) {
          return AddFieldForm.fromField(field);
        });
    if (f != null)
      setState(() {
        _fields.removeWhere((rm) => rm.index == f.index);
        _fields.add(f);
      });
  }

  void _updateLists(int page, _) {
    setState(() {
      _pageIndex = page;
      _fieldsInPage.clear();
      _fieldsInPage.addAll(_fields.where((f) => f.page == page));
    });
  }

  _buildAlertDialog(String msg) {
    return AlertDialog(
      title: Text("Upload status"),
      content: Text(msg),
      actions: <Widget>[
        FlatButton(
          child: Text("Confirm"),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Future<void> _savePDF() async {
    print("saving");
    try {
      setState(() {
        _uploading = true;
      });

      List<Map<String, dynamic>> fields = [];
      _fields.forEach((f) => fields.add(f.toJson()));
      await _uploadFile(fields);

      setState(() {
        _uploading = false;
      });
    } catch (e) {
      setState(() {
        _uploading = false;
      });
    }
  }

  //TOOD: finish uploading
  Future<void> _uploadFile(List<Map<String, dynamic>> fields) async {
    //TODO: make this a 2 part cloud functions
    _updateProgress(0);
    final File file = await File(widget.pathPDF).create();
    await FirebaseStorage.instance
        .ref()
        .child('test')
        .child(widget.devCode)
        .child(path.basenameWithoutExtension(widget.pathPDF))
        .putFile(
          file,
          StorageMetadata(
            contentLanguage: 'en',
            customMetadata: <String, String>{'activity': 'test2'},
          ),
        )
        .onComplete
        .then((value) async => {
              print('file uploaded'),
              await CloudFunctions.instance
                  .getHttpsCallable(functionName: "addDeviceReport")
                  .call(<String, dynamic>{
                    "device_id": widget.deviceID,
                    "file_path": path.basenameWithoutExtension(widget.pathPDF),
                    "fields": fields,
                  })
                  .then((_) async => {
                        print('fields uploaded'),
                        _updateProgress(100),
                        await showDialog(
                            context: context,
                            builder: (_) => _buildAlertDialog(
                                "Upload completed successfuly"))
                      })
                  .catchError(
                    (_) async => _updateProgress(
                      await showDialog(
                          context: context,
                          builder: (_) => _buildAlertDialog("Upload failed")),
                    ),
                  )
                  .whenComplete(
                      () => Navigator.of(context).pop()) //close pdf view},
            })
        .catchError((e) => print("Error uploading: " + e.toString()));
  }

  _updateProgress(double p) {
    setState(() {
      _progressValue = p;
    });
  }
}
