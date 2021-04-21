import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/models/part.dart';
import 'package:teamshare/widgets/forms/add_part_form.dart';
import 'package:teamshare/widgets/list_items/part_list_item.dart';

class AdminPartScreen extends StatefulWidget {
  @override
  _AdminPartScreenState createState() => _AdminPartScreenState();
}

class _AdminPartScreenState extends State<AdminPartScreen> {
  @override
  Widget build(BuildContext context) {
    List<Part> _partList = Provider.of<List<Part>>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Parts"),
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
                itemBuilder: (ctx, index) => PartListItem(
                  part: _partList.elementAt(index),
                  key: UniqueKey(),
                ),
                itemCount: _partList.length,
              ),
      ),
    );
  }

  _openAddParts(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return AddPartForm();
        });
  }
}
