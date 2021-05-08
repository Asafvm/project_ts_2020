import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/models/site.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _siteFilter = '';
  String _roomFilter = '';
  String _instrumentFilter = '';

  List<Room> _roomList;

  @override
  Widget build(BuildContext context) {
    List<Site> sites = Provider.of<List<Site>>(context);
    List<Instrument> instruments = Provider.of<List<Instrument>>(context);
    List<InstrumentInstance> instances =
        Provider.of<List<InstrumentInstance>>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Reports"),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            DropdownButton(
              hint: Text("Site"),
              items: sites
                  .map((e) => DropdownMenuItem<String>(
                        value: e.id,
                        child: Text(e.name),
                      ))
                  .toList(),
              onChanged: (value) => {
                setState(() {
                  _siteFilter = value;
                  _roomFilter = '';
                })
              },
            ),
            if (_siteFilter != '')
              StreamBuilder<List<Room>>(
                stream: FirebaseFirestoreProvider.getRooms(_siteFilter),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _roomList = snapshot.data;

                    return DropdownButton(
                      hint: Text("Room"),
                      items: snapshot.data
                          .map((room) => DropdownMenuItem<String>(
                                value: room.id,
                                child: Text(room.roomTitle),
                              ))
                          .toList(),
                      onChanged: (value) => {
                        setState(() {
                          _roomFilter = value;
                        })
                      },
                    );
                  } else
                    return Container();
                },
              ),
            DropdownButton(
              hint: Text("Instrument"),
              items: instruments
                  .map((e) => DropdownMenuItem<String>(
                        value: e.getCodeName(),
                        child: Text(e.getCodeName()),
                      ))
                  .toList(),
              onChanged: (value) {
                _instrumentFilter = value;
              },
            ),
            if (_siteFilter != '' &&
                _roomFilter != '' &&
                _instrumentFilter != '')
              DropdownButton(
                hint: Text("Serial"),
                items: instances
                    .where((element) =>
                        (element.currentRoomId == _roomFilter) &&
                        (element.currentSiteId == _siteFilter) &&
                        (element.instrumentCode == _instrumentFilter))
                    .map((e) => DropdownMenuItem<String>(
                          value: e.serial,
                          child: Text(e.serial),
                        ))
                    .toList(),
                onChanged: (value) {
                  _instrumentFilter = value;
                },
              ),
          ],
        ),
      ),
    );
  }
}
