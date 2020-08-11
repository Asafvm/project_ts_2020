import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/field.dart';
import 'package:teamshare/providers/authentication.dart';
import 'package:teamshare/providers/team_provider.dart';
import 'package:teamshare/screens/instrument_list_screen.dart';
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
  Color _bgcolor = Colors.white;
  bool _selected = false;

  void _setSelected() {
    setState(() {
      _selected = !_selected;
      _bgcolor = _selected ? Theme.of(context).accentColor : Colors.white;
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
            color: _bgcolor,
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
                        String filePath = await FilePicker.getFilePath(
                            type: FileType.custom, allowedExtensions: ['pdf']);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PDFScreen(
                                filePath,
                                widget.instrument.getCodeName(),
                                widget.instrument.getCodeName(),
                                null), //documentID = Instrument document id
                          ),
                        );
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
                            ), //documentID = Instrument document id
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
            stream: Firestore.instance
                .collection(
                    "teams/${TeamProvider().getCurrentTeam.getTeamId}/Instruments/${widget.instrument.getCodeName()}/reports")
                .snapshots()
                .map((list) => list.documents),
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
                      title: Text(snapshot.data[index].documentID),
                      trailing: FittedBox(
                        child: Row(
                          children: <Widget>[
                            IconButton(
                                icon: Icon(Icons.file_upload),
                                onPressed:
                                    () {}), //TODO: replace file at storage
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PDFScreen(
                                      snapshot.data[index].documentID +
                                          ".pdf", //TODO: get file path from Instrument automaticly,
                                      widget.instrument.getCodeName(),
                                      widget.instrument.getCodeName(),
                                      snapshot.data[index].data.entries
                                          .map((e) => Field.fromJson(
                                              e.value.cast<String, dynamic>()))
                                          .toList()),
                                ),
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
}
