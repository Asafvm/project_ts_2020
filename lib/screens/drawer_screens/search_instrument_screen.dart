import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/models/site.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/widgets/list_items/instrument_instance_list_item.dart';
import 'package:teamshare/widgets/searchbar.dart';

class SearchInstrumentScreen extends StatefulWidget {
  @override
  _SearchInstrumentScreenState createState() => _SearchInstrumentScreenState();
}

class _SearchInstrumentScreenState extends State<SearchInstrumentScreen> {
  List<InstrumentInstance> filteredInstances = [];
  String _statistics = "Matches found";
  String _filter = '';

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
              SearchBar(
                label: 'Search for instruments',
                onChange: (value) {
                  setState(() {
                    _filter = value;
                  });
                },
              ),
              Text(_statistics),
              Expanded(
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
    List<String> filters = _filter.split(" ");
    filters.forEach((filter) {
      if (filter != '')
        filteredInstances = filteredInstances
            .where((element) =>
                FirebaseFirestoreProvider.getInstrumentById(
                        element.instrumentId)
                    .codeName
                    .toLowerCase()
                    .contains(filter.toLowerCase()) ||
                FirebaseFirestoreProvider.getSiteById((element.currentSiteId))
                    .name
                    .toLowerCase()
                    .contains(filter.toLowerCase()) ||
                element.serial.toLowerCase().contains(filter.toLowerCase()))
            .toList();
    });

    filteredInstances.sort((a, b) => a.instrumentId.compareTo(b.instrumentId));
    _statistics = '${filteredInstances.length} Matches Found';
  }
}
