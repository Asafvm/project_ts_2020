import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/helpers/image_helper.dart';
import 'package:teamshare/models/entry.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/models/site.dart';
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/providers/firebase_firestore_cloud_functions.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/helpers/firebase_paths.dart';
import 'package:teamshare/providers/firebase_storage_provider.dart';
import 'package:teamshare/screens/pdf/generic_form_screen.dart';
import 'package:teamshare/widgets/list_items/entry_list_item.dart';

class InstrumentInfoScreen extends StatelessWidget {
  final Instrument instrument;
  final InstrumentInstance instance;

  InstrumentInfoScreen({this.instrument, this.instance});

  @override
  Widget build(BuildContext context) {
    List<Site> siteList = Provider.of<List<Site>>(context);

    var textStyleTitle = TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold);
    var textStyleContent = TextStyle(fontSize: 20.0);
    return Scaffold(
      appBar:
          AppBar(title: Text(instrument.getCodeName() + " " + instance.serial)),
      body: Column(
        children: [
          Flexible(
            //General info
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 2,
                    child: InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: instance.imgUrl == null
                                  ? AssetImage('assets/pics/unknown.jpg')
                                  : NetworkImage(instance.imgUrl),
                              fit: BoxFit.fitHeight),
                        ),
                      ),
                      onTap: () async => {
                        instance.imgUrl = await ImageHelper.takePicture(
                            context: context,
                            uploadPath: FirebasePaths.instanceImagePath(
                                instance.instrumentCode, instance.serial),
                            fileName: 'instrumentImg'),
                        FirebaseFirestoreCloudFunctions
                            .uploadInstrumentInstance(
                                instance, Operation.CREATE)
                      },
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(13.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            instrument.getCodeName(),
                            style: textStyleTitle,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Model",
                                style: textStyleContent,
                              ),
                              Text(
                                instrument.getModel(),
                                style: textStyleContent,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Serial",
                                style: textStyleContent,
                              ),
                              Text(
                                instance.serial,
                                style: textStyleContent,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Site',
                                style: textStyleContent,
                              ),
                              Text(
                                '${instance.currentSiteId}',
                                style: textStyleContent,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Maintenance",
                              ),
                              Text(
                                "",
                                style: textStyleContent,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Flexible(
            //log and forms
            flex: 7,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
              child: DefaultTabController(
                initialIndex: 0,
                length: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    tabInstrument, //defined in consts
                    Expanded(
                      child: TabBarView(
                        children: [
                          Container(
                            //log
                            child: StreamBuilder<List<Entry>>(
                              stream: FirebaseFirestoreProvider.getEntries(
                                  instance),
                              initialData: [],
                              builder: (context, snapshot) {
                                return ListView.builder(
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (context, index) {
                                    return EntryListItem(
                                        snapshot.data.elementAt(index));
                                  },
                                );
                              },
                            ),
                          ),
                          Container(
                            //forms
                            child: StreamBuilder<List<DocumentSnapshot>>(
                              stream: FirebaseFirestoreProvider
                                  .getInstrumentReports(instrument.id),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  List<DocumentSnapshot> docList =
                                      snapshot.data;

                                  return ListView.builder(
                                    shrinkWrap: true,
                                    itemBuilder: (ctx, index) => ListTile(
                                      leading: Icon(Icons.picture_as_pdf),
                                      title: Text(docList[index].id),
                                      trailing: OutlinedButton(
                                        child: Text(
                                          "Create",
                                        ),
                                        style: outlinedButtonStyle,
                                        onPressed: () async {
                                          String downloadedPdfPath =
                                              await FirebaseStorageProvider
                                                  .downloadFile(
                                                      '${FirebasePaths.instrumentReportTemplatePath(instrument.id)}/${docList[index].id}');
                                          if (downloadedPdfPath == null) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        'Could not download report. Please check your internet connection.')));
                                          } else
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    GenericFormScreen(
                                                  fields: snapshot.data[index]
                                                      .data(),
                                                  pdfPath: downloadedPdfPath,
                                                  instance: instance,
                                                  siteName:
                                                      instance.currentSiteId,
                                                ),
                                              ),
                                            );
                                        },
                                      ),
                                    ),
                                    itemCount: docList.length,
                                  );
                                } else {
                                  return Container();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
