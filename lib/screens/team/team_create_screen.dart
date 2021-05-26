import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teamshare/helpers/decoration_library.dart';
import 'package:teamshare/helpers/picker_helper.dart';
import 'package:teamshare/providers/applogger.dart';
import 'package:teamshare/providers/authentication.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspath;
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/providers/firebase_firestore_cloud_functions.dart';
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
  Map<String, bool> members = Map<String, bool>();
  bool _imgPicked = false;
  String _picUrl;
  bool _loading = false;
  @override
  void initState() {
    setState(() {
      _currentStep = STEPS.INFO.index;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mqd = MediaQuery.of(context);
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

              content: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    child: Container(
                      constraints:
                          BoxConstraints(maxHeight: 100, maxWidth: 100),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: _picUrl == null
                                ? AssetImage('assets/pics/unknown.jpg')
                                : Image.file(File(_picUrl)).image,
                            fit: BoxFit.fitHeight),
                      ),
                    ),
                    onTap: () async => {
                      _picUrl = await PickerHelper.takePicture(
                        context: context,
                      ),
                    },
                  ),
                  TextFormField(
                    initialValue: _name,
                    decoration:
                        DecorationLibrary.inputDecoration('Team Name', context),
                    maxLines: 1,
                    onChanged: (value) => {_name = value},
                  ),
                  TextFormField(
                    initialValue: _description,
                    decoration: DecorationLibrary.inputDecoration(
                        'Description', context),
                    maxLines: 8,
                    onChanged: (value) => {_description = value},
                  ),
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
                            name: members.keys.elementAt(index),
                            isSelected: false,
                            onSwitch: (String name, bool value) {
                              members[name] = value;
                            },
                            onRemove: (String name) {
                              setState(() {
                                members.remove(name);
                              });
                            });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        OutlinedButton(
                          style:
                              outlinedButtonStyle, // shape: RoundedRectangleBorder
                          onPressed: () async {
                            final EmailContact contact =
                                await FlutterContactPicker.pickEmailContact(
                                    askForPermission: true);
                            setState(() {
                              members.addEntries(
                                  [MapEntry(contact.email.email, false)]);
                            });
                          },
                          child: Text("Add From Contacts"),
                        ),
                        OutlinedButton(
                          style: outlinedButtonStyle,
                          onPressed: () async {
                            String email = await _getMailManually(context);
                            if (email.isNotEmpty) {
                              setState(() {
                                members.addEntries(
                                    [MapEntry(email.toLowerCase(), false)]);
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
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Confirm"),
            content: Text("Create $_name?"),
            actions: [
              TextButton(
                onPressed: _uploadTeam,
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

  void _uploadTeam() async {
    if (Authentication().isAuth) {
      setState(() {
        _loading = true;
      });
      members.addEntries([
        MapEntry(Authentication().userEmail.toLowerCase(), true)
      ]); //set creator as admin

      HttpsCallableResult result =
          await FirebaseFirestoreCloudFunctions.addTeam(
              _name, _description, members, _imgPicked ? _picUrl : null);

      if (result.data["status"] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Team Added Successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding team!\n${result.data["messege"]}'),
          ),
        );
      }

      setState(() {
        _loading = false;
      });
      Navigator.of(context).pop();
    } else
      Applogger.consoleLog(MessegeType.error, "User is not connected");
  }
}
