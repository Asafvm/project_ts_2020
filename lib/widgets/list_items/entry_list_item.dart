import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teamshare/models/entry.dart';
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
                  '${FirebaseFirestoreProvider.getInstrumentById(entryDetails["instrumentId"]).codeName} ${FirebaseFirestoreProvider.getInstanceById(entryDetails["instanceId"]).serial}',
                  maxLines: 1,
                )
              : Container(),
          trailing: SizedBox(
            width: 30,
            child: entry.type == 2 && !kIsWeb && entryDetails["link"] != null
                ? IconButton(
                    icon: Icon(Icons.file_download),
                    onPressed: () async {
                      //get report
                      String path =
                          await FirebaseStorageProvider.downloadFileFromUrl(
                              '${entryDetails["link"]}');

                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => PDFScreen(
                          pathPDF: path,
                          viewOnly: true,
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
