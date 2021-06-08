import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:draw_graph/draw_graph.dart';
import 'package:draw_graph/models/feature.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/helpers/picker_helper.dart';
import 'package:teamshare/models/entry.dart';
import 'package:teamshare/models/field.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/models/report.dart';
import 'package:teamshare/models/site.dart';
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/providers/firebase_firestore_cloud_functions.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/helpers/firebase_paths.dart';
import 'package:teamshare/screens/pdf/generic_form_screen.dart';
import 'package:teamshare/widgets/list_items/entry_list_item.dart';

class InstrumentInfoScreen extends StatefulWidget {
  final Instrument instrument;
  final InstrumentInstance instance;

  InstrumentInfoScreen({this.instrument, this.instance});

  @override
  _InstrumentInfoScreenState createState() => _InstrumentInfoScreenState();
}

class _InstrumentInfoScreenState extends State<InstrumentInfoScreen> {
  bool _showGraph = false;

  String _selectedReport = '';

  bool _loading = false;
  bool _creatingForm = false;

  @override
  Widget build(BuildContext context) {
    MediaQueryData mqd = MediaQuery.of(context);
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    var textStyleTitle = TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold);
    var textStyleContent = TextStyle(fontSize: 20.0);
    return StreamProvider<List<Site>>.value(
      value: FirebaseFirestoreProvider.getSites(),
      initialData: [],
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              '${FirebaseFirestoreProvider.getInstrumentById(widget.instance.instrumentId).codeName} ${widget.instance.serial}'),
        ),
        body: Column(
          children: [
            Flexible(
              //General info
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: Row(
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 2,
                      child: InkWell(
                        child: _loading
                            ? Center(child: CircularProgressIndicator())
                            : Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: widget.instance.imgUrl == null
                                          ? widget.instrument.imgUrl == null
                                              ? AssetImage(
                                                  'assets/pics/unknown.jpg')
                                              : Image.network(
                                                  widget.instrument.imgUrl,
                                                  width: 70,
                                                ).image
                                          : Image.network(
                                              widget.instance.imgUrl,
                                              width: 70,
                                            ).image,
                                      fit: BoxFit.fitWidth),
                                ),
                              ),
                        onTap: () async {
                          String pic = await PickerHelper.takePicture(
                              context: context,
                              uploadPath: FirebasePaths.instanceImagePath(
                                  widget.instance.instrumentId,
                                  widget.instance.serial),
                              fileName: 'instrumentImg');

                          if (pic != null && pic.isNotEmpty) {
                            setState(() {
                              _loading = true;
                              widget.instance.imgUrl = pic;
                            });
                            await FirebaseFirestoreCloudFunctions
                                .uploadInstrumentInstance(
                                    widget.instance, Operation.UPDATE);
                            setState(() {
                              _loading = false;
                            });
                          }
                        },
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(13.0),
                        child: Column(
                          children: [
                            Text(
                              widget.instrument.getCodeName(),
                              style: textStyleTitle,
                              maxLines: 1,
                            ),
                            SingleChildScrollView(
                              child: Table(
                                border: TableBorder(
                                    horizontalInside: BorderSide(
                                        color: Colors.grey, width: 1)),
                                defaultVerticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                children: [
                                  TableRow(children: [
                                    Text(
                                      "Model",
                                      style: textStyleContent,
                                    ),
                                    Text(
                                      widget.instrument.getModel(),
                                      style: textStyleContent,
                                    ),
                                  ]),
                                  TableRow(children: [
                                    Text(
                                      "Serial",
                                      style: textStyleContent,
                                    ),
                                    Text(
                                      widget.instance.serial,
                                      style: textStyleContent,
                                    ),
                                  ]),
                                  TableRow(children: [
                                    Text(
                                      'Site',
                                      style: textStyleContent,
                                    ),
                                    Consumer<List<Site>>(
                                      builder: (context, value, child) {
                                        String site =
                                            '${widget.instance.currentSiteId}';
                                        value.forEach((element) {
                                          if (element.id == site)
                                            site = element.name;
                                        });

                                        return Text(
                                          '$site',
                                          style: textStyleContent,
                                        );
                                      },
                                    ),
                                  ]),
                                  TableRow(children: [
                                    Text(
                                      "Maintenance",
                                    ),
                                    Text(
                                      widget.instance.nextMaintenance == null
                                          ? ""
                                          : formatter.format(DateTime
                                              .fromMillisecondsSinceEpoch(widget
                                                  .instance.nextMaintenance)),
                                      style: textStyleContent,
                                    ),
                                  ]),
                                ],
                              ),
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
              flex: _showGraph ? 3 : 7,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
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
                                    widget.instance),
                                initialData: [],
                                builder: (context, snapshot) {
                                  if (snapshot.hasData)
                                    return ListView.builder(
                                      itemCount: snapshot.data.length,
                                      itemBuilder: (context, index) {
                                        return EntryListItem(
                                            entry:
                                                snapshot.data.elementAt(index));
                                      },
                                    );
                                  else
                                    return Container();
                                },
                              ),
                            ),
                            Container(
                              //forms
                              child: StreamBuilder<List<DocumentSnapshot>>(
                                stream: FirebaseFirestoreProvider
                                    .getInstrumentReports(widget.instrument.id),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      itemBuilder: (ctx, index) {
                                        String reportName =
                                            snapshot.data[index]["reportName"];
                                        List<Field> reportFields =
                                            List<Field>.from(snapshot
                                                .data[index]["fields"].values
                                                .map((e) => Field.fromJson(e)));

                                        return ListTile(
                                          leading: Icon(Icons.picture_as_pdf),
                                          title: Text(reportName),
                                          trailing: SizedBox(
                                            width: 150,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: IconButton(
                                                    icon: Icon(
                                                      Icons.bar_chart,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                    ),
                                                    onPressed: () =>
                                                        setState(() {
                                                      _showGraph = !_showGraph;
                                                      _selectedReport =
                                                          reportName;
                                                    }),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: OutlinedButton(
                                                    child: _creatingForm
                                                        ? CircularProgressIndicator()
                                                        : Text(
                                                            "Create",
                                                          ),
                                                    style: outlinedButtonStyle,
                                                    onPressed: () async {
                                                      setState(() {
                                                        _creatingForm = true;
                                                      });
                                                      Map<String, dynamic>
                                                          reportData =
                                                          await FirebaseFirestoreCloudFunctions
                                                              .reserveReportId(
                                                                  widget
                                                                      .instance,
                                                                  reportName);

                                                      await Navigator.of(
                                                              context)
                                                          .push(
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              GenericFormScreen(
                                                            fields:
                                                                reportFields,
                                                            pdfId: reportName,
                                                            instance:
                                                                widget.instance,
                                                            siteId: widget
                                                                .instance
                                                                .currentSiteId,
                                                            reportId:
                                                                reportData[
                                                                    "reportId"],
                                                            reportIndex:
                                                                reportData[
                                                                    "reportIndex"],
                                                          ),
                                                        ),
                                                      );
                                                      setState(() {
                                                        _creatingForm = false;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      itemCount: snapshot.data.length,
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
            if (_showGraph)
              Flexible(
                flex: 4,
                child: ReportGraph(
                  widget: widget,
                  mqd: mqd,
                  reportName: _selectedReport,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ReportGraph extends StatelessWidget {
  const ReportGraph({
    Key key,
    @required this.reportName,
    @required this.widget,
    @required this.mqd,
  }) : super(key: key);

  final InstrumentInfoScreen widget;
  final MediaQueryData mqd;
  final String reportName;

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    int _dataLimit = mqd.orientation == Orientation.portrait ? 4 : 8;
    int _ySize = 5;

    return SingleChildScrollView(
      child: StreamBuilder<List<Report>>(
        stream: FirebaseFirestoreProvider.getTeamReport(),
        initialData: [],
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.isNotEmpty) {
            //init

            //get a specific report list
            List<Report> reports = snapshot.data
                .where((report) =>
                    report.status == "Closed" && //ignore open reports
                    report.reportName == reportName &&
                    report.instrumentId == widget.instance.instrumentId &&
                    report.instanceId == widget.instance.id)
                .toList();
            if (reports.isEmpty)
              return Container(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "No data recoreded for this instrument",
                  textAlign: TextAlign.center,
                ),
              );
            List<String> labelX = List<String>.generate(
                reports.length,
                (index) =>
                    '${reports.elementAt(index).index}\n${formatter.format(DateTime.fromMillisecondsSinceEpoch(reports.elementAt(index).timestampOpen))}');
            labelX = labelX.sublist(
                labelX.length > _dataLimit ? labelX.length - _dataLimit : 0);
            Map<String, List<String>> labelY = Map<String, List<String>>();

            //list graphable fields (feature titles)
            List<String> titles = reports.first.fields
                    .where((field) => field.type == FieldType.Num)
                    .where((field) => field.hint.isNotEmpty)
                    .map((field) => field.hint)
                    .toList() ??
                [];
            //create feature
            List<Feature> features = titles
                .map((title) => Feature(
                    title: title,
                    data: [],
                    color: Theme.of(context).primaryColor))
                .toList();

            //get feature data

            reports.forEach((report) {
              report.fields
                  .where((field) => titles.contains(field.hint))
                  .forEach((field) {
                try {
                  features
                      .firstWhere((feature) => feature.title == field.hint)
                      .data
                      .add(double.parse(field.defaultValue));
                } catch (_) {}
              });
            });
            //scale data
            features.forEach((feature) {
              //limit size
              List<double> data = feature.data.sublist(
                  feature.data.length > _dataLimit
                      ? feature.data.length - _dataLimit
                      : 0);
              double datamin =
                  data.reduce((value, element) => min(value, element));
              double datamax =
                  data.reduce((value, element) => max(value, element));
              double factor = datamax - datamin;
              //scale between 0 and 1
              feature.data = data
                  .map((element) => ((element - datamin) / factor))
                  .toList();
              //generate feature Y labels
              labelY[feature.title] = List<String>.generate(
                  _ySize + 1,
                  (index) =>
                      (datamin + index * (factor / _ySize)).toStringAsFixed(2));
            });

            return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: features
                    .map(
                      (feature) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              feature.title,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          SingleChildScrollView(
                            child: LineGraph(
                              features: [feature],
                              size: Size(
                                  mqd.size.width * .9,
                                  mqd.orientation == Orientation.portrait
                                      ? mqd.size.width * .6
                                      : mqd.size.width * .25),
                              labelX: labelX,
                              labelY: labelY[feature.title],
                              showDescription: true,
                              graphColor: Colors.black,
                              graphOpacity: 0.2,
                              verticalFeatureDirection: true,
                              descriptionHeight: 100,
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList());
          } else
            return Container();
        },
      ),
    );
  }
}
