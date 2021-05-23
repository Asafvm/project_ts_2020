import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/part.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/widgets/forms/add_part_form.dart';
import 'package:teamshare/widgets/list_items/part_list_item.dart';

class AdminPartScreen extends StatefulWidget {
  @override
  _AdminPartScreenState createState() => _AdminPartScreenState();
}

class _AdminPartScreenState extends State<AdminPartScreen> {
  bool _stocktaking = false;

  @override
  Widget build(BuildContext context) {
    // List<MapEntry<String, dynamic>> _storageList =
    //     Provider.of<List<MapEntry<String, dynamic>>>(context);
    List<Part> _partList = Provider.of<List<Part>>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Parts"),
        actions: [
          IconButton(
            icon: Icon(Icons.storage),
            onPressed: () {
              setState(() {
                _stocktaking = !_stocktaking;
              });
            },
            tooltip: 'Stocktaking',
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () => _openAddParts(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: _partList.isEmpty
            ? Center(child: Text("You haven't registered any parts yet"))
            : ListView.builder(
                key: UniqueKey(), //new Key(Strings.randomString(20)),
                itemBuilder: (ctx, index) {
                  // Map<String, dynamic> parts =
                  //     Map<String, dynamic>.fromEntries(_storageList);

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: PartListItem(
                          part: _partList.elementAt(index),
                          key: UniqueKey(),
                        ),
                      ),
                      // if(_stocktaking)
                    ],
                  );
                },
                itemCount: _partList.length,
              ),
      ),
    );
  }

  _openAddParts(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return StreamProvider<List<Instrument>>(
            create: (context) => FirebaseFirestoreProvider.getInstruments(),
            initialData: [],
            child: AddPartForm(),
          );
        });
  }
}
