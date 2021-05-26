import 'package:flutter/material.dart';
import 'package:teamshare/models/field.dart';

class CustomField extends StatefulWidget {
  final Field field;
  final MediaQueryData mqd;
  final Function onClick;
  final Size pdfSizeOnScreen;
  final double appbarHeight;
  final double scale;
  final Offset focalPoint;
  CustomField(
      {this.field,
      this.mqd,
      this.onClick,
      this.pdfSizeOnScreen,
      this.scale,
      this.focalPoint,
      this.appbarHeight});

  @override
  _CustomFieldState createState() => _CustomFieldState();
}

const ballDiameter = 8.0;

class _CustomFieldState extends State<CustomField> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    Size rectSize = widget.field.size; // * widget.scale;

    var field = Container(
      height: rectSize.height,
      width: rectSize.width,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.green),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Text(
          '(${widget.field.hint}) ${widget.field.defaultValue}',
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
      top: widget.field.offset.dy *
          widget.pdfSizeOnScreen.height, // / widget.scale,
      left: widget.field.offset.dx *
          widget.pdfSizeOnScreen.width, // / widget.scale,
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
                data: widget.field.index,
                onDragEnd: (details) {
                  //subtract the height of the status bar and appbar
                  setState(() {
                    widget.field.offset = Offset(
                        (details.offset.dx -
                                widget.mqd.viewPadding.topLeft.dx) /
                            widget.pdfSizeOnScreen.width,
                        (details.offset.dy -
                                widget.mqd.padding.top -
                                widget.appbarHeight) /
                            widget.pdfSizeOnScreen.height);
                  });
                },
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
