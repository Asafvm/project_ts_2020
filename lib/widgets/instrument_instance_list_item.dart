import 'package:flutter/material.dart';
import 'package:teamshare/models/Instrument_instance.dart';

class InstrumentInstanceListItem extends StatefulWidget {
  final IconData icon;
  final BuildContext ctx;
  final InstrumentInstance Instrument;
  InstrumentInstanceListItem(this.icon, this.ctx, this.Instrument);

  @override
  _InstrumentListItemState createState() => _InstrumentListItemState();
}

class _InstrumentListItemState extends State<InstrumentInstanceListItem> {
  var InstrumentDoc;
  Color _bgcolor = Colors.white;
  bool _selected = false;

  @override
  void initState() {
    InstrumentDoc = widget.Instrument;
    super.initState();
  }

  void _setSelected() {
    setState(() {
      _selected = !_selected;
      _bgcolor = _selected ? Theme.of(context).accentColor : Colors.white;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        GestureDetector(
          onTap: _setSelected,
          child: Card(
            color: _bgcolor,
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(widget.icon),
              ),
              title: Text(widget.Instrument.getSerial),
              subtitle: Text("TODO: Insert next maintenance here"),
            ),
          ),
        ),
      ],
    );
  }
}
