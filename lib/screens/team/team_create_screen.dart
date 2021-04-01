import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teamshare/providers/applogger.dart';
import 'package:teamshare/providers/authentication.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspath;
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/widgets/list_items/member_list_item.dart';

enum STEPS { INFO, INVITE, CONFIRM }
int _currentStep = STEPS.INFO.index;
String _name = "";
String _description = "";

class TeamCreateScreen extends StatefulWidget {
  @override
  _TeamCreateScreenState createState() => _TeamCreateScreenState();
}

class _TeamCreateScreenState extends State<TeamCreateScreen> {
  Set<String> members = Set<String>(); //using set to avoid duplicates
  bool __imgPicked = false;
  String _picUrl = 'assets/pics/add_image.png';

  @override
  void initState() {
    setState(() {
      _currentStep = STEPS.INFO.index;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create"),
      ),
      body: Stepper(
          controlsBuilder: (context, {onStepCancel, onStepContinue}) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  if (_currentStep == STEPS.INFO.index) //first step
                    ...[
                    TextButton(
                      onPressed: () => _changeStep(_currentStep + 1),
                      child: const Text('NEXT'),
                    ),
                  ] else if (_currentStep == STEPS.CONFIRM.index) //last step
                    ...[
                    TextButton(
                      onPressed: () => _changeStep(_currentStep - 1),
                      child: const Text('BACK'),
                    ),
                    TextButton(
                      onPressed: _createTeam,
                      child: const Text('FINISH'),
                    ),
                  ] else //any other step
                    ...[
                    TextButton(
                      onPressed: () => _changeStep(_currentStep - 1),
                      child: const Text('BACK'),
                    ),
                    TextButton(
                      onPressed: () => _changeStep(_currentStep + 1),
                      child: const Text('NEXT'),
                    ),
                  ],
                ],
              ),
            );
          },
          onStepTapped: (value) => _changeStep(value),
          currentStep: _currentStep,
          type: StepperType.horizontal,
          steps: [
            Step(
              //GENERAL INFORMATION
              title: Text("Info"),
              content: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextButton(
                      child: __imgPicked
                          ? Image.file(File(_picUrl))
                          : Image.asset(_picUrl),
                      onPressed: _takePicture,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: _name,
                          decoration: InputDecoration(
                            labelText: "Team name",
                          ),
                          maxLines: 1,
                          onChanged: (value) => {_name = value},
                        ),
                        TextFormField(
                          initialValue: _description,
                          decoration: InputDecoration(labelText: "Description"),
                          maxLines: 1,
                          onChanged: (value) => {_description = value},
                        ),
                      ],
                    ),
                  )
                ],
              ),
              isActive: _currentStep == STEPS.INFO.index ? true : false,
              state: _currentStep == STEPS.INFO.index
                  ? StepState.editing
                  : StepState.indexed,
            ),
            Step(
              //INVITE TEAM MEMBERS
              title: Text("Invite"),
              content: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: members.length,
                      itemBuilder: (BuildContext context, int index) {
                        return MemberListItem(
                            key: UniqueKey(),
                            name: members.elementAt(index),
                            removeFunction: _removeFromList);
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.resolveWith(getColor),
                          ), // shape: RoundedRectangleBorder
                          onPressed: () async {
                            final EmailContact contact =
                                await FlutterContactPicker.pickEmailContact(
                                    askForPermission: true);
                            setState(() {
                              members.add(contact.email.email);
                            });
                          },
                          child: Text("Add From Contacts"),
                        ),
                        TextButton(
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.resolveWith(getColor),
                          ), // shape: RoundedRectangleBorder(
                          //   borderRadius: BorderRadius.all(Radius.circular(25)),
                          //   side: BorderSide(
                          //       color: Colors.black,
                          //       width: 1,
                          //       style: BorderStyle.solid),
                          // ),
                          onPressed: () async {
                            String email = await _getMailManually(context);
                            if (email.isNotEmpty) {
                              setState(() {
                                members.add(email);
                              });
                            }
                          },
                          child: Text("Enter Manually"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              isActive: _currentStep == STEPS.INVITE.index ? true : false,
              state: _currentStep == STEPS.INVITE.index
                  ? StepState.editing
                  : StepState.indexed,
            ),
            Step(
              //CONFIRMATION
              title: Text("Confirm"),
              content: Container(),
              isActive: _currentStep == STEPS.CONFIRM.index ? true : false,
              state: _currentStep == STEPS.CONFIRM.index
                  ? StepState.editing
                  : StepState.indexed,
            ),
          ]),
    );
  }

  void _changeStep(int step) {
    setState(() {
      _currentStep = step;
    });
  }

  void _createTeam() {
    bool _loading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Confirm"),
            content: Text("Create $_name?"),
            actions: [
              TextButton(
                onPressed: () async => {
                  if (Authentication().isAuth)
                    {
                      setState(() {
                        _loading = true;
                      }),
                      members.add(Authentication().userEmail),
                      await FirebaseFirestoreProvider.addTeam(
                          _name,
                          _description,
                          members.toList(),
                          __imgPicked ? _picUrl : null),
                      setState(() {
                        _loading = false;
                      }),
                      Navigator.of(context).pop(),
                    }
                  else
                    Applogger.consoleLog(
                        MessegeType.error, "User is not connected")
                },
                child: _loading ? CircularProgressIndicator() : Text("Ok"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Cancel"),
              ),
            ],
          );
        },
      ),
    ).then((value) => {Navigator.of(context).pop()});
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final imageFile = await picker.getImage(
      source: ImageSource.gallery,
      maxHeight: 100,
      maxWidth: 100,
    );
    final appDir = await syspath.getApplicationDocumentsDirectory();
    final picName = path.basename(imageFile.path);
    File image = File(imageFile.path);
    File savedImage = await image.copy('${appDir.path}/$picName');
    setState(() {
      _picUrl = savedImage.path;
      __imgPicked = true;
    });
  }

  _removeFromList(String value) {
    setState(() {
      members.remove(value);
    });
  }

  Future<String> _getMailManually(BuildContext context) {
    TextEditingController _textController = TextEditingController();
    bool _valid = true;

    return showDialog(
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Enter Email"),
              content: TextField(
                controller: _textController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: _valid ? null : "Must be a valid email",
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
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
                TextButton(
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
  }
}
