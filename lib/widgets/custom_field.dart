import 'package:flutter/material.dart';
import 'package:teamshare/models/field.dart';

class CustomField extends StatefulWidget {
  final Field field;
  final MediaQueryData mqd;
  final Function editFunction;
  final Size pdfSizeOnScreen;
  final double appbarHeight;
  final double scale;
  final Offset focalPoint;
  CustomField(
      {this.field,
      this.mqd,
      this.editFunction,
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
      child: Text(
        '(${widget.field.index.toString()})' + widget.field.defaultValue,
        style: TextStyle(fontSize: rectSize.height - 2),
        softWrap: true,
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
        onLongPress: () => widget.editFunction(context, widget.field),
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
                  Offset newPos = Offset(
                      (details.offset.dx - widget.mqd.viewPadding.topLeft.dx) /
                          widget.pdfSizeOnScreen.width,
                      (details.offset.dy -
                              widget.mqd.padding.top -
                              widget
                                  .appbarHeight) / //75 =  empty space due to centered widget
                          widget.pdfSizeOnScreen.height);
                  _relocate(newPos);
                },
                feedback: Card(elevation: 5, child: field),
                child: field,
                childWhenDragging: Container(),
              ),
      ),
    );
  }

  void _relocate(Offset offset) {
    // Offset viewRatio = Offset(
    //     widget.mqd.viewPadding.topLeft.dx / widget.pdfSizeOnScreen.width,
    //     widget.mqd.viewPadding.topLeft.dy / widget.pdfSizeOnScreen.height);

    // Offset factor =
    //     Offset(0, 50 / widget.pdfSizeOnScreen.height); //TODO: figure this out

    setState(() {
      widget.field.offset = offset;
      // -viewRatio;
      // -factor;
    });
  }

  void _resize(Offset offset) {
    setState(() {
      widget.field.setSize = offset;
    });
  }
}
