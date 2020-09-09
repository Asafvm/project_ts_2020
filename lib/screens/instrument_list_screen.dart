import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/models/team.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/providers/team_provider.dart';
import 'package:teamshare/widgets/add_instrument_instance_form.dart';
import 'package:teamshare/widgets/instrument_instance_list_item.dart';

class InstrumentListScreen extends StatefulWidget {
  final Instrument instrument;
  InstrumentListScreen(this.instrument);

  @override
  _InstrumentListScreenState createState() => _InstrumentListScreenState();
}

class _InstrumentListScreenState extends State<InstrumentListScreen> {
  Team curTeam;
  @override
  void initState() {
    curTeam = TeamProvider().getCurrentTeam;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.instrument.getCodeName()),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _openAddInstrumentInstance(context))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: StreamBuilder<List<DocumentSnapshot>>(
          stream: FirebaseFirestoreProvider()
              .getInstrumentsInstances(widget.instrument.getCodeName()),
          builder: (context, snapshot) {
            if (snapshot == null || snapshot.data == null) {
              return Container();
            } else {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (ctx, index) => InstrumentInstanceListItem(
                  Icons.computer,
                  ctx,
                  InstrumentInstance.fromFirestore(snapshot.data[index]),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _openAddInstrumentInstance(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (_) {
          return AddInstrumentInstanceForm(widget.instrument.getCodeName());
        });
    setState(() {});
  }
}
