import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/screens/instrument/instrument_info_screen.dart';

class InstrumentInstanceListItem extends StatelessWidget {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  final Instrument instrument;
  final InstrumentInstance instance;
  InstrumentInstanceListItem({this.instrument, this.instance});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => InstrumentInfoScreen(
              instrument: instrument,
              instance: instance,
            ),
          ),
        )
      },
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.white, width: 3),
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        color: Colors.white,
        child: ListTile(
          leading: CircleAvatar(
            child: Icon(Icons.computer),
          ),
          title: Text(instance.serial),
          subtitle: Text(
              '${instance.nextMaintenance == null ? "Maintenance needed" : "Next maintenance = " + formatter.format(DateTime.fromMillisecondsSinceEpoch(instance.nextMaintenance))}'),
        ),
      ),
    );
  }
}
