import 'package:flutter/material.dart';
import 'package:teamshare/widgets/add_part_form.dart';

class AdminPartScreen extends StatefulWidget {
  @override
  _AdminPartScreenState createState() => _AdminPartScreenState();
}

class _AdminPartScreenState extends State<AdminPartScreen> {
  @override
  Widget build(BuildContext context) {
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
          child: Text('Parts'),
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
