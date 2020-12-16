import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teamshare/models/entry.dart';

class EntryListItem extends StatelessWidget {
  final Entry entry;
  const EntryListItem(this.entry);

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    return Card(
      shape: RoundedRectangleBorder(
        side:
            BorderSide(color: Colors.grey, width: 1, style: BorderStyle.solid),
      ),
      elevation: 7,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Flexible(
              fit: FlexFit.tight,
              flex: 1,
              child: Text(
                formatter.format(
                    DateTime.fromMillisecondsSinceEpoch(entry.timestamp)),
                textAlign: TextAlign.center,
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              flex: 1,
              child: Icon(Icons.info),
            ),
            Flexible(
              fit: FlexFit.tight,
              flex: 3,
              child: Text(
                entry.details,
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
