import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/models/site.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/widgets/list_items/instrument_instance_list_item.dart';

class SearchInstrumentScreen extends StatefulWidget {
  @override
  _SearchInstrumentScreenState createState() => _SearchInstrumentScreenState();
}

class _SearchInstrumentScreenState extends State<SearchInstrumentScreen> {
  String _siteFilter = '';
  String _roomFilter = '';
  String _instrumentFilter = '';

  List<Room> _roomList;

  String _selectedSite;
  String _selectedRoom;
  String _selectedInstrument;

  String _statistics = "Matches found";
  List<InstrumentInstance> filteredInstances = [];

  @override
  void initState() {
    _siteFilter = '';
    _roomFilter = '';
    _instrumentFilter = '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // instances = Provider.of<List<InstrumentInstance>>(context);
    return MultiProvider(
      providers: [
        StreamProvider<List<Site>>.value(
          value: FirebaseFirestoreProvider.getSites(),
          initialData: [],
        ),
        StreamProvider<List<Instrument>>.value(
            value: FirebaseFirestoreProvider.getInstruments(), initialData: []),
        StreamProvider<List<InstrumentInstance>>.value(
            value: FirebaseFirestoreProvider.getAllInstrumentsInstances(),
            initialData: [])
      ],
      child: Consumer3<List<Site>, List<Instrument>, List<InstrumentInstance>>(
        builder: (context, sites, instruments, instances, child) {
          _filterInstanceList(instances);
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(
                flex: 1,
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButton(
                        hint: Text(_selectedSite ?? "Site"),
                        items: sites
                            .map((e) => DropdownMenuItem<String>(
                                  value: e.id,
                                  child: Text(e.name),
                                ))
                            .toList(),
                        onChanged: (value) => {
                          setState(() {
                            _selectedSite = sites
                                .where((element) => element.id == value)
                                .first
                                .name;
                            _siteFilter = value;
                            _roomFilter = '';
                          })
                        },
                      ),
                    ),
                    if (_siteFilter != '')
                      Expanded(
                        child: StreamBuilder<List<Room>>(
                          stream:
                              FirebaseFirestoreProvider.getRooms(_siteFilter),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              _roomList = snapshot.data;

                              return DropdownButton(
                                hint: Text(_selectedRoom ?? "Room"),
                                items: snapshot.data
                                    .map((room) => DropdownMenuItem<String>(
                                          value: room.id,
                                          child: Text(room.roomTitle),
                                        ))
                                    .toList(),
                                onChanged: (value) => {
                                  setState(() {
                                    _selectedRoom = _roomList
                                        .where((element) => element.id == value)
                                        .first
                                        .roomTitle;
                                    _roomFilter = value;
                                    _instrumentFilter = '';
                                  })
                                },
                              );
                            } else
                              return Container();
                          },
                        ),
                      ),
                    if (_siteFilter != '' && _roomFilter != '')
                      Expanded(
                        child: DropdownButton(
                          hint: Text(_selectedInstrument ?? "Instrument"),
                          items: instruments
                              .map((e) => DropdownMenuItem<String>(
                                    value: e.getCodeName(),
                                    child: Text(e.getCodeName()),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            _selectedInstrument = instruments
                                .where((element) => element.id == value)
                                .first
                                .codeName;
                            _instrumentFilter = value;
                          },
                        ),
                      ),
                    if (_siteFilter != '' &&
                        _roomFilter != '' &&
                        _instrumentFilter != '')
                      Expanded(
                        child: DropdownButton(
                          hint: Text("Serial"),
                          items: instances
                              .where((element) =>
                                  (element.currentRoomId == _roomFilter) &&
                                  (element.currentSiteId == _siteFilter) &&
                                  (element.instrumentId == _instrumentFilter))
                              .map((e) => DropdownMenuItem<String>(
                                    value: e.serial,
                                    child: Text(e.serial),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            _instrumentFilter = value;
                          },
                        ),
                      ),
                  ],
                ),
              ),
              Flexible(flex: 1, child: Text(_statistics)),
              Flexible(
                flex: 8,
                child: Container(
                    child: instruments.isNotEmpty
                        ? ListView.builder(
                            itemCount: filteredInstances.length,
                            itemBuilder: (context, index) {
                              return InstrumentInstanceListItem(
                                instance: filteredInstances[index],
                                instrument: instruments.firstWhere(
                                    (instrument) =>
                                        instrument.id ==
                                        filteredInstances[index].instrumentId),
                              );
                            },
                          )
                        : Container()),
              )
            ],
          );
        },
      ),
    );
  }

  void _filterInstanceList(List<InstrumentInstance> instances) {
    filteredInstances = instances;
    if (_siteFilter != '') {
      filteredInstances = filteredInstances
          .where((element) => element.currentSiteId.contains(_siteFilter))
          .toList();
    }
    if (_roomFilter != '') {
      filteredInstances = filteredInstances
          .where((element) => element.currentRoomId == _roomFilter)
          .toList();
    }
    if (_instrumentFilter != '') {
      filteredInstances = filteredInstances
          .where((element) => element.instrumentId == _instrumentFilter)
          .toList();
    }
    _statistics = '${filteredInstances.length} Matches Found';
  }
}
