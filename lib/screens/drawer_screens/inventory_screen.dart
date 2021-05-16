import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/helpers/decoration_library.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/part.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/widgets/list_items/part_list_item.dart';

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _searchText = ''; // = TextEditingController();
  bool _searchMode = false;
  bool _personalMode = false;
  bool _groupMode = false;
  bool _storageMode = false;

  @override
  Widget build(BuildContext context) {
    List<Part> storageParts = Provider.of<List<Part>>(context);
    List<Instrument> instruments = Provider.of<List<Instrument>>(context);
    List<String> members = Provider.of<List<String>>(context);
    List<Part> storagePartsFiltered = [];
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory'),
        actions: [
          if (_personalMode || _groupMode || _storageMode)
            IconButton(
                icon: Icon(Icons.cancel),
                onPressed: () {
                  setState(() {
                    _personalMode = false;
                    _groupMode = false;
                    _storageMode = false;
                  });
                }),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 0,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchText = value;
                          if (value.trim().isNotEmpty) {
                            _personalMode = false;
                            _groupMode = false;
                            _storageMode = false;
                            _searchMode = true;
                          } else
                            _searchMode = false;
                        });
                      },
                      decoration: DecorationLibrary.searchDecoration(
                          context: context,
                          hint: 'Quick search by description or referance'),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              //content

              child: _searchMode
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: storageParts
                          .where((part) =>
                              part.description
                                  .toLowerCase()
                                  .contains(_searchText.toLowerCase()) ||
                              part.reference
                                  .toLowerCase()
                                  .contains(_searchText.toLowerCase()))
                          .length,
                      itemBuilder: (context, index) {
                        return PartListItem(
                          part: storageParts
                              .where((part) =>
                                  part.description
                                      .toLowerCase()
                                      .contains(_searchText.toLowerCase()) ||
                                  part.reference
                                      .toLowerCase()
                                      .contains(_searchText.toLowerCase()))
                              .elementAt(index),
                          inventoryMode: true,
                        );
                      },
                    )
                  : Column(
                      children: [
                        if (!(_storageMode || _groupMode))
                          Expanded(
                            child: AnimatedContainer(
                                constraints: BoxConstraints.expand(),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 2, color: Colors.black)),
                                duration: Duration(milliseconds: 1400),
                                child: _personalMode
                                    ? StreamBuilder<List<String>>(
                                        stream: FirebaseFirestoreProvider
                                            .getPersonalParts(),
                                        initialData: [],
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            List<Part> personalParts =
                                                storageParts
                                                    .where((part) => snapshot
                                                        .data
                                                        .contains(part.id))
                                                    .toList();
                                            return ListView.builder(
                                              itemCount: personalParts.length,
                                              itemBuilder: (context, index) {
                                                return PartListItem(
                                                  part: personalParts[index],
                                                );
                                              },
                                            );
                                          }
                                          return Container();
                                        },
                                      )
                                    : IconButton(
                                        icon: Icon(
                                          Icons.person,
                                          semanticLabel: 'Personal Storage',
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _personalMode = true;
                                          });
                                        })),
                          ),
                        if (!(_storageMode || _personalMode))
                          Expanded(
                            child: AnimatedContainer(
                                duration: Duration(milliseconds: 1400),
                                constraints: BoxConstraints.expand(),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 2, color: Colors.black)),
                                child: _groupMode
                                    ? StreamBuilder<List<String>>(
                                        stream: FirebaseFirestoreProvider
                                            .getPersonalParts(),
                                        initialData: [],
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            List<String> personalParts =
                                                snapshot.data;
                                            return ListView.builder(
                                              itemCount: storageParts
                                                  .where((part) => personalParts
                                                      .contains(part.id))
                                                  .length,
                                              itemBuilder: (context, index) {
                                                return PartListItem(
                                                  part: storageParts.firstWhere(
                                                      (part) =>
                                                          part.id ==
                                                          snapshot.data[index]),
                                                );
                                              },
                                            );
                                          }
                                          return Container();
                                        },
                                      )
                                    : IconButton(
                                        icon: Icon(
                                          Icons.group,
                                          semanticLabel: 'Group Storage',
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _groupMode = true;
                                          });
                                        })),
                          ),
                        if (!(_groupMode || _personalMode))
                          Expanded(
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 1400),
                              constraints: BoxConstraints.expand(),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 2, color: Colors.black)),
                              child: _storageMode
                                  ? ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: storageParts.length,
                                      itemBuilder: (context, index) {
                                        return PartListItem(
                                          part: storageParts[index],
                                          inventoryMode: true,
                                        );
                                      },
                                    )
                                  : IconButton(
                                      icon: Icon(
                                        Icons.storage,
                                        semanticLabel: 'Storage Storage',
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _storageMode = true;
                                        });
                                      }),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
