import 'package:flutter/material.dart';
import 'package:teamshare/models/device_instance.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';

class AddDeviceInstanceForm extends StatefulWidget {
  final String deviceDocID;
  AddDeviceInstanceForm(this.deviceDocID);

  @override
  _AddDeviceInstanceFormState createState() => _AddDeviceInstanceFormState();
}

class _AddDeviceInstanceFormState extends State<AddDeviceInstanceForm> {
  bool _uploading = false;
  DeviceInstance _newDevice = DeviceInstance("0");

  final _deviceForm = GlobalKey<FormState>();

  Widget _buildTextFormField(
      String label, TextInputType type, Function onSave) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      keyboardType: type,
      onSaved: onSave,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _uploading
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: FittedBox(
                child: CircularProgressIndicator(),
              ),
            ),
          )
        : SingleChildScrollView(
            padding: EdgeInsets.only(
                left: 15,
                top: 5,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 10),
            child: Form(
              key: _deviceForm,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _buildTextFormField(
                    "Serial",
                    TextInputType.text,
                    (val) {
                      _newDevice = DeviceInstance(val);
                    },
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 20),
                      child: FlatButton(
                        onPressed: () async {
                          _deviceForm.currentState.save();
                          setState(() {
                            _uploading = true;
                          });
                          //send to server
                          try {
                            await FirebaseFirestoreProvider()
                                .uploadDeviceInstance(
                                    _newDevice, widget.deviceDocID)
                                .then((_) => Navigator.of(context).pop());
                          } catch (error) {
                            showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                      title: Text('Error!'),
                                      content: Text('Operation failed\n' +
                                          error.toString()),
                                      actions: <Widget>[
                                        FlatButton(
                                          onPressed: Navigator.of(context).pop,
                                          child: Text('Ok'),
                                        ),
                                      ],
                                    ));
                          } finally {
                            setState(() {
                              _uploading = false;
                            });
                          }
                        },
                        child: Text(
                          'Add New Device',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Theme.of(context).primaryColor,
                      ))
                ],
              ),
            ),
          );
  }
}
