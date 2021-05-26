import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teamshare/helpers/decoration_library.dart';
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/providers/firebase_storage_provider.dart';

class PickerHelper {
  //IMAGE
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
                        onPressed: () => PickerHelper._pickFromGallery(
                            uploadPath, fileName, context)),
                  ),
                  Expanded(
                    child: IconButton(
                        icon: Icon(Icons.camera_alt_rounded),
                        onPressed: () => PickerHelper._pickFromCamera(
                            uploadPath, fileName, context)),
                  ),
                ],
              ),
            ));
  }

  static Future _pickFromGallery(
      String uploadPath, String fileName, BuildContext context) async {
    final imageFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxHeight: 100,
      maxWidth: 100,
    );

    String downloadUrl = imageFile.path;
    if (uploadPath != null)
      downloadUrl = await FirebaseStorageProvider.uploadFile(
          File(imageFile.path), uploadPath, fileName);

    Navigator.of(context).pop(downloadUrl);
  }

  static Future _pickFromCamera(
      String uploadPath, String fileName, BuildContext context) async {
    final imageFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxHeight: 100,
      maxWidth: 100,
    );
    String downloadUrl = imageFile.path;
    if (uploadPath != null)
      downloadUrl = await FirebaseStorageProvider.uploadFile(
          File(imageFile.path), uploadPath, fileName);
    Navigator.of(context).pop(downloadUrl);
  }

  //CONTACTS
  static Future<String> pickContact(BuildContext context) async {
    return await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
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
                    icon: Icon(Icons.contact_mail),
                    onPressed: () => _pickFromContacts(context)),
              ),
              Expanded(
                child: IconButton(
                    icon: Icon(Icons.keyboard),
                    onPressed: () => _writeManualy(context)),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future _pickFromContacts(BuildContext context) async {
    final EmailContact contact =
        await FlutterContactPicker.pickEmailContact(askForPermission: true);
    if (contact != null) {
      Navigator.of(context).pop(contact.email.email);
      // await FirebaseFirestoreCloudFunctions.addTeamMember(
      //     currentTeam.id, [contact.email.email]);
    }
  }

  static Future _writeManualy(BuildContext context) async {
    TextEditingController _textController = TextEditingController();
    bool _valid = true;

    String contact = await showDialog(
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Enter Email"),
              content: TextField(
                  controller: _textController,
                  keyboardType: TextInputType.emailAddress,
                  decoration:
                      DecorationLibrary.inputDecoration('Email', context)
                          .copyWith(
                    errorText: _valid ? null : "Must be a valid email",
                  )),
              actions: [
                OutlinedButton(
                  style: outlinedButtonStyle,
                  onPressed: () async {
                    if (_textController.text.isEmpty ||
                        !emailRegExp.hasMatch(_textController.text)) {
                      setState(() {
                        _valid = false;
                      });
                    } else {
                      setState(() {
                        _valid = true;
                      });
                      Navigator.of(context).pop(_textController.text);
                    }
                  },
                  child: Text(
                    "OK",
                  ),
                ),
                OutlinedButton(
                  style: outlinedButtonStyle,
                  onPressed: () {
                    Navigator.of(context).pop("");
                  },
                  child: Text(
                    "Cancel",
                  ),
                ),
              ],
              elevation: 10,
            );
          },
        );
      },
      context: context,
    );
    Navigator.of(context).pop(contact);
  }
}
