import 'package:flutter/material.dart';

class InstrumentInstanceListItem extends StatelessWidget {
  final IconData icon;
  final BuildContext ctx;
  final String instrumentSeial;
  InstrumentInstanceListItem(this.icon, this.ctx, this.instrumentSeial);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.white, width: 3),
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          color: Colors.white,
          child: ListTile(
            leading: CircleAvatar(
              child: Icon(icon),
            ),
            title: Text(instrumentSeial),
            subtitle: Text("Last maintenance = ???"),
          ),
        ),
      ],
    );
  }
}
