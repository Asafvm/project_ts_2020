import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/widgets/forms/add_instrument_form.dart';
import 'package:teamshare/widgets/list_items/instrument_list_item.dart';

class AdminInstrumentScreen extends StatefulWidget {
  @override
  _AdminInstrumentScreenState createState() => _AdminInstrumentScreenState();
}

class _AdminInstrumentScreenState extends State<AdminInstrumentScreen> {
  @override
  Widget build(BuildContext context) {
    List<Instrument> _instrumentList =
        Provider.of<List<Instrument>>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Instruments"),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add_to_queue,
          color: Colors.white,
        ),
        onPressed: () => _openAddInstrument(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: _instrumentList.isEmpty
            ? Center(child: Text("You haven't registered any instruments yet"))
            : ListView.builder(
                key: UniqueKey(), //new Key(Strings.randomString(20)),
                itemBuilder: (ctx, index) => InstrumentListItem(
                    Icons.computer, ctx, _instrumentList[index]),
                itemCount: _instrumentList.length,
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
