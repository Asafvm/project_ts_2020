import 'dart:io';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teamshare/providers/authentication.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspath;
import 'package:teamshare/providers/firebase_firestore_provider.dart';

enum STEPS { INFO, INVITE, CONFIRM }
int _currentStep = STEPS.INFO.index;
Iterable<Contact> contacts;
String _name = "";
String _description = "";

class TeamCreateScreen extends StatefulWidget {
  @override
  _TeamCreateScreenState createState() => _TeamCreateScreenState();
}

class _TeamCreateScreenState extends State<TeamCreateScreen> {
  bool _loading = false;
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
                    FlatButton(
                      onPressed: () => _changeStep(_currentStep + 1),
                      child: const Text('NEXT'),
                    ),
                  ] else if (_currentStep == STEPS.CONFIRM.index) //last step
                    ...[
                    FlatButton(
                      onPressed: () => _changeStep(_currentStep - 1),
                      child: const Text('BACK'),
                    ),
                    FlatButton(
                      onPressed: _createTeam,
                      child: const Text('FINISH'),
                    ),
                  ] else //any other step
                    ...[
                    FlatButton(
                      onPressed: () => _changeStep(_currentStep - 1),
                      child: const Text('BACK'),
                    ),
                    FlatButton(
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
                title: Text("Info"),
                content: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: FlatButton(
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
                            decoration:
                                InputDecoration(labelText: "Description"),
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
                    : StepState.indexed),
            Step(
                title: Text("Invite"),
                content: Container(),
                isActive: _currentStep == STEPS.INVITE.index ? true : false,
                state: _currentStep == STEPS.INVITE.index
                    ? StepState.editing
                    : StepState.indexed),
            Step(
                title: Text("Confirm"),
                content: Container(),
                isActive: _currentStep == STEPS.CONFIRM.index ? true : false,
                state: _currentStep == STEPS.CONFIRM.index
                    ? StepState.editing
                    : StepState.indexed),
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
      builder: (context) => AlertDialog(
        title: Text("Confirm"),
        content: Text("Create $_name?"),
        actions: [
          _loading
              ? CircularProgressIndicator()
              : FlatButton(
                  onPressed: () async => {
                    if (Authentication().isAuth)
                      {
                        _setLoading(),
                        //firebase.uploadToFirebase(Authentication().userEmail),

                        FirebaseFirestoreProvider.addTeam(_name, _description,
                                __imgPicked ? _picUrl : null)
                            .then(
                          (value) => Navigator.of(context).pop(),
                        ),
                      }
                    else
                      print("User is not connected")
                  },
                  child: Text("Ok"),
                ),
          FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
        ],
      ),
    ).then((value) => {Navigator.of(context).pop(), _setLoading()});
  }

  _setLoading() {
    setState(() {
      _loading = !_loading;
    });
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
}
