import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teamshare/providers/firebase_storage_provider.dart';

class ImageHelper {
  static Future<String> takePicture(
      {BuildContext context, String uploadPath, String fileName}) async {
    return await showModalBottomSheet(
        context: context,
        builder: (context) => Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                      color: Colors.black, width: 2, style: BorderStyle.solid),
                ),
              ),
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: IconButton(
                        icon: Icon(Icons.photo),
                        onPressed: () => ImageHelper.pickFromGallery(
                            uploadPath, fileName, context)),
                  ),
                  Expanded(
                    child: IconButton(
                        icon: Icon(Icons.camera_alt_rounded),
                        onPressed: () => ImageHelper.pickFromCamera(
                            uploadPath, fileName, context)),
                  ),
                ],
              ),
            ));
  }

  static Future pickFromGallery(
      String uploadPath, String fileName, BuildContext context) async {
    final imageFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxHeight: 100,
      maxWidth: 100,
    );
    String downloadUrl = await FirebaseStorageProvider.uploadFile(
        File(imageFile.path), uploadPath, fileName);

    Navigator.of(context).pop(downloadUrl);
  }

  static Future pickFromCamera(
      String uploadPath, String fileName, BuildContext context) async {
    final imageFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxHeight: 100,
      maxWidth: 100,
    );

    String downloadUrl = await FirebaseStorageProvider.uploadFile(
        File(imageFile.path), uploadPath, fileName);
    Navigator.of(context).pop(downloadUrl);
  }
}
