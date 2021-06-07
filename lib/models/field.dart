import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamshare/providers/consts.dart';

class Field {
  final FieldType type;
  static final double minWidth = 10;
  static final double minHeight = 10;
  static final double defWidth = 50;
  static final double defHeight = 30;

  String defaultValue;
  final int index;
  String hint;
  final int page;
  Offset offset;
  Size size;

  String regexp;
  String prefix;
  String suffix;
  bool isMandatory;

  Field(this.type,
      {this.index,
      this.hint,
      this.regexp = '',
      this.prefix,
      this.defaultValue = '',
      this.suffix = '',
      this.page,
      this.offset,
      this.size,
      this.isMandatory});

  set setSize(Offset o) {
    Size _tmp = this.size + o;
    if (_tmp.width > minWidth && _tmp.height > minHeight)
      this.size = _tmp;
    else {
      if (_tmp.width < minWidth) this.size = Size(minWidth, this.size.height);
      if (_tmp.height < minHeight) this.size = Size(this.size.width, minHeight);
    }
  }

  Field.basic(
      {this.type, this.index, this.page, Offset initialPos, Size size}) {
    this.hint = "";

    this.regexp = "";
    this.prefix = "";
    this.defaultValue = "";
    this.suffix = "";
    this.offset =
        Offset(initialPos.dx, initialPos.dy); // center around click point
    this.size = Size(size == null ? defWidth : size.width,
        size == null ? defHeight : size.height);
    this.isMandatory = false;
  }
  Field.checkbox(
      {this.type, this.index, this.page, Offset initialPos, Size size}) {
    this.hint = "";

    this.regexp = "";
    this.prefix = "";
    this.defaultValue = "";
    this.suffix = "";
    this.offset =
        Offset(initialPos.dx, initialPos.dy); // center around click point
    this.size = Size(size == null ? defHeight : size.height,
        size == null ? defHeight : size.height);
    this.isMandatory = false;
  }

  Field.fromJson(Map<String, dynamic> data)
      : type = FieldType.values[data["type"]] ?? FieldType.Text,
        defaultValue = data['defaultValue'],
        index = data['index'],
        hint = data['hint'] ?? '',
        page = data['page'],
        offset = Offset(data['offsetX'], data['offsetY']),
        size = Size(data['sizeW'].toDouble(), data['sizeH'].toDouble()),
        regexp = data['regexp'] ?? '',
        prefix = data['prefix'] ?? '',
        suffix = data['suffix'] ?? '',
        isMandatory = data['isMandatory'];

  Map<String, dynamic> toJson() => {
        'type': type.index,
        'defaultValue': defaultValue,
        'index': index,
        'hint': hint,
        'page': page,
        'offsetX': offset.dx,
        'offsetY': offset.dy,
        'sizeW': size.width,
        'sizeH': size.height,
        'regexp': regexp,
        'prefix': prefix,
        'suffix': suffix,
        'isMandatory': isMandatory,
      };

  static Field fromFirestore(QueryDocumentSnapshot documentSnapshot) {
    return Field.fromJson(documentSnapshot.data());
  }
}
