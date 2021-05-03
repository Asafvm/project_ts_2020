import 'package:flutter/cupertino.dart';

class ImageButton extends StatelessWidget {
  final ImageProvider image;
  final Function action;

  const ImageButton({this.image, this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: action,
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(image: image, fit: BoxFit.fitWidth)),
      ),
    );
  }
}
