import 'dart:async';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:teamshare/helpers/pdf_handler.dart';
import 'package:teamshare/models/field.dart';
import 'package:teamshare/providers/applogger.dart';
import 'package:teamshare/providers/authentication.dart';
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/providers/firebase_firestore_cloud_functions.dart';
import 'package:teamshare/helpers/firebase_paths.dart';
import 'package:teamshare/providers/firebase_storage_provider.dart';
import 'package:teamshare/widgets/forms/add_field_form.dart';
import 'package:teamshare/widgets/custom_field.dart';
import 'package:path/path.dart' as path;

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
  List<Field> _fields = [];
  // List<Field> _fieldsInPage = [];
  GlobalKey _keyPDF = GlobalKey();
  RenderBox pdfBox;
  // Size pdfSize;
  // PdfController _pdfController;
  static final int _initialPage = 1;
  int _actualPageNumber = _initialPage;

  final appbar = AppBar(
    title: Text('Creating Form'),
  );

  double _viewScaleRecorder = 1.0;
  double _viewScale = 1.0;

  bool _dataRecieved = false;
  Offset _centerOffset = Offset(0, 0);

  var _transformController = TransformationController();

  @override
  void initState() {
    super.initState();
    setState(() {
      if (widget.fields != null) {
        _fields = List.from(widget.fields, growable: true);
        _fieldIndex = _fields.length;
      }
    });
  }

  void didChangeDependencies() {
    //recored size of pdf on screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_keyPDF.currentContext != null)
        setState(() {
          pdfBox = _keyPDF.currentContext.findRenderObject() as RenderBox;
        });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: _progressColor,
                  strokeWidth: 5,
                  backgroundColor: Colors.grey,
                  value: _progressValue,
                ),
              )
            : FutureBuilder<List<PdfRawImage>>(
                future: PdfFileHandler.loadPdf(widget.pathPDF),
                initialData: [],
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data.length > 0) {
                    if (!_dataRecieved) {
                      didChangeDependencies();
                      _dataRecieved = true;
                    }
                    List<PdfRawImage> images = snapshot.data;

                    return Column(
                      children: [
                        AspectRatio(
                          aspectRatio: images.first.size.aspectRatio,
                          child: Container(
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.black)),
                            child: GestureDetector(
                              behavior: HitTestBehavior.deferToChild,
                              onLongPressStart: (details) =>
                                  _addField(details.localPosition),
                              child: InteractiveViewer(
                                maxScale: 3,
                                minScale: 1,
                                onInteractionUpdate: (details) {
                                  _viewScaleRecorder = details.scale;
                                },
                                onInteractionEnd: (details) {
                                  _viewScale = (_viewScale * _viewScaleRecorder)
                                      .clamp(1.0, 3.0)
                                      .toDouble();
                                  var vector3 = _transformController.value
                                      .getTranslation();
                                  setState(() {
                                    _centerOffset =
                                        -Offset(vector3[0], vector3[1]) /
                                            _viewScale;
                                  });
                                },
                                transformationController: _transformController,
                                child: Stack(
                                  clipBehavior: Clip.hardEdge,
                                  children: <Widget>[
                                    Image.memory(
                                      snapshot.data
                                          .elementAt(_actualPageNumber - 1)
                                          .data,
                                      key: _keyPDF,
                                    ),
                                    if (pdfBox != null)
                                      for (Field field in _fields.where((field) =>
                                          field.page ==
                                          _actualPageNumber)) //put each field in a customfield wrapper
                                        CustomField(
                                          field: field,
                                          centerOffset: _centerOffset,
                                          scale: _viewScale,
                                          mqd: MediaQuery.of(context),
                                          onClick: (Field field) async {
                                            await _editField(context, field);
                                          },
                                          pdfSizeOnScreen: pdfBox.size,
                                          appbarHeight:
                                              appbar.preferredSize.height,
                                        ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              OutlinedButton.icon(
                                  style: outlinedButtonStyle,
                                  onPressed: () {
                                    if (_actualPageNumber == 1) return;
                                    if (_actualPageNumber > 1) {
                                      setState(() {
                                        _actualPageNumber--;
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.chevron_left),
                                  label: Text('Previous')),
                              Text(
                                  'Page $_actualPageNumber / ${images.length}'),
                              OutlinedButton.icon(
                                style: outlinedButtonStyle,
                                onPressed: () {
                                  if (_actualPageNumber == images.length)
                                    return;
                                  if (_actualPageNumber < images.length) {
                                    setState(() {
                                      _actualPageNumber++;
                                    });
                                  }
                                },
                                label: Text('Next'),
                                icon: Icon(Icons.chevron_right),
                              )
                            ],
                          ),
                        ),
                        Expanded(child: DragTarget(
                          builder: (context, candidateData, rejectedData) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Draggable(
                                    child: Text("Field"),
                                    feedback: Text("Field")),
                                Draggable(
                                    child: Text("Signature"),
                                    feedback: Text("Signature")),
                              ],
                            );
                          },
                        ))
                      ],
                    );
                  } else
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: _progressColor,
                        strokeWidth: 5,
                        backgroundColor: Colors.grey,
                        value: _progressValue,
                      ),
                    );
                }),
      ),
    );
  }

  Future<void> _addField(Offset pos) async {
    final Field f = Field.basic(
      index: _fieldIndex,
      page: _actualPageNumber,
      initialPos: Offset(
          (pos.dx / _viewScale + _centerOffset.dx) / pdfBox.size.width,
          (pos.dy / _viewScale + _centerOffset.dy) / pdfBox.size.height),
      //save offset as ratio
    );
    if (f != null) {
      setState(() {
        _fields.add(f);
        _fieldIndex++;
      });
    }
  }

  Future<Field> _editField(BuildContext context, Field field) async {
    // final Field f =
    return await showModalBottomSheet(
        context: context,
        builder: (_) {
          return AddFieldForm(field);
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
        if (!widget.onlyFields) {
          Applogger.consoleLog(MessegeType.info, "Saving File");
          await FirebaseStorageProvider.uploadFile(
            file,
            FirebasePaths.instrumentReportTemplatePath(widget.instrumentID),
          ).catchError((e) => e.toString());
        }

        _updateProgress(50);
        Applogger.consoleLog(MessegeType.info, "Saving Fields");
        await FirebaseFirestoreCloudFunctions.uploadFields(_fields,
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
