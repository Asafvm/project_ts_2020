import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/providers/firebase_storage_provider.dart';
import 'package:teamshare/providers/team_provider.dart';
import 'package:teamshare/screens/generic_form_screen.dart';
import 'package:teamshare/widgets/entry_list_item.dart';

class InstrumentInfoScreen extends StatelessWidget {
  final Instrument instrument;
  final InstrumentInstance instance;

  InstrumentInfoScreen({this.instrument, this.instance});

  @override
  Widget build(BuildContext context) {
    final String instrumentPath = "instruments/" +
        TeamProvider().getCurrentTeam.getTeamId +
        instrument.getCodeName() +
        "/";
    var textStyleTitle = TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold);
    var textStyleContent = TextStyle(fontSize: 20.0);
    return Scaffold(
      appBar:
          AppBar(title: Text(instrument.getCodeName() + " " + instance.serial)),
      body: Column(
        children: [
          Flexible(
            //General info
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 2,
                    child: IconButton(
                      icon: Icon(Icons.add_a_photo),
                      onPressed: () {},
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          instrument.getCodeName(),
                          style: textStyleTitle,
                        ),
                        Text(
                          "Model: " + instrument.getModel(),
                          style: textStyleContent,
                        ),
                        Text(
                          "Serial: " + instance.serial,
                          style: textStyleContent,
                        ),
                        Text(
                          "Currently at: ",
                          style: textStyleContent,
                        ),
                        Text(
                          "Next: ",
                          style: textStyleContent,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Flexible(
            //log and forms
            flex: 7,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
              child: DefaultTabController(
                initialIndex: 0,
                length: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    tabInstrument, //defined in consts
                    Expanded(
                      child: TabBarView(
                        children: [
                          Container(
                            //log
                            child: ListView.builder(
                              itemCount: instance.entries.length,
                              itemBuilder: (context, index) {
                                return EntryListItem(
                                    instance.entries.elementAt(index));
                              },
                            ),
                          ),
                          Container(
                            //forms
                            child: StreamBuilder<List<DocumentSnapshot>>(
                              stream: FirebaseFirestore.instance
                                  .collection(
                                      "teams/${TeamProvider().getCurrentTeam.getTeamId}/instruments/${instrument.getCodeName()}/reports")
                                  .snapshots()
                                  .map((list) => list.docs),
                              builder: (context, snapshot) {
                                if (snapshot == null || snapshot.data == null) {
                                  return Container();
                                } else {
                                  int items = snapshot
                                      .data.length; //for height calculation
                                  return AnimatedContainer(
                                    height: 50.0,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemBuilder: (ctx, index) => ListTile(
                                        leading: Icon(Icons.picture_as_pdf),
                                        title: Text(snapshot.data[index].id),
                                        trailing: FittedBox(
                                          child: FlatButton(
                                            color:
                                                Theme.of(context).primaryColor,
                                            onPressed: () async {
                                              String downloadedPdfPath =
                                                  await FirebaseStorageProvider
                                                      .downloadFile(
                                                          '$instrumentPath/${snapshot.data[index].id}');
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      GenericFormScreen(
                                                    fields: snapshot.data[index]
                                                        .data(),
                                                    pdfPath: downloadedPdfPath,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              "Create",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                      itemCount: items,
                                    ),
                                    duration: Duration(milliseconds: 300),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
