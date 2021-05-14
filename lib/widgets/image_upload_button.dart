import 'package:flutter/material.dart';

class ImageUploadButton extends StatelessWidget {
  final String imgUrl;
  final IconData defaultIcon;
  final String uploadPath;
  final BuildContext context;

  const ImageUploadButton(
      {this.imgUrl, this.defaultIcon, this.uploadPath, this.context});

  @override
  Widget build(BuildContext context) {
    return imgUrl == null
        ? IconButton(
            icon: Icon(Icons.add_a_photo),
            iconSize: 50,
            onPressed: () {},
          )
        : Image.network(imgUrl);
  }
}
