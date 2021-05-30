import 'package:flutter/material.dart';
import 'package:teamshare/models/field.dart';

class CustomField extends StatefulWidget {
  final Field field;
  final Function onClick;
  final Function onDrag;
  final Size pdfSizeOnScreen;
  final double appbarHeight;
  final Offset centerOffset;
  final double scale;
  final Color color;
  CustomField(
      {this.field,
      this.onClick,
      this.pdfSizeOnScreen,
      this.appbarHeight,
      this.centerOffset,
      this.scale,
      this.onDrag,
      this.color});

  @override
  _CustomFieldState createState() => _CustomFieldState();
}

const ballDiameter = 8.0;

class _CustomFieldState extends State<CustomField> {
  bool _selected = false;
  Offset before;

  @override
  Widget build(BuildContext context) {
    Size rectSize = widget.field.size; // * widget.scale;

    var field = Container(
      height: rectSize.height * widget.scale,
      width: rectSize.width * widget.scale,
      decoration: BoxDecoration(
        color: widget.color.withAlpha(50),
        border: Border.all(
            color: '${widget.field.hint} ${widget.field.defaultValue}'
                    .trim()
                    .isNotEmpty
                ? widget.color
                : Colors.deepOrange),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Text(
          '${widget.field.hint} ${widget.field.defaultValue}',
          style: TextStyle(
            fontSize: rectSize.height - 6,
          ),
          softWrap: true,
        ),
      ),
    );
    return Positioned(
      height: rectSize.height,
      width: rectSize.width,
      top: widget.field.offset.dy * widget.pdfSizeOnScreen.height,
      left: widget.field.offset.dx * widget.pdfSizeOnScreen.width,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() {
          _selected = !_selected;
        }),
        onPanUpdate: (details) => {if (_selected) _resize(details.delta)},
        onPanEnd: (details) => {
          setState(() {
            _selected = false;
          })
        },
        onLongPress: () => widget.onClick(widget.field),
        child: _selected
            ? Stack(clipBehavior: Clip.none, children: [
                field,
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    width: ballDiameter,
                    height: ballDiameter,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: ballDiameter,
                    height: ballDiameter,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: ballDiameter,
                    height: ballDiameter,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: ballDiameter,
                    height: ballDiameter,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ])
            : Draggable(
                onDraggableCanceled: (velocity, offset) {
                  widget.field.offset = before;
                },
                onDragStarted: () => before = widget.field.offset,
                dragAnchor: DragAnchor.pointer,
                data: widget.field.index,
                onDragEnd: (details) =>
                    widget.onDrag(widget.field, details.offset),
                feedback: field,
                child: field,
                childWhenDragging: Container(),
              ),
      ),
    );
  }

  void _resize(Offset offset) {
    setState(() {
      widget.field.setSize = offset;
    });
  }
}
