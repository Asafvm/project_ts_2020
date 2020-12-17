import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:positioned_tap_detector/positioned_tap_detector.dart';
import 'package:teamshare/models/field.dart';
import 'package:teamshare/providers/authentication.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/providers/firebase_storage_provider.dart';
import 'package:teamshare/providers/team_provider.dart';
import 'package:teamshare/widgets/add_field_form.dart';
import 'package:teamshare/widgets/custom_field.dart';
import 'package:path/path.dart' as path;

class PDFScreen extends StatefulWidget {
  final List<Field> _fields;
  final String pathPDF;
  final String instrumentID;
  final String devCode;
  PDFScreen(this.pathPDF, this.instrumentID, this.devCode, this._fields);

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
    File(widget.pathPDF).exists().catchError((e) async => {
          await showDialog(
                  context: context,
                  builder: (_) => _buildAlertDialog("Error opening file"))
              .then((_) => Navigator.of(context).pop())
        });

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
          Field f = Field.basic(
              index: _fieldIndex, page: _pageIndex, initialPos: pos.relative);
          return AddFieldForm(f);
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
        FlatButton(
          child: Text("Confirm"),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Future<void> _savePDF() async {
    print("saving");
    _updateProgress(0);
    try {
      setState(() {
        _uploading = true;
      });
      List<Map<String, dynamic>> fields = [];
      _fields.forEach((f) => fields.add(f.toJson()));
      File file = File(widget.pathPDF);

      if (file != null && Authentication().isAuth) {
        final String instrumentPath = "instruments/" +
            TeamProvider().getCurrentTeam.getTeamId +
            widget.instrumentID +
            "/";

        await FirebaseStorageProvider.uploadFile(file, instrumentPath)
            .then((val) async => {
                  _updateProgress(50),
                  await FirebaseFirestoreProvider.uploadFields(
                          fields,
                          path.basenameWithoutExtension(file.path),
                          widget.instrumentID)
                      .then((val) async => {
                            _updateProgress(100),
                            await showDialog(
                                    context: context,
                                    builder: (_) => _buildAlertDialog(
                                        "Upload completed successfuly"))
                                .then((_) => Navigator.of(context).pop())
                          })
                      .catchError((e) async => {
                            await showDialog(
                              context: context,
                              builder: (_) => _buildAlertDialog(
                                  "Upload Failed: Fields\n$e"),
                            )
                          })
                })
            .catchError((e) async => {
                  await showDialog(
                      context: context,
                      builder: (_) => _buildAlertDialog("Upload Failed: File"))
                });
      } else {
        await showDialog(
            context: context,
            builder: (_) =>
                _buildAlertDialog("Must be logged in to upload files"));
      }

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

  _updateProgress(double p) {
    setState(() {
      _progressValue = p;
    });
  }
}
