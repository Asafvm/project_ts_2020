import 'package:flutter/material.dart';

//TODO: remove this!

class CustomTextFormField extends StatelessWidget {
  final String label;
  final TextInputType keyType;
  final Function onSavedFunction;

  const CustomTextFormField(
      {Key key, this.label, this.keyType, this.onSavedFunction})
      : super(key: key);
  //final RegExp regExp;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      keyboardType: keyType,
      onSaved: onSavedFunction,
      //validator: RegExp(regExp),
    );
  }
}
