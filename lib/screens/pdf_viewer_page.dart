import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:positioned_tap_detector/positioned_tap_detector.dart';
import 'package:teamshare/models/field.dart';
import 'package:teamshare/widgets/add_field_form.dart';
import 'package:teamshare/widgets/custom_appbar.dart';
import 'package:teamshare/widgets/custom_field.dart';

class PDFScreen extends StatefulWidget {
  final String pathPDF;
  PDFScreen(this.pathPDF);

  @override
  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  int _fieldIndex = 0;
  int _pageIndex = 0;
  List<Field> _fields = [];
  List<Field> _fieldsInPage = [];
  Completer<PDFViewController> _controller = Completer<PDFViewController>();

  PDFViewController _pdfView;

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
      appBar: CustomAppBar('Creating Form', Icon(Icons.save), () {}),
      body: Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            flex: 9,
            child: Container(decoration: BoxDecoration(border: Border.all(width: 2,color: Colors.black)),
              child: Stack(
                children: <Widget>[
                  PositionedTapDetector(
                    behavior: HitTestBehavior.opaque,
                    onLongPress: (pos) => _addField(context, pos),
                    child: PDFView(
                      filePath: widget.pathPDF,
                      onError: (e) => print('PDF: Error!'),
                      onViewCreated: (_pdfView) => {},
                      onPageChanged: _updateLists,
                      onPageError: (e1, e2) => print('PDF: Page Error!'),
                      onRender: (e) => print('PDF: Render!'),
                    ),
                  ),

                  DragTarget<CustomField>(
                    builder: (BuildContext context,
                        List<CustomField> candidateData,
                        List<dynamic> rejectedData) {
                      return Expanded(child: Container());
                    },
                  ),
                  //add rects here
                  for (Field i in _fieldsInPage)
                    CustomField(i, MediaQuery.of(context)),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch,
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
          //TODO: send required fields!
          return AddFieldForm(
            _fieldIndex,
            _pageIndex,
            pos.relative,
          );
        });
    if (f != null)
      setState(() {
        _fields.add(f);
        _fieldsInPage.add(f);
        _fieldIndex++;
      });
  }

  void _updateLists(int page, int total) {
    setState(() {
      _pageIndex = page;
      _fieldsInPage.clear();
      _fieldsInPage.addAll(_fields.where((f) => f.page == page));
    });
  }
}
