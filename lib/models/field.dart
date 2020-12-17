import 'dart:ui';
import 'package:flutter/foundation.dart';

class Field {
  final double _minWidth = 20;
  final double _minHeight = 20;

  String defaultValue;
  final int index;
  String hint;
  final int page;
  Offset offset;
  Size size;
  bool isText;
  String regexp;
  String prefix;
  String suffix;
  bool isMandatory;

  Field(
      {@required this.index,
      @required this.hint,
      @required this.isText,
      this.regexp,
      @required this.prefix,
      this.defaultValue,
      this.suffix,
      @required this.page,
      @required this.offset,
      @required this.size,
      @required this.isMandatory});

  set setSize(Offset o) {
    Size _tmp = this.size + o;
    if (_tmp.width > _minWidth && _tmp.height > _minHeight)
      this.size = _tmp;
    else {
      if (_tmp.width < _minWidth) this.size = Size(_minWidth, this.size.height);
      if (_tmp.height < _minHeight)
        this.size = Size(this.size.width, _minHeight);
    }
  }

  Field.basic({this.index, this.page, Offset initialPos}) {
    this.hint = "";
    this.isText = true;
    this.regexp = "";
    this.prefix = "";
    this.defaultValue = "";
    this.suffix = "";
    this.offset = initialPos;
    this.size = Size(60, 30);
    this.isMandatory = false;
  }

  Field.fromJson(Map<String, dynamic> data)
      : defaultValue = data['defaultValue'],
        index = data['index'],
        hint = data['hint'],
        page = data['page'],
        offset = Offset(data['offsetX'], data['offsetY']),
        size = Size(data['sizeW'].toDouble(), data['sizeH'].toDouble()),
        isText = data['isText'],
        regexp = data['regexp'],
        prefix = data['prefix'],
        suffix = data['suffix'],
        isMandatory = data['isMandatory'];

  Map<String, dynamic> toJson() => {
        'defaultValue': defaultValue,
        'index': index,
        'hint': hint,
        'page': page,
        'offsetX': offset.dx,
        'offsetY': offset.dy,
        'sizeW': size.width,
        'sizeH': size.height,
        'isText': isText,
        'regexp': regexp,
        'prefix': prefix,
        'suffix': suffix,
        'isMandatory': isMandatory,
      };
}
