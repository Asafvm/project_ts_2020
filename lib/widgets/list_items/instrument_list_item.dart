import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/field.dart';
import 'package:teamshare/providers/authentication.dart';
import 'package:teamshare/providers/firebase_storage_provider.dart';
import 'package:teamshare/providers/team_provider.dart';
import 'package:teamshare/screens/instrument/instrument_list_screen.dart';
import 'package:teamshare/screens/pdf_viewer_page.dart';

class InstrumentListItem extends StatefulWidget {
  final IconData icon;
  final BuildContext ctx;
  final Instrument instrument;
  InstrumentListItem(this.icon, this.ctx, this.instrument);

  @override
  _InstrumentListItemState createState() => _InstrumentListItemState();
}

class _InstrumentListItemState extends State<InstrumentListItem> {
  bool _selected = false;
  Color _bgDefaultColor = Colors.white;
  void _setSelected() {
    setState(() {
      _selected = !_selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        GestureDetector(
          onTap: _setSelected,
          child: Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: _selected
                      ? Theme.of(context).primaryColor
                      : _bgDefaultColor,
                  width: 3),
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            color: _bgDefaultColor,
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(widget.icon),
              ),
              title: Text(widget.instrument.getCodeName()),
              subtitle: Text(widget.instrument.getReference()),
              trailing: FittedBox(
                child: Row(
                  //buttons
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.picture_as_pdf),
                      tooltip: 'Add new form',
                      onPressed: () async {
                        FilePickerResult result =
                            await FilePicker.platform.pickFiles(
                          allowMultiple: false,
                          type: FileType.custom,
                          allowedExtensions: ['pdf'],
                        );

                        if (result != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PDFScreen(
                                pathPDF: result.paths.first,
                                instrumentID: widget.instrument.getCodeName(),
                              ),
                            ), //documentID = Instrument document id
                          );
                        }
                      },
                    ),
                    IconButton(
                      tooltip: 'Show All',
                      icon: Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InstrumentListScreen(
                              widget.instrument,
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ),

        //list of related reports for selected Instrument
        if (Authentication().isAuth)
          StreamBuilder<List<DocumentSnapshot>>(
            //list of files related to instrument
            stream: FirebaseFirestore.instance
                .collection(
                    "teams/${TeamProvider().getCurrentTeam.getTeamId}/instruments/${widget.instrument.getCodeName()}/reports")
                .snapshots()
                .map((list) => list.docs),
            builder: (context, snapshot) {
              if (snapshot == null || snapshot.data == null) {
                return Container();
              } else {
                int items = snapshot.data.length; //for height calculation
                return AnimatedContainer(
                  height:
                      _selected ? items * 50.0 : 0, //50 = height of listtile
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (ctx, index) => ListTile(
                      leading: Icon(Icons.picture_as_pdf),
                      title: Text(snapshot.data[index].id),
                      trailing: FittedBox(
                        child: Row(
                          children: <Widget>[
                            // IconButton(
                            //     icon: Icon(Icons.file_upload),
                            //     onPressed:
                            //         () {}), //TODO: replace file at storage
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _openPDF(
                                snapshot.data[index].id,
                                snapshot.data[index]
                                    .data()
                                    .entries
                                    .map((e) => Field.fromJson(
                                        e.value.cast<String, dynamic>()))
                                    .toList(),
                              ),
                            ),
                          ],
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
      ],
    );
  }

  _openPDF(String pdf, List<Field> fields) async {
    final String instrumentPath = "instruments/" +
        TeamProvider().getCurrentTeam.getTeamId +
        widget.instrument.getCodeName() +
        "/";
    String path =
        await FirebaseStorageProvider.downloadFile('$instrumentPath/$pdf');
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFScreen(
            pathPDF: path,
            fields: fields,
            instrumentID: widget.instrument.getCodeName(),
            onlyFields: true,
          ),
        ));
  }
}