import 'package:flutter/material.dart';
import 'package:teamshare/models/field.dart';

class CustomField extends StatefulWidget {
  final Field field;
  final MediaQueryData mqd;
  final Function editFunction;
  CustomField(this.field, this.mqd, this.editFunction);

  @override
  _CustomFieldState createState() => _CustomFieldState();
}

class _CustomFieldState extends State<CustomField> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    Size rectSize = widget.field.size;

    Widget _createRect(Color color, double w, Size size) {
      Size _size = size;
      return SizedBox.fromSize(
        size: _size,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(width: w, color: color),
          ),
          child: Text(
            "(" + widget.field.index.toString() + ") " + widget.field.hint,
            style: TextStyle(fontSize: 16), //TODO: fix style while dragging
          ),
        ),
      );
    }

    return Positioned(
      top: widget.field.offset.dy,
      left: widget.field.offset.dx,
      child: GestureDetector(
        onTap: () => setState(() {
          _selected = !_selected;
          if (_selected) {
            widget.editFunction(context, widget.field);
          }
        }),
        onLongPress:
            () {}, //ignore long press TODO:change long press to drag with animation
        onPanUpdate: (details) => {if (_selected) _resize(details.delta)},
        child: _selected
            ? _createRect(Colors.deepOrange, 2, rectSize)
            : Draggable(
                data: widget.field.index,
                onDragEnd: (details) {
                  //if (details.wasAccepted)
                  _relocate(details.offset);
                },
                feedback: _createRect(Colors.orange, 4, rectSize),
                child: _createRect(Colors.green, 2, rectSize),
                childWhenDragging: Container(),
              ),
      ),
    );
  }

  void _relocate(Offset offset) {
    setState(() {
      widget.field.offset = offset -
          widget.mqd.viewPadding.topLeft -
          widget.mqd.viewInsets.topLeft -
          widget
              .mqd.padding.topLeft; //consider space outside of main Stack view
    });
  }

  void _resize(Offset offset) {
    setState(() {
      widget.field.setSize = offset;
    });
  }
}
