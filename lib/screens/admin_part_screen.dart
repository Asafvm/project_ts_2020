import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/models/part.dart';
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/widgets/add_part_form.dart';
import 'package:teamshare/widgets/part_list_item.dart';

class AdminPartScreen extends StatefulWidget {
  @override
  _AdminPartScreenState createState() => _AdminPartScreenState();
}

class _AdminPartScreenState extends State<AdminPartScreen> {
  @override
  Widget build(BuildContext context) {
    var partList = Provider.of<List<Part>>(context, listen: true) ?? [];

    return Scaffold(
        appBar: AppBar(
          title: Text("Manage Parts"),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.add), onPressed: () => _openAddParts(context))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: partList.length == 0
              ? Center(child: Text("You haven't registered any parts"))
              : ListView.builder(
                  key: new Key(randomString(20)),
                  itemBuilder: (ctx, index) =>
                      PartListItem(part: partList.elementAt(index)),
                  itemCount: partList.length,
                ),
        ));
  }

  _openAddParts(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return AddPartForm();
        });
    setState(() {});
  }
}
