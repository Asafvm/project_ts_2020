import 'package:flutter/material.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/widgets/forms/add_part_form.dart';
import 'package:teamshare/widgets/part_list_item.dart';

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
        child: StreamBuilder(
          stream: FirebaseFirestoreProvider.getParts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (!snapshot.hasData || snapshot.data.length == 0)
                return Center(
                    child: Text("You haven't registered any parts yet"));
              else
                return ListView.builder(
                  key: UniqueKey(), //new Key(Strings.randomString(20)),
                  itemBuilder: (ctx, index) => PartListItem(
                    part: snapshot.data.elementAt(index),
                    key: UniqueKey(),
                  ),
                  itemCount: snapshot.data.length,
                );
            } else {
              if (!snapshot.hasData || snapshot.data.length == 0)
                return Center(
                    child: Text("You haven't registered any parts yet"));
              else
                return Center(child: CircularProgressIndicator());
            }
          },
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
