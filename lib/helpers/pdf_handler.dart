import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pdfWidgets;
// import 'package:pdf_image_renderer/pdf_image_renderer.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart' as pdfRender;

class PdfRawImage {
  final Uint8List data;
  final Size size;

  PdfRawImage({this.data, this.size});
}

class _PdfFileHandler {
  static Future<File> getFileFromAssets(String filename) async {
    assert(filename != null);
    final byteData = await rootBundle.load(filename);
    var name = filename.split(Platform.pathSeparator).last;
    var absoluteName = '${(await getTemporaryDirectory()).path}/$name';
    final file = File(absoluteName);

    await file.writeAsBytes(byteData.buffer.asUint8List());

    return file;
  }

  static Future<List<PdfRawImage>> loadPdf(String path) async {
    var file = await pdfRender.PdfDocument.openFile(path);
    // var file = pdfRender.PdfImageRendererPdf(path: path);
    // await file.open();
    // var count = await file.getPageCount();
    int count = file.pagesCount;
    var images = List<PdfRawImage>.empty(growable: true);

    for (int i = 0; i < count; i++) {
      pdfRender.PdfPage page = await file.getPage(i + 1); // count starts from 1
      page
          .render(
            width: page.width,
            height: page.height,
          )
          .then((value) => images.add(
                PdfRawImage(
                  data: value.bytes,
                  size: Size(value.width.toDouble(), value.height.toDouble()),
                ),
              ));
      await page.close();
      //TODO: find fix for multipage
      // await file.openPage(pageIndex: i);
      // var rawImage = await file.renderPage(
      //   background: Colors.transparent,
      //   x: 0,
      //   y: 0,
      //   width: page.width,
      //   height: page.height,
      //   scale: 1.0,
      //   pageIndex: i,
      // );
      // images.add(PdfRawImage(
      //   data: rawImage,
      //   size: Size(size.width.toDouble(), size.height.toDouble()),
      // ));
    }

    return images;
  }

  static Future<File> save(pdfWidgets.Document document, String filename,
      {String directory}) async {
    final dir = directory ?? (await getExternalCacheDirectories()).first.path;
    final file = File('$dir${Platform.pathSeparator}$filename');
    return file.writeAsBytes(await document.save());
  }
}

class PdfMutablePage {
  final PdfRawImage _background;
  final List<pdfWidgets.Widget> _stackedItems;

  PdfMutablePage({PdfRawImage background})
      : _background = background,
        _stackedItems = [];

  void add({pdfWidgets.Widget item}) {
    _stackedItems.add(item);
  }

  Size get size => _background.size;

  pdfWidgets.Page build(pdfWidgets.Document document) {
    final format =
        pdf.PdfPageFormat(_background.size.width, _background.size.height);
    return pdfWidgets.Page(
        pageFormat: format,
        orientation: pdfWidgets.PageOrientation.portrait,
        build: (context) {
          return pdfWidgets.Stack(
            children: <pdfWidgets.Widget>[
              pdfWidgets.Container(
                decoration: pdfWidgets.BoxDecoration(
                  image: pdfWidgets.DecorationImage(
                    image: pdfWidgets.MemoryImage(_background.data),
                  ),
                ),
              ),
              if (_stackedItems != null) ..._stackedItems,
            ],
          );
        });
  }
}

class PdfMutableDocument {
  String _filePath;
  final List<PdfMutablePage> _pages;

  PdfMutableDocument._({List<PdfMutablePage> pages, String filePath})
      : _pages = pages ?? [],
        _filePath = filePath;

  static Future<PdfMutableDocument> asset(String assetName) async {
    var copy = await _PdfFileHandler.getFileFromAssets(assetName);
    final rawImages = await _PdfFileHandler.loadPdf(copy.path);
    final pages =
        rawImages.map((raw) => PdfMutablePage(background: raw)).toList();
    return PdfMutableDocument._(
        pages: pages, filePath: copy.uri.pathSegments.last);
  }

  static Future<PdfMutableDocument> path(String fullPath) async {
    var copy = File(fullPath); //work on a copy of the original
    final rawImages =
        await _PdfFileHandler.loadPdf(copy.path); //convert pages to images
    final pages = rawImages
        .map((raw) => PdfMutablePage(background: raw))
        .toList(); //convert images to pdf pages
    return PdfMutableDocument._(
        pages: pages, filePath: copy.uri.pathSegments.last);
  }

  void addPage(PdfMutablePage page) => _pages.add(page);

  PdfMutablePage getPage(int index) => _pages[index];

  pdfWidgets.Document build() {
    var doc = pdfWidgets.Document();
    _pages.forEach((page) => doc.addPage(page.build(doc)));
    return doc;
  }

  Future<File> save({String filename}) async {
    return _PdfFileHandler.save(build(), filename ?? _filePath);
  }
}
