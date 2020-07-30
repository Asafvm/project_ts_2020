import 'package:flutter/material.dart';
import 'package:teamshare/models/device_instance.dart';

class DeviceInstanceListItem extends StatefulWidget {
  final IconData icon;
  final BuildContext ctx;
  final DeviceInstance device;
  DeviceInstanceListItem(this.icon, this.ctx, this.device);

  @override
  _DeviceListItemState createState() => _DeviceListItemState();
}

class _DeviceListItemState extends State<DeviceInstanceListItem> {
  var deviceDoc;
  Color _bgcolor = Colors.white;
  bool _selected = false;

  @override
  void initState() {
    deviceDoc = widget.device;
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
              title: Text(widget.device.getSerial),
              subtitle: Text("TODO: Insert next maintenance here"),
            ),
          ),
        ),
      ],
    );
  }
}
