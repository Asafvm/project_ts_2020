import 'package:flutter/material.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/widgets/entry_list_item.dart';

class InstrumentInfoScreen extends StatelessWidget {
  final Instrument instrument;
  final InstrumentInstance instance;

  InstrumentInfoScreen({this.instrument, this.instance});

  @override
  Widget build(BuildContext context) {
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
                  width: 3,
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 2,
                    child: IconButton(
                      icon: Icon(Icons.add_a_photo),
                      onPressed: () {},
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          instrument.getCodeName(),
                          style: textStyleTitle,
                        ),
                        Text(
                          "Model: " + instrument.getModel(),
                          style: textStyleContent,
                        ),
                        Text(
                          "Serial: " + instance.serial,
                          style: textStyleContent,
                        ),
                        Text(
                          "Currently at: ",
                          style: textStyleContent,
                        ),
                        Text(
                          "Next: ",
                          style: textStyleContent,
                        ),
                      ],
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
                    width: 3,
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
                              child: ListView.builder(
                                itemCount: instance.entries.length,
                                itemBuilder: (context, index) {
                                  return EntryListItem(
                                      instance.entries.elementAt(index));
                                },
                              ),
                            ),
                            Container(),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
