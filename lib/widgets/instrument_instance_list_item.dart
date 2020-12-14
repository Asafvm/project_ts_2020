import 'package:flutter/material.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/screens/instrument_info_screen.dart';

class InstrumentInstanceListItem extends StatefulWidget {
  final IconData icon;
  final BuildContext ctx;
  final InstrumentInstance instrument;
  InstrumentInstanceListItem(this.icon, this.ctx, this.instrument);

  @override
  _InstrumentListItemState createState() => _InstrumentListItemState();
}

class _InstrumentListItemState extends State<InstrumentInstanceListItem> {
  var instrumentDoc;
  Color _bgDefaultColor = Colors.white;

  @override
  void initState() {
    instrumentDoc = widget.instrument;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => InstrumentInfoScreen())),
          child: Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: _bgDefaultColor, width: 3),
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            color: _bgDefaultColor,
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(widget.icon),
              ),
              title: Text(widget.instrument.serial),
              subtitle: Text("Last maintenance = ???"),
            ),
          ),
        ),
      ],
    );
  }
}
