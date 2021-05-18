import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/models/site.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/screens/instrument/instrument_info_screen.dart';

class InstrumentInstanceListItem extends StatelessWidget {
  final Instrument instrument;
  final InstrumentInstance instance;
  InstrumentInstanceListItem({this.instrument, this.instance});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => StreamProvider<List<Site>>(
              create: (context) => FirebaseFirestoreProvider.getSites(),
              initialData: [],
              child: InstrumentInfoScreen(
                instrument: instrument,
                instance: instance,
              ),
            ),
          ),
        )
      },
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.white, width: 3),
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        color: Colors.white,
        child: ListTile(
          leading: CircleAvatar(
            child: Icon(Icons.computer),
          ),
          title: Text(instance.serial),
          subtitle: Text("Last maintenance = ???"),
        ),
      ),
    );
  }
}
