import 'dart:ui';
import 'package:flutter/foundation.dart';

class Field {
  final double _minWidth = 20;
  final double _minHeight = 20;

  String defaultSValue;
  int defaultIValue;
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
      this.defaultIValue,
      this.defaultSValue,
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

  Map<String, dynamic> toJson() => {
        'defaultSValue': defaultSValue,
        'defaultIValue': defaultIValue,
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
