import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/part.dart';
import 'package:teamshare/providers/firebase_firestore_cloud_functions.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/screens/part/part_info_screen.dart';

class PartListItem extends StatefulWidget {
  final Part part;
  final bool inventoryMode;

  const PartListItem({Key key, this.part, this.inventoryMode = false})
      : super(key: key);

  @override
  _PartListItemState createState() => _PartListItemState();
}

class _PartListItemState extends State<PartListItem> {
  @override
  Widget build(BuildContext context) {
    int _partCount = 0;
    return Card(
      child: ListTile(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) {
              return StreamProvider<List<Instrument>>(
                initialData: [],
                create: (context) => FirebaseFirestoreProvider.getInstruments(),
                child: PartInfoScreen(
                  part: widget.part,
                ),
              );
            },
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(
            widget.part.active ? Icons.computer : Icons.desktop_access_disabled,
            color: widget.part.active
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
        ),
        title: Text(
          widget.part.getDescription(),
          maxLines: 2,
        ),
        subtitle: Text(
          widget.part.getreference(),
          maxLines: 1,
        ),
        trailing: SizedBox(
          width: 50,
          child: widget.inventoryMode
              ? IconButton(
                  icon: Icon(Icons.import_export),
                  onPressed: () => _inventoryChange(_partCount))
              : Container(),
        ),
      ),
    );
  }

  void _inventoryChange(int partCount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text('Inventory Change'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  icon: Icon(Icons.arrow_circle_down_outlined),
                  onPressed: () {
                    setState(() {
                      if (partCount > 0) partCount--;
                    });
                  }),
              Text(partCount.toString()),
              IconButton(
                  icon: Icon(Icons.arrow_circle_up_outlined),
                  onPressed: () {
                    setState(() {
                      partCount++;
                    });
                  })
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            TextButton(
                onPressed: () async => {
                      print(await FirebaseFirestoreCloudFunctions
                          .addUserInventory(widget.part, partCount)),
                      Navigator.pop(context)
                    },
                child: Text("OK")),
          ],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        );
      }),
    );
  }
}
