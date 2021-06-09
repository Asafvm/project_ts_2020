import 'package:flutter/material.dart';
import 'package:teamshare/models/report.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/providers/firebase_storage_provider.dart';
import 'package:teamshare/screens/pdf/pdf_viewer_page.dart';

class ReportListTile extends StatelessWidget {
  final Report report;

  ReportListTile({this.report});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: report.status == 'Closed'
          ? Icon(
              Icons.mark_email_read,
              color: Theme.of(context).primaryColor,
            )
          : Icon(Icons.mail),
      title: Text(
        '${report.index} ${report.reportName}',
        maxLines: 1,
      ),
      subtitle: Text(
          '${FirebaseFirestoreProvider.getInstrumentById(report.instrumentId).codeName} ${FirebaseFirestoreProvider.getInstanceById(report.instanceId).serial}'),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${FirebaseFirestoreProvider.getSiteById(report.siteId).name}'),
          Text('${report.creatorId}')
        ],
      ),
      onTap: report.downloadUrl != null ? () => _showReport(context) : null,
    );
  }

  Future<void> _showReport(BuildContext context) async {
    String url =
        await FirebaseStorageProvider.downloadFileFromUrl(report.downloadUrl);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PDFScreen(
        pathPDF: url,
        viewOnly: true,
      ),
    ));
  }
}
