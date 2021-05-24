import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/helpers/decoration_library.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/part.dart';
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/providers/firebase_firestore_cloud_functions.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/screens/team/team_home_screen.dart';
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
    return StreamProvider<List<MapEntry<String, dynamic>>>.value(
      value: FirebaseFirestoreProvider.getInventoryParts('$storage'),
      initialData: [],
      child: Scaffold(
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
        body: SizedBox.expand(
          child: InfoCube(
            title: '$storage',
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: _partList.isEmpty
                  ? Center(child: Text("You haven't registered any parts yet"))
                  : ListView.builder(
                      shrinkWrap: true,
                      key: UniqueKey(), //new Key(Strings.randomString(20)),
                      itemBuilder: (ctx, index) {
                        // Map<String, dynamic> parts =
                        //     Map<String, dynamic>.fromEntries(_storageList);

                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              flex: 8,
                              child: PartListItem(
                                part: _partList.elementAt(index),
                                key: UniqueKey(),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Consumer<List<MapEntry<String, dynamic>>>(
                                builder: (context, value, child) {
                                  Map<String, dynamic> parts =
                                      Map<String, dynamic>.fromEntries(value);

                                  var res =
                                      parts[_partList.elementAt(index).id];

                                  return GestureDetector(
                                    onTap: () {
                                      final controller =
                                          TextEditingController();
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Set amount'),
                                          content: TextField(
                                            controller: controller,
                                            keyboardType: TextInputType.number,
                                            decoration: DecorationLibrary
                                                .inputDecoration(
                                                    'Amount', context),
                                          ),
                                          actions: [
                                            TextButton(
                                                onPressed: () async {
                                                  await FirebaseFirestoreCloudFunctions
                                                      .transferParts(
                                                          null,
                                                          '$storage',
                                                          _partList
                                                              .elementAt(index),
                                                          int.parse(
                                                              controller.text));

                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('OK')),
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Cancel'))
                                          ],
                                        ),
                                      );
                                    },
                                    child: Container(
                                      child: Center(
                                        child: Text(res == null
                                            ? "0"
                                            : parts[_partList
                                                    .elementAt(index)
                                                    .id
                                                    .toString()]
                                                .toString()),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
                        );
                      },
                      itemCount: _partList.length,
                    ),
            ),
          ),
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
