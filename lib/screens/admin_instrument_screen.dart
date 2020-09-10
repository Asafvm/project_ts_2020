import 'package:flutter/material.dart';
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/widgets/instrument_list_item.dart';
import 'package:teamshare/widgets/add_instrument_form.dart';

class AdminInstrumentScreen extends StatefulWidget {
  @override
  _AdminInstrumentScreenState createState() => _AdminInstrumentScreenState();
}

class _AdminInstrumentScreenState extends State<AdminInstrumentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Instruments"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _openAddInstrument(context))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: StreamBuilder(
          stream: FirebaseFirestoreProvider().getInstruments(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (!snapshot.hasData || snapshot.data.length == 0)
                return Center(
                    child: Text("You haven't registered any instruments yet"));
              else
                return ListView.builder(
                  key: new Key(randomString(20)),
                  itemBuilder: (ctx, index) => InstrumentListItem(
                      Icons.computer, ctx, snapshot.data.elementAt(index)),
                  itemCount: snapshot.data.length,
                );
            } else
              return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  void _openAddInstrument(BuildContext ctx) {
    showModalBottomSheet(
        enableDrag: false,
        isDismissible: true,
        context: ctx,
        builder: (_) {
          return AddInstrumentForm();
        }).whenComplete(() => setState(() {}));
  }
}
