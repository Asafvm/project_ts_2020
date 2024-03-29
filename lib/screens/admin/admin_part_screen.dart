import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:teamshare/widgets/searchbar.dart';

class AdminPartScreen extends StatefulWidget {
  @override
  _AdminPartScreenState createState() => _AdminPartScreenState();
}

class _AdminPartScreenState extends State<AdminPartScreen> {
  bool _loading = false;
  bool _stockTaking = false;

  String _filter = '';

  @override
  Widget build(BuildContext context) {
    List<Part> _catalogParts = Provider.of<List<Part>>(context)
        .where((part) =>
            part.description.contains(_filter) ||
            part.reference.contains(_filter))
        .toList();

    return StreamProvider<List<MapEntry<String, dynamic>>>.value(
      value: FirebaseFirestoreProvider.getInventoryParts('$storage'),
      initialData: [],
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: Icon(_stockTaking ? Icons.lock_open : Icons.lock_outline),
              onPressed: () {
                setState(() {
                  _stockTaking = !_stockTaking;
                });
              },
            )
          ],
          title: Text("Manage Parts"),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () => _openAddParts(context),
        ),
        body: Column(
          children: [
            SearchBar(
              label: 'Search',
              onChange: (value) {
                setState(() {
                  _filter = value;
                });
              },
            ),
            Expanded(
              child: InfoCube(
                title: '$storage',
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: _catalogParts.isEmpty
                      ? Center(
                          child: Text("You haven't registered any parts yet"))
                      : ListView.builder(
                          shrinkWrap: true,
                          key: UniqueKey(), //new Key(Strings.randomString(20)),
                          itemBuilder: (ctx, index) {
                            Part catalogPart = _catalogParts.elementAt(index);

                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  flex: 8,
                                  child: PartListItem(
                                    part: catalogPart,
                                    key: UniqueKey(),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child:
                                      Consumer<List<MapEntry<String, dynamic>>>(
                                    builder: (context, value, child) {
                                      Map<String, dynamic> storageParts =
                                          Map<String, dynamic>.fromEntries(
                                              value);

                                      return OutlinedButton(
                                        style: outlinedButtonStyle,
                                        onPressed: _stockTaking
                                            ? () {
                                                final controller =
                                                    TextEditingController();
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      StatefulBuilder(builder:
                                                          (context, setState) {
                                                    return AlertDialog(
                                                      title: Text(
                                                          'Set amount\n${catalogPart.description}'),
                                                      content: TextField(
                                                        inputFormatters: <
                                                            TextInputFormatter>[
                                                          FilteringTextInputFormatter
                                                              .allow(RegExp(
                                                                  r'^[0-9]+'))
                                                        ],
                                                        controller: controller,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        decoration:
                                                            DecorationLibrary
                                                                .inputDecoration(
                                                                    'Amount',
                                                                    context),
                                                      ),
                                                      actions: [
                                                        OutlinedButton(
                                                            style:
                                                                outlinedButtonStyle,
                                                            onPressed:
                                                                () async {
                                                              if (controller
                                                                  .text.isEmpty)
                                                                return;
                                                              setState(() {
                                                                _loading = true;
                                                              });
                                                              await FirebaseFirestoreCloudFunctions
                                                                  .transferParts(
                                                                      null,
                                                                      '$storage',
                                                                      catalogPart,
                                                                      int.parse(
                                                                          controller
                                                                              .text));
                                                              setState(() {
                                                                _loading =
                                                                    false;
                                                              });

                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: _loading
                                                                ? CircularProgressIndicator()
                                                                : Text('OK')),
                                                        OutlinedButton(
                                                            style:
                                                                outlinedButtonStyle,
                                                            onPressed: _loading
                                                                ? null
                                                                : () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                            child:
                                                                Text('Cancel'))
                                                      ],
                                                    );
                                                  }),
                                                );
                                              }
                                            : null,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 25),
                                          child: Text(
                                            storageParts[catalogPart.id] == null
                                                ? "0"
                                                : storageParts[catalogPart.id]
                                                    .toString(),
                                            style: TextStyle(
                                              color: catalogPart.mainStockMin >
                                                      0
                                                  ? storageParts[
                                                              catalogPart.id] ==
                                                          null
                                                      ? Colors.red
                                                      : catalogPart
                                                                  .mainStockMin >
                                                              storageParts[
                                                                  catalogPart
                                                                      .id]
                                                          ? Colors.red
                                                          : Colors.black
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                          itemCount: _catalogParts.length,
                        ),
                ),
              ),
            ),
          ],
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
