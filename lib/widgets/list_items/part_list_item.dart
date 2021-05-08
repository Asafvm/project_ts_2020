import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/part.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/screens/part/part_info_screen.dart';

class PartListItem extends StatelessWidget {
  final Part part;

  const PartListItem({Key key, this.part}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) {
              return StreamProvider<List<Instrument>>(
                initialData: [],
                create: (context) => FirebaseFirestoreProvider.getInstruments(),
                child: PartInfoScreen(
                  part: part,
                ),
              );
            },
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(
            part.active ? Icons.computer : Icons.desktop_access_disabled,
            color: part.active ? Theme.of(context).primaryColor : Colors.grey,
          ),
        ),
        title: Text(part.getDescription()),
        subtitle: Text(part.getreference()),
      ),
    );
  }
}
