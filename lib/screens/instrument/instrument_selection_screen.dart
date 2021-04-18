import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';

class InstrumentSelectionScreen extends StatefulWidget {
  @override
  _InstrumentSelectionScreenState createState() =>
      _InstrumentSelectionScreenState();
}

class _InstrumentSelectionScreenState extends State<InstrumentSelectionScreen> {
  List<InstrumentInstance> _selectedInstruments = [];
  List<bool> _expandedItem;
  List<Instrument> _instrumentsList;
  int _oldInstrumentListLength = 0;
  List<InstrumentInstance> _instanceList;
  List<bool> _selectableList;
  int _oldSelectableListLength = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _instrumentsList = Provider.of<List<Instrument>>(context, listen: true);
    _instanceList =
        Provider.of<List<InstrumentInstance>>(context, listen: true);
    _initExpanded();
    _initSelectableList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Instruments'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _selectedInstruments.isEmpty
                ? null
                : () {
                    Navigator.of(context).pop(_selectedInstruments);
                  },
          )
        ],
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          ExpansionPanelList(
            expansionCallback: (panelIndex, isExpanded) {
              setState(() {
                _expandedItem[panelIndex] = !isExpanded;
              });
            },
            children: _instrumentsList
                .map(
                  (instrument) => ExpansionPanel(
                    isExpanded:
                        _expandedItem[_instrumentsList.indexOf(instrument)],
                    headerBuilder: (context, isExpanded) {
                      return Text(instrument.getCodeName());
                    },
                    body: ListView(
                      shrinkWrap: true,
                      children: _instanceList
                          .where((instance) =>
                              instance.instrumentCode ==
                              instrument.getCodeName())
                          .map(
                            (instance) => CheckboxListTile(
                              value: _selectableList[
                                  _instanceList.indexOf(instance)],
                              onChanged: (value) => {
                                setState(() {
                                  if (value)
                                    _selectedInstruments.add(instance);
                                  else
                                    _selectedInstruments.remove(instance);

                                  _selectableList[
                                      _instanceList.indexOf(instance)] = value;
                                })
                              },
                              title: Text(instance.serial),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  void _initExpanded() {
    if (_instrumentsList.length != _oldInstrumentListLength) {
      _oldInstrumentListLength = _instrumentsList.length;
      _expandedItem = List<bool>.filled(_instrumentsList.length, false);
    }
  }

  void _initSelectableList() {
    if (_instanceList.length != _oldSelectableListLength) {
      _selectableList = List<bool>.filled(_instanceList.length, false);
      _oldSelectableListLength = _instanceList.length;
    }
  }
}
