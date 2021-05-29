import 'package:flutter/material.dart';

class MemberListItem extends StatefulWidget {
  final String name;
  final bool isSelected;
  final Function onRemove;
  final Function onSwitch;

  MemberListItem({
    UniqueKey key,
    this.isSelected,
    this.name,
    this.onRemove,
    this.onSwitch,
  }) : super(key: key);

  @override
  _MemberListItemState createState() => _MemberListItemState();
}

class _MemberListItemState extends State<MemberListItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Text(
                widget.name,
                textAlign: TextAlign.start,
              ),
            ),
            widget.onRemove != null
                ? Row(
                    children: [
                      Switch(
                        activeColor: Theme.of(context).primaryColor,
                        onChanged: (bool value) {
                          widget.onSwitch(widget.name, value);
                        },
                        value: widget.isSelected ?? false,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                        ),
                        onPressed: () => widget.onRemove(widget.name),
                      ),
                    ],
                  )
                : Text(
                    "Team Creator",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
