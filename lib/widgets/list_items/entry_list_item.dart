import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teamshare/helpers/firebase_paths.dart';
import 'package:teamshare/helpers/pdf_helper.dart';
import 'package:teamshare/models/entry.dart';
import 'package:teamshare/models/field.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/models/site.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/providers/firebase_storage_provider.dart';
import 'package:teamshare/screens/pdf/pdf_viewer_page.dart';

class EntryListItem extends StatelessWidget {
  final Entry entry;
  final bool showSub;
  const EntryListItem({this.entry, this.showSub = false});

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    Map<String, String> entryDetails = entry.details;
    return Card(
      shape: RoundedRectangleBorder(
        side:
            BorderSide(color: Colors.grey, width: 1, style: BorderStyle.solid),
      ),
      child: ListTile(
          leading: SizedBox(
            width: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    formatter.format(
                        DateTime.fromMillisecondsSinceEpoch(entry.timestamp)),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Icon(_getIcon(entry.type)),
                ),
              ],
            ),
          ),
          title: Text(
            entryDetails["title"],
            textAlign: TextAlign.start,
          ),
          subtitle: showSub
              ? Text(
                  '${entryDetails["instrumentId"]} ${entryDetails["instanceId"]}')
              : Container(),
          trailing: SizedBox(
            width: 30,
            child: entry.type == 2 && !kIsWeb
                ? IconButton(
                    icon: Icon(Icons.file_download),
                    onPressed: () async {
                      //get report
                      String path = await FirebaseStorageProvider.downloadFile(
                          '${FirebasePaths.instrumentReportTemplatePath(entryDetails["instrumentId"])}/${entryDetails["reportName"]}');
                      //get fields
                      List<Field> fields =
                          await FirebaseFirestoreProvider.getReportFields(
                              instrumentId: entryDetails["instrumentId"],
                              instanceId: entryDetails["instanceId"],
                              reportId:
                                  '${entryDetails["reportName"]}_${entryDetails["reportid"]}');
                      //get site from instance id
                      InstrumentInstance instance =
                          await FirebaseFirestoreProvider.getInstanceInfo(
                              entryDetails["instrumentId"],
                              entryDetails["instanceId"]);
                      Site site = await FirebaseFirestoreProvider.getSiteInfo(
                          instance.currentSiteId);

                      //build report
                      String pdfPath = await PdfHelper.createPdf(
                        fields: fields,
                        instrumentId: entryDetails["instrumentId"],
                        instanceId: entryDetails["instanceId"],
                        isNew: false,
                        pdfPath: path,
                        siteName: site.name,
                      );

                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => PDFScreen(
                          pathPDF: pdfPath,
                        ),
                      ));
                    })
                : Container(),
          )),
    );
  }

  IconData _getIcon(int type) {
    switch (type) {
      case 0:
        return Icons.info;
        break;

      case 1:
        return Icons.location_city;
        break;

      case 2:
        return Icons.file_copy;
        break;
    }
    return Icons.error;
  }
}
