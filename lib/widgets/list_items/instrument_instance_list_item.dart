import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
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
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.white, width: 3),
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      color: Colors.white,
      child: ListTile(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => InstrumentInfoScreen(
              instrument: instrument,
              instance: instance,
            ),
          ),
        ),
        leading: instance.imgUrl == null
            ? instrument.imgUrl == null
                ? CircleAvatar(child: Icon(Icons.computer))
                : Image.network(
                    instrument.imgUrl,
                    width: 70,
                  )
            : Image.network(
                instance.imgUrl,
                width: 70,
              ),
        title: Text(instance.serial),
        subtitle: Text(
            '${instance.nextMaintenance == null ? "Maintenance needed" : "Next maintenance = " + formatter.format(DateTime.fromMillisecondsSinceEpoch(instance.nextMaintenance))}'),
      ),
    );
  }
}
