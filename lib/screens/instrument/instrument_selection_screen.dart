import 'package:flutter/material.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';

class InstrumentSelectionScreen extends StatefulWidget {
  @override
  _InstrumentSelectionScreenState createState() =>
      _InstrumentSelectionScreenState();
}

class _InstrumentSelectionScreenState extends State<InstrumentSelectionScreen> {
  List<Instrument> _selectedInstruments = [];
  List<ExpandableItem> _expandableItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Instruments'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _selectedInstruments.isEmpty ? null : () {},
          )
        ],
      ),
      body: StreamBuilder<List<Instrument>>(
        initialData: [],
        stream: FirebaseFirestoreProvider.getInstruments(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _expandableItems.clear();
            for (Instrument instrument in snapshot.data) {
              ExpandableItem temp = ExpandableItem(instrument: instrument);
              if (!_expandableItems.contains(temp)) _expandableItems.add(temp);
            }
          }
          return (_expandableItems.isNotEmpty)
              ? ListView(
                  children: [
                    ExpansionPanelList(
                      expansionCallback: (panelIndex, isExpanded) {
                        setState(() {
                          _expandableItems[panelIndex].isExpanded = !isExpanded;
                        });
                      },
                      children: [
                        for (ExpandableItem item in _expandableItems)
                          ExpansionPanel(
                            isExpanded: item.isExpanded,
                            headerBuilder: (context, isExpanded) {
                              return Text(item.instrument.getCodeName());
                            },
                            body: StreamBuilder<List<InstrumentInstance>>(
                              initialData: [],
                              stream: FirebaseFirestoreProvider
                                  .getInstrumentsInstances(
                                      item.instrument.getCodeName()),
                              builder: (context, snapshot) {
                                return (snapshot.hasData)
                                    ? ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: snapshot.data.length,
                                        itemBuilder: (context, index) {
                                          InstrumentInstance instance =
                                              snapshot.data[index];
                                          return Card(
                                            child: CheckboxListTile(
                                              controlAffinity:
                                                  ListTileControlAffinity
                                                      .platform,
                                              title: Text(instance.serial),
                                              subtitle: Text(
                                                  'Cuttently at ${instance.getCurrentLocation}'),
                                              onChanged: (bool value) {},
                                              value: false,
                                            ),
                                          );
                                        },
                                      )
                                    : CircularProgressIndicator();
                              },
                            ),
                          ),
                      ],
                    ),
                  ],
                )
              : CircularProgressIndicator();
        },
      ),
    );
  }
}

class ExpandableItem {
  bool isExpanded = false;
  final Instrument instrument;

  ExpandableItem({this.instrument});
}

class ListItem {
  bool isSelected = false;
  final InstrumentInstance instance;

  ListItem({this.instance});
}
