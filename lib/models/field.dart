import 'dart:ui';

import 'package:flutter/foundation.dart';

class Field {
  final double _minWidth = 20;
  final double _minHeight = 20;

  final String defaultSValue;
  final int defaultIValue;
  final int index;
  final String hint;
  final int page;
  Offset offset;
  Size size;
  final bool isText;
  final RegExp regexp;
  final String prefix;
  final String suffix;
  final bool isMandatory;

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
    else
      this.size = Size(_minWidth, _minHeight);
  }
}
