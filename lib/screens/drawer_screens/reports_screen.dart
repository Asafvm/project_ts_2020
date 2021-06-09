import 'package:flutter/material.dart';
import 'package:teamshare/models/report.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/screens/drawer_screens/search_instrument_screen.dart';
import 'package:teamshare/widgets/list_items/report_list_tile.dart';
import 'package:teamshare/widgets/searchbar.dart';

enum ReportScreen { History, Create }

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _currentIndex = ReportScreen.History.index;
  String _filter = '';
  String _statistics = "Matches found";
  List<Report> filteredReports = [];

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
          ? Column(
              children: [
                SearchBar(
                  label: 'Search for instruments',
                  onChange: (value) {
                    setState(() {
                      _filter = value;
                    });
                  },
                ),
                Text(_statistics),
                Expanded(
                  child: StreamBuilder<List<Report>>(
                      stream: FirebaseFirestoreProvider.getTeamReport(
                          decending: true),
                      initialData: [],
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          _filterReportList(snapshot.data);

                          return ListView.builder(
                              itemCount: filteredReports.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) => ReportListTile(
                                    report: filteredReports[index],
                                  ));
                        } else
                          return Container();
                      }),
                )
              ],
            )
          : SearchInstrumentScreen(),
    );
  }

  void _filterReportList(List<Report> reports) {
    filteredReports = reports;
    List<String> filters = _filter.split(" ");
    filters.forEach((filter) {
      if (filter.isNotEmpty)
        filteredReports = filteredReports
            .where((report) =>
                FirebaseFirestoreProvider.getInstrumentById(report.instrumentId)
                    .codeName
                    .toLowerCase()
                    .contains(filter.toLowerCase()) ||
                FirebaseFirestoreProvider.getSiteById((report.siteId))
                    .name
                    .toLowerCase()
                    .contains(filter.toLowerCase()) ||
                FirebaseFirestoreProvider.getInstanceById((report.instanceId))
                    .serial
                    .toLowerCase()
                    .contains(filter.toLowerCase()) ||
                report.creatorId.toLowerCase().contains(filter) ||
                report.index.toLowerCase().contains(filter) ||
                report.reportName.toLowerCase().contains(filter))
            .toList();
    });

    filteredReports.sort((a, b) => a.instrumentId.compareTo(b.instrumentId));
    _statistics = '${filteredReports.length} Matches Found';
  }
}
