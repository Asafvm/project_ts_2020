import 'package:flutter/material.dart';

class ContactListTile extends StatelessWidget {
  final text;
  ContactListTile(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextField(
          keyboardType: TextInputType.emailAddress,
        ),
        Checkbox(
          onChanged: (bool value) {},
          value: false,
        ),
      ],
    );
  }
}
