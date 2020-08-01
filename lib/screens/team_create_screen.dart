import 'package:cloud_functions/cloud_functions.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:teamshare/providers/authentication.dart';

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
                      child: IconButton(
                          icon: Icon(
                            Icons.add_photo_alternate,
                            size: 50,
                          ),
                          onPressed: () {}),
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
          FlatButton(
            onPressed: () async => {
              await CloudFunctions.instance
                  .getHttpsCallable(functionName: "addTeam")
                  .call(<String, dynamic>{
                    "name": _name,
                    "description": _description,
                    "creatorEmail": await Authentication().userEmail,
                    "creatorName": await Authentication().userName,
                  })
                  .then((value) => print("Team Created"))
                  .catchError(
                      (e) => print("Failed to create team. ${e.toString()}"))
                  .whenComplete(
                    () => Navigator.of(context).pop(),
                  )
                  .then(
                    (value) => Navigator.of(context).pop(),
                  )
            },
            child: Text("Ok"),
          ),
          FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }
}