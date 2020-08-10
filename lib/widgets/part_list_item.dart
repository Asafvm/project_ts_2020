import 'package:flutter/material.dart';
import 'package:teamshare/models/part.dart';

class PartListItem extends StatelessWidget {
  final Part part;

  const PartListItem({Key key, this.part}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(Icons.radio_button_unchecked),
        ),
        title: Text(part.getDescription()),
        subtitle: Text(part.getreference()),
      ),
    );
  }
}
