import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/models/part.dart';
import 'package:teamshare/providers/authentication.dart';
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/providers/firebase_firestore_cloud_functions.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/screens/team/team_home_screen.dart';
import 'package:teamshare/widgets/list_items/part_list_item.dart';
import 'package:teamshare/widgets/searchbar.dart';

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _searchText = ''; // = TextEditingController();
  bool _transfer = false;
  bool _missing = false;
  String _transferTarget = '$storage';
  int _bottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    MediaQueryData mqd = MediaQuery.of(context);
    Map<String, bool> members = Map<String, bool>.fromEntries(
        Provider.of<Iterable<MapEntry<String, bool>>>(context));
    List<Part> catalog = Provider.of<List<Part>>(context);

    Widget getTransferPartner() => InventoryWindow(
          target: '$_transferTarget',
          title: '$_transferTarget Inventory',
          partStream:
              FirebaseFirestoreProvider.getInventoryParts(_transferTarget),
          filter: _searchText,
        );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Inventory'),
        actions: [],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (value) {
          _bottomNavIndex = value;
          switch (value) {
            case 0:
              setState(() {
                _transfer = !_transfer;
                if (_transfer) {
                  _missing = false;
                  _transferTarget = _chooseTarget();
                }
              });
              break;
            case 1:
              setState(() {
                _missing = !_missing;
                if (_missing) _transfer = false;
              });
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.height),
            label: 'External Inventory',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.repeat), label: 'Show Missing')
        ],
      ),
      body: Column(
        children: [
          Container(
            height: mqd.size.height * .12,
            child: Row(
              children: [
                Expanded(
                  child: SearchBar(
                    label: 'Quick search by description or referance',
                    onChange: (value) {
                      setState(() {
                        _searchText = value;
                      });
                    },
                  ),
                ),
                if (_transfer)
                  PopupMenuButton<String>(
                    onSelected: (String value) => setState(() {
                      _transferTarget = value;
                    }),
                    icon: Icon(Icons.account_circle),
                    itemBuilder: (context) => members.keys
                        .where(
                            (element) => element != Authentication().userEmail)
                        .map((e) =>
                            PopupMenuItem<String>(value: e, child: Text(e)))
                        .toList(),
                  )
              ],
            ),
          ),
          Expanded(
            flex: _transfer ? 9 ~/ 2 : 9,
            child: _missing
                ? AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    child: InfoCube(
                      title: 'Missing Inventory',
                      child: MissingPartWindow(
                          catalog: catalog
                              .where((element) =>
                                  element.reference.contains(_searchText) ||
                                  element.description.contains(_searchText))
                              .toList()),
                    ),
                  )
                : InventoryWindow(
                    target: Authentication().userEmail,
                    title: 'My Inventory',
                    partStream: FirebaseFirestoreProvider.getInventoryParts(
                        Authentication().userEmail),
                    filter: _searchText,
                  ),
          ),
          //Expanded(
          //flex: 9 ~/ 2,
          //child:
          AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: _transfer ? mqd.size.height * .3 : 0,
              child: getTransferPartner()), //),
        ],
      ),
    );
  }

  String _chooseTarget() {
    return '$storage';
  }
}

class MissingPartWindow extends StatelessWidget {
  const MissingPartWindow({
    Key key,
    @required this.catalog,
  }) : super(key: key);

  final List<Part> catalog;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MapEntry<String, dynamic>>>(
        stream: FirebaseFirestoreProvider.getInventoryParts(
            Authentication().userEmail),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> parts =
                Map<String, dynamic>.fromEntries(snapshot.data);
            List<Part> filtered = catalog
                //filter mandatory parts
                .where((part) => part.personalStockMin > 0)
                .toList();
            return MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  Part part = filtered[index];
                  int quantity = parts[part.id] != null
                      ? (part.personalStockMin - parts[part.id])
                      : (-part.personalStockMin);
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(flex: 8, child: PartListItem(part: part)),
                      Expanded(
                        flex: 2,
                        child: Container(
                          child: Center(
                            child: Text(
                              quantity.toString(),
                              style: TextStyle(
                                  color:
                                      quantity > 0 ? Colors.orange : Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                },
                itemCount: filtered.length,
              ),
            );
          } else
            return Container();
        });
  }
}

class InventoryWindow extends StatefulWidget {
  final String title;
  final Stream partStream;
  final String target;
  final String filter;

  const InventoryWindow(
      {Key key, this.title, this.partStream, this.target, this.filter})
      : super(key: key);

  @override
  _InventoryWindowState createState() => _InventoryWindowState();
}

class _InventoryWindowState extends State<InventoryWindow> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    List<Part> catalog = Provider.of<List<Part>>(context);
    return DragTarget(
      onWillAccept: (data) {
        return widget.target !=
            data["target"]; //accept if origin and destination are different
      },
      onAccept: (data) => _inventoryChange(
          data['data'], data['target'], widget.target, data['maxCount']),
      builder: (context, candidateData, rejectedData) => InfoCube(
        title: widget.title,
        child: StreamBuilder<List<MapEntry<String, dynamic>>>(
            stream: widget.partStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Map<String, dynamic> parts =
                    Map<String, dynamic>.fromEntries(snapshot.data);
                List<Part> filtered = catalog
                    //remove non existing parts
                    .where((part) => parts.keys.contains(part.id))
                    //remove by filter
                    .where((part) =>
                        part.description
                            .toLowerCase()
                            .contains(widget.filter.toLowerCase()) ||
                        part.reference
                            .toLowerCase()
                            .contains(widget.filter.toLowerCase()))
                    //remove 0 quantity
                    .where((element) => parts[element.id] > 0)
                    .toList();
                return ListView.builder(
                  itemBuilder: (context, index) {
                    Part part = filtered[index];

                    return Draggable(
                        dragAnchor: DragAnchor.pointer,
                        maxSimultaneousDrags: 1,
                        feedback: Icon(Icons.computer),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(flex: 8, child: PartListItem(part: part)),
                            Expanded(
                              child: Container(
                                child: Center(
                                  child: Text(parts[part.id].toString()),
                                ),
                              ),
                            )
                          ],
                        ),
                        childWhenDragging: Container(
                            color: Colors.green,
                            child: PartListItem(part: part)),
                        data: {
                          'data': part,
                          'target': widget.target,
                          'maxCount': parts[part.id]
                        });
                  },
                  itemCount: filtered.length,
                );
              } else
                return Container();
            }),
      ),
    );
  }

  void _inventoryChange(
      Part part, String origin, String destination, int maxCount) {
    int partCount = 0;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text('Inventory Change'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(part.description),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                      icon: Icon(Icons.arrow_circle_down_outlined),
                      onPressed: _loading
                          ? null
                          : () {
                              setState(() {
                                if (partCount > 0) partCount--;
                              });
                            }),
                  Text(partCount.toString()),
                  IconButton(
                      icon: Icon(Icons.arrow_circle_up_outlined),
                      onPressed: _loading
                          ? null
                          : () {
                              setState(() {
                                if (partCount < maxCount) partCount++;
                              });
                            })
                ],
              ),
            ],
          ),
          actions: [
            OutlinedButton(
                style: outlinedButtonStyle,
                onPressed: _loading ? null : () => Navigator.pop(context),
                child: Text("Cancel")),
            OutlinedButton(
                style: outlinedButtonStyle,
                onPressed: partCount == 0
                    ? null
                    : () async {
                        setState(() {
                          _loading = true;
                        });
                        await FirebaseFirestoreCloudFunctions.transferParts(
                                origin, destination, part, partCount)
                            .then((value) => setState(() {
                                  _loading = false;
                                }))
                            .catchError((error) {
                          print(error);
                        }).whenComplete(() => Navigator.pop(context));
                      },
                child: _loading ? CircularProgressIndicator() : Text("OK")),
          ],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        );
      }),
    );
  }
}
