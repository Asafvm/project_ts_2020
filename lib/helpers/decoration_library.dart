import 'package:flutter/material.dart';

class DecorationLibrary {
  static InputDecoration inputDecoration(String label, BuildContext context) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 1,
            style: BorderStyle.solid),
      ),
    );
  }
}
