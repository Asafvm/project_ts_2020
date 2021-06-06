import 'package:flutter/material.dart';
import 'package:teamshare/models/report.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/screens/drawer_screens/search_instrument_screen.dart';
import 'package:teamshare/widgets/list_items/report_list_tile.dart';

enum ReportScreen { History, Create }

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _currentIndex = ReportScreen.History.index;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reports'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (value) {
          setState(() {
            _currentIndex = ReportScreen.values[value].index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
              icon: Icon(Icons.create), label: 'New Report'),
        ],
      ),
      body: _currentIndex == ReportScreen.History.index
          ? StreamBuilder<List<Report>>(
              stream: FirebaseFirestoreProvider.getTeamReport(decending: true),
              initialData: [],
              builder: (context, snapshot) {
                return snapshot.hasData && snapshot.data != null
                    ? ListView.builder(
                        itemCount: snapshot.data.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) => ReportListTile(
                              report: snapshot.data[index],
                            ))
                    : Container();
              })
          : SearchInstrumentScreen(),
    );
  }
}
