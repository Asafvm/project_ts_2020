import 'package:flutter/material.dart';
import 'package:teamshare/models/field.dart';

class CustomField extends StatefulWidget {
  final Field field;
  final MediaQueryData mqd;
  final Function editFunction;
  final Size pdfSizeOnScreen;

  CustomField(this.field, this.mqd, this.editFunction, this.pdfSizeOnScreen);

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
      top: widget.field.offset.dy * widget.pdfSizeOnScreen.height,
      left: widget.field.offset.dx * widget.pdfSizeOnScreen.width,
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
                  Offset newPos = Offset(
                      details.offset.dx / widget.pdfSizeOnScreen.width,
                      details.offset.dy / widget.pdfSizeOnScreen.height);
                  _relocate(newPos);
                },
                feedback: _createRect(Colors.orange, 4, rectSize),
                child: _createRect(Colors.green, 2, rectSize),
                childWhenDragging: Container(),
              ),
      ),
    );
  }

  void _relocate(Offset offset) {
    Offset viewRatio = Offset(
        widget.mqd.viewPadding.topLeft.dx / widget.pdfSizeOnScreen.width,
        widget.mqd.viewPadding.topLeft.dy / widget.pdfSizeOnScreen.height);

    Offset factor =
        Offset(0, 60 / widget.pdfSizeOnScreen.height); //TODO: figure this out

    setState(() {
      widget.field.offset = offset - viewRatio - factor;
    });
  }

  void _resize(Offset offset) {
    setState(() {
      widget.field.setSize = offset;
    });
  }
}
