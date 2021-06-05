import 'package:flutter/material.dart';
import 'package:teamshare/models/report.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/widgets/list_items/entry_list_item.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reports'),
      ),
      body: StreamBuilder<List<Report>>(
          stream: FirebaseFirestoreProvider.getTeamReport(),
          initialData: [],
          builder: (context, snapshot) {
            return snapshot.hasData
                ? ListView.builder(
                    itemCount: snapshot.data.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) =>
                        Text(snapshot.data[index].index),
                  )
                : Container();
          }),
    );
  }
}
