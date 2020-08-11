import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/widgets/instrument_list_item.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/widgets/add_instrument_form.dart';

class AdminInstrumentScreen extends StatefulWidget {
  @override
  _AdminInstrumentScreenState createState() => _AdminInstrumentScreenState();
}

class _AdminInstrumentScreenState extends State<AdminInstrumentScreen> {
  List<Instrument> Instruments = [];

  @override
  Widget build(BuildContext context) {
    var InstrumentList =
        Provider.of<List<Instrument>>(context, listen: true) ?? [];

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
        child: InstrumentList.length == 0
            ? Center(child: Text("You haven't registered any instruments yet"))
            : ListView.builder(
                key: new Key(randomString(20)),
                itemBuilder: (ctx, index) => InstrumentListItem(
                    Icons.computer, ctx, InstrumentList.elementAt(index)),
                itemCount: InstrumentList.length,
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
        }); //.whenComplete(() => setState(() {}));
  }
}
