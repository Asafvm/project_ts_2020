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

  static InputDecoration searchDecoration({String hint, BuildContext context}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(Icons.search),
      hintText: '$hint',
      hintStyle: TextStyle(fontWeight: FontWeight.bold),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 1,
            style: BorderStyle.solid),
      ),
    );
  }

  static loginDecoration(
      IconData icon, String label, String hint, BuildContext context,
      [bool visible = true]) {
    return InputDecoration(
      prefixIcon: visible ? Icon(icon, color: Colors.white) : Container(),
      hintStyle: TextStyle(color: Colors.grey[500]),
      labelText: label,
      labelStyle: TextStyle(color: Colors.white),
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
