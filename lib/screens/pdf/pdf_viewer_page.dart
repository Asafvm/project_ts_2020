import 'dart:async';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:teamshare/helpers/pdf_handler.dart';
import 'package:teamshare/models/field.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/site.dart';
import 'package:teamshare/providers/applogger.dart';
import 'package:teamshare/providers/authentication.dart';
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/providers/firebase_firestore_cloud_functions.dart';
import 'package:teamshare/helpers/firebase_paths.dart';
import 'package:teamshare/providers/firebase_storage_provider.dart';
import 'package:teamshare/widgets/forms/add_field_form.dart';
import 'package:teamshare/widgets/custom_field.dart';
import 'package:path/path.dart' as path;
import 'package:vector_math/vector_math_64.dart' as vector;

class PDFScreen extends StatefulWidget {
  final bool viewOnly;
  final bool approveMode;
  final List<Field> fields;
  final String pathPDF;
  final Instrument instrument;
  final Site site;
  final String reportId; // upload field data only (update exisiting report)
  PDFScreen(
      {this.pathPDF,
      this.instrument,
      this.fields = const [],
      this.reportId,
      this.viewOnly = false,
      this.site,
      this.approveMode = false});

  @override
  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  bool _uploading = false;
  double _progressValue = 0.0;
  AlwaysStoppedAnimation<Color> _progressColor;
  int _fieldIndex = 0;
  List<Field> _fields = [];
  GlobalKey _keyPDF = GlobalKey();
  RenderBox pdfBox;
  static final int _initialPage = 1;
  int _actualPageNumber = _initialPage;

  double _viewScaleRecorder = 1.0;
  double _viewScale = 1.0;

  bool _dataRecieved = false;
  bool _dragging = false;
  Offset _centerOffset = Offset(0, 0);

  var _transformController = TransformationController();

  double _maxScale = 3.0;
  double _minScale = 1.0;

  var _boxColor;

  Widget _buildDraggable(String title, FieldType type) => Draggable(
        data: {'index': -1},
        dragAnchor: DragAnchor.pointer,
        onDragEnd: (details) => _addField(
            details.offset - Offset(Field.defWidth / 2, Field.defHeight / 2),
            type),
        child: Container(
            margin: const EdgeInsets.all(8),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
            decoration: BoxDecoration(
              color: _getColor(type).withAlpha(50),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: _getColor(type)),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
            )),
        feedback: Transform(
          transform: Matrix4.translation(
              vector.Vector3(-Field.defWidth / 2, -Field.defHeight / 2, 0)),
          child: Container(
            width:
                _fields.isNotEmpty ? _fields.last.size.width : Field.defWidth,
            height:
                _fields.isNotEmpty ? _fields.last.size.height : Field.defHeight,
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
            decoration:
                BoxDecoration(border: Border.all(color: _getColor(type))),
            child: Material(
              child: Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      );

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
        appBar: AppBar(
          actions: [
            if (!widget.viewOnly)
              IconButton(
                icon: Icon(Icons.save),
                onPressed: _savePDF,
              ),
          ],
          title: Text('Creating Form'),
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

                    return StatefulBuilder(
                      builder: (context, setState) => Column(
                        children: [
                          MediaQuery.removePadding(
                            context: context,
                            removeTop: true,
                            child: AspectRatio(
                              aspectRatio: images.first.size.aspectRatio,
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: Colors.black)),
                                child: InteractiveViewer(
                                  maxScale: _maxScale,
                                  minScale: _minScale,
                                  onInteractionUpdate: (details) {
                                    //get the lastest scale
                                    _viewScaleRecorder = details.scale;
                                  },
                                  onInteractionEnd: (details) {
                                    //calcualte relative scale
                                    _viewScale =
                                        (_viewScale * _viewScaleRecorder)
                                            .clamp(_minScale, _maxScale)
                                            .toDouble();
                                    //find the offset
                                    var vector3 = _transformController.value
                                        .getTranslation();
                                    setState(() {
                                      _centerOffset =
                                          -Offset(vector3[0], vector3[1]) /
                                              _viewScale;
                                    });
                                  },
                                  transformationController:
                                      _transformController,
                                  child: DragTarget(
                                    onWillAccept: (data) => true,
                                    builder: (context, candidateData,
                                            rejectedData) =>
                                        Stack(
                                      clipBehavior: Clip.hardEdge,
                                      children: <Widget>[
                                        Image.memory(
                                          snapshot.data
                                              .elementAt(_actualPageNumber - 1)
                                              .data,
                                          key: _keyPDF,
                                        ),
                                        if (pdfBox != null)
                                          for (Field field in _fields.where(
                                              (field) =>
                                                  field.page ==
                                                  _actualPageNumber)) //put each field in a customfield wrapper
                                            CustomField(
                                                color: _getColor(field.type),
                                                field: field,
                                                centerOffset: _centerOffset,
                                                scale: _viewScale,
                                                onClick: (Field field) async {
                                                  await _editField(
                                                      context, field);
                                                  setState(() {});
                                                },
                                                onDrag: (Field field,
                                                    Offset dragDetails) {
                                                  setState(() {
                                                    _dragging = false;
                                                    field.offset =
                                                        calculateFieldOffset(
                                                            dragDetails,
                                                            field.size);
                                                  });
                                                },
                                                onDragUpdate: (details) {
                                                  setState(() {
                                                    _dragging = true;
                                                  });
                                                },
                                                pdfSizeOnScreen: pdfBox.size,
                                                appbarHeight: AppBar()
                                                    .preferredSize
                                                    .height),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: _dragging
                                ? Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(), color: _boxColor),
                                    child: DragTarget(onAccept: (data) {
                                      setState(() {
                                        if (data['index'] != -1)
                                          _fields.removeWhere((element) =>
                                              element.index == data['index']);
                                        _boxColor = null;
                                      });
                                    }, onMove: (details) {
                                      setState(() {
                                        _boxColor = Colors.orangeAccent;
                                      });
                                    }, onLeave: (data) {
                                      setState(() {
                                        _boxColor = null;
                                      });
                                    }, builder:
                                        (context, candidateData, rejectedData) {
                                      return Center(
                                        child: Icon(Icons.delete),
                                      );
                                    }),
                                  )
                                : Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            color: _boxColor,
                                            border: Border(
                                                bottom: BorderSide(),
                                                left: BorderSide(),
                                                right: BorderSide())),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            OutlinedButton.icon(
                                                style: outlinedButtonStyle,
                                                onPressed:
                                                    _actualPageNumber == 1
                                                        ? null
                                                        : () {
                                                            if (_actualPageNumber >
                                                                1) {
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
                                              onPressed: _actualPageNumber ==
                                                      images.length
                                                  ? null
                                                  : () {
                                                      if (_actualPageNumber <
                                                          images.length) {
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
                                      if (!widget.viewOnly)
                                        Expanded(
                                          child: GridView.count(
                                            crossAxisCount: 3,
                                            physics: BouncingScrollPhysics(),
                                            childAspectRatio: 2 / 1,
                                            shrinkWrap: true,
                                            mainAxisSpacing: 3,
                                            crossAxisSpacing: 15,
                                            children: [
                                              _buildDraggable(
                                                  'Text', FieldType.Text),
                                              _buildDraggable(
                                                  '123', FieldType.Num),
                                              _buildDraggable(
                                                  'Date', FieldType.Date),
                                              _buildDraggable('Signature',
                                                  FieldType.Signature),
                                              _buildDraggable(
                                                  'Checkbox', FieldType.Check),
                                              // if (widget.site != null)
                                              //   _buildDraggable('Site', FieldType.Text),
                                              // if (widget.instrument != null)
                                              //   _buildDraggable(
                                              //       'Instrument', FieldType.Text)
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                          ),
                          if (widget.approveMode)
                            Expanded(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: Container(
                                    color: Colors.lightGreen,
                                    child: IconButton(
                                      color: Colors.white,
                                      icon: Icon(Icons.check_circle_rounded),
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    color: Colors.redAccent,
                                    child: IconButton(
                                      color: Colors.white,
                                      icon: Icon(Icons.cancel),
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                    ),
                                  ),
                                ),
                              ],
                            ))
                        ],
                      ),
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

  Future<void> _addField(Offset pos, FieldType type) async {
    Field f;
    switch (type) {
      case FieldType.Text:
        f = Field.basic(
          type: type,
          index: _fieldIndex,
          page: _actualPageNumber,
          initialPos: calculateFieldOffset(
              pos, _fields.isNotEmpty ? _fields.last.size : null),
          size: _fields.isNotEmpty
              ? _fields.last.size
              : null, //keep same size from the last field
        );
        break;
      case FieldType.Num:
        f = Field.basic(
          type: type,
          index: _fieldIndex,
          page: _actualPageNumber,
          initialPos: calculateFieldOffset(
              pos, _fields.isNotEmpty ? _fields.last.size : null),
          size: _fields.isNotEmpty
              ? _fields.last.size
              : null, //keep same size from the last field
        );
        break;
      case FieldType.Date:
        f = Field.basic(
          hint: "Date",
          type: type,
          index: _fieldIndex,
          page: _actualPageNumber,
          initialPos: calculateFieldOffset(
              pos, _fields.isNotEmpty ? _fields.last.size : null),
          size: _fields.isNotEmpty
              ? _fields.last.size
              : null, //keep same size from the last field
        );
        break;
      case FieldType.Check:
        f = Field.checkbox(
          type: type,
          index: _fieldIndex,
          page: _actualPageNumber,
          initialPos: calculateFieldOffset(pos),
          size: _fields.isNotEmpty
              ? _fields.last.size
              : null, //keep same size from the last field
        );
        break;
      case FieldType.Signature:
        f = Field.basic(
          hint: "Signature",
          type: type,
          index: _fieldIndex,
          page: _actualPageNumber,
          initialPos: calculateFieldOffset(
              pos, _fields.isNotEmpty ? _fields.last.size : null),
          size: _fields.isNotEmpty
              ? _fields.last.size
              : null, //keep same size from the last field
        );
        break;
    }

    if (f != null) {
      setState(() {
        _fields.add(f);
        _fieldIndex++;
      });
    }
  }

  Offset calculateFieldOffset(Offset pos, [Size size]) {
    MediaQueryData mqd = MediaQuery.of(context);

    double topOffset = mqd.viewInsets.top +
        mqd.viewPadding.top +
        AppBar().preferredSize.height;

    Offset test = Offset(
        ((pos.dx - mqd.viewInsets.left - mqd.viewPadding.left) / _viewScale +
                _centerOffset.dx) /
            pdfBox.size.width,
        ((pos.dy - topOffset) / _viewScale + _centerOffset.dy) /
            pdfBox.size.height);
    double dx = test.dx.clamp(
        0.0,
        size != null
            ? (pdfBox.size.width - size.width) / pdfBox.size.width
            : (pdfBox.size.width - Field.defWidth) / pdfBox.size.width);
    double dy = test.dy.clamp(
        0.0,
        size != null
            ? ((pdfBox.size.height - size.height) / (pdfBox.size.height))
                .toDouble()
            : ((pdfBox.size.height - Field.defHeight) / (pdfBox.size.height))
                .toDouble());

    return Offset(dx, dy);
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
    if (_fields.where((element) => element.hint.isEmpty).length > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Some fields were not filled properly")));
      return;
    }
    _updateProgress(0);
    try {
      setState(() {
        _uploading = true;
      });
      File file = File(widget.pathPDF);
      if (file != null && Authentication().isAuth) {
        String fileName = path.basenameWithoutExtension(file.path);

        if (!fileNameRegExp.hasMatch(fileName)) {
          bool validInput = false;
          final textedit = TextEditingController();
          textedit.text = path.basenameWithoutExtension(file.path);
          fileName = await showDialog<String>(
            barrierDismissible: false,
            context: context,
            builder: (context) => StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                title: Text('Illegal file name'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        'File name must contain letters and numbers only\nPlease corrent the file name'),
                    TextField(
                      controller: textedit,
                      maxLines: 2,
                      onChanged: (value) {
                        setState(() {
                          validInput = fileNameRegExp.hasMatch(value);
                        });
                      },
                    ),
                  ],
                ),
                actions: [
                  OutlinedButton(
                      onPressed: validInput
                          ? () => Navigator.of(context).pop(textedit.text)
                          : null,
                      child: Text('OK'))
                ],
              ),
            ),
          );
        }

        if (widget.reportId == null) {
          Applogger.consoleLog(MessegeType.info, "Saving File");
          await FirebaseStorageProvider.uploadFile(
                  file,
                  FirebasePaths.instrumentReportTemplatePath(
                      widget.instrument.id),
                  fileName)
              .catchError((e) => e.toString());
        }

        _updateProgress(50);
        Applogger.consoleLog(MessegeType.info, "Saving Fields");
        await FirebaseFirestoreCloudFunctions.uploadFields(
            _fields, fileName, widget.instrument.id, widget.reportId);

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

  _getColor(FieldType type) {
    switch (type) {
      case FieldType.Text:
        return Colors.green;
        break;
      case FieldType.Num:
        return Colors.green;
        break;
      case FieldType.Date:
        return Colors.orange;
        break;
      case FieldType.Check:
        return Colors.yellow;
        break;
      case FieldType.Signature:
        return Colors.blue;
        break;

      default:
        return Colors.green;
    }
  }
}
