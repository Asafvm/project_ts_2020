import 'package:flutter/material.dart';

class AddDeviceInstanceForm extends StatefulWidget {
  @override
  _AddDeviceInstanceFormState createState() => _AddDeviceInstanceFormState();
}

class _AddDeviceInstanceFormState extends State<AddDeviceInstanceForm> {
  //TODO: fix everything


    bool _uploading = false;
    
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
                // mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _buildTextFormField(
                    "Manifacturer",
                    TextInputType.text,
                    (val) {
                      // _newDevice = Device(
                      //   manifacturer: val,
                      //   codeName: _newDevice.codeName,
                      //   codeNumber: _newDevice.codeNumber,
                      //   model: _newDevice.model,
                      //   price: _newDevice.price,
                      //);
                    },
                  ),
                  Row(
                    children: <Widget>[
                      Flexible(
                        flex: 3,
                        child: _buildTextFormField(
                          "Code Number",
                          TextInputType.text,
                          (val) {
                            // _newDevice = Device(
                            //   manifacturer: _newDevice.manifacturer,
                            //   codeName: _newDevice.codeName,
                            //   codeNumber: val,
                            //   model: _newDevice.model,
                            //   price: _newDevice.price,
                            //);
                          },
                        ),
                      ),
                      Spacer(
                        flex: 1,
                      ),
                      Flexible(
                        flex: 3,
                        child: _buildTextFormField(
                          'Code Name',
                          TextInputType.text,
                          (val) {
                            // _newDevice = Device(
                            //   manifacturer: _newDevice.manifacturer,
                            //   codeName: val,
                            //   codeNumber: _newDevice.codeNumber,
                            //   model: _newDevice.model,
                            //   price: _newDevice.price,
                            // );
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Flexible(
                        flex: 3,
                        child: _buildTextFormField(
                          "Model",
                          TextInputType.text,
                          (val) {
                            // _newDevice = Device(
                            //   manifacturer: _newDevice.manifacturer,
                            //   codeName: _newDevice.codeName,
                            //   codeNumber: _newDevice.codeNumber,
                            //   model: val,
                            //   price: _newDevice.price,
                            // );
                          },
                        ),
                      ),
                      Spacer(
                        flex: 1,
                      ),
                      Flexible(
                        flex: 3,
                        child: _buildTextFormField(
                          "price",
                          TextInputType.numberWithOptions(decimal: true),
                          (val) {
                            // _newDevice = Device(
                            //   manifacturer: _newDevice.manifacturer,
                            //   codeName: _newDevice.codeName,
                            //   codeNumber: _newDevice.codeNumber,
                            //   model: _newDevice.model,
                            //   price: double.parse(val),
                            // );
                          },
                        ),
                      ),
                    ],
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
                            //await _uploadDevice();
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

  // Future<void> _uploadDevice() async {
  //   await CloudFunctions.instance
  //       .getHttpsCallable(functionName: "addDevice")
  //       .call(<String, dynamic>{"device": _newDevice.toJson()})
  //       .then((value) => print("then: " + value.data.toString()))
  //       .catchError((e) => print("error: " + e.toString()))
  //       .whenComplete(() => Navigator.of(context).pop()); //close pop up window
  // }
}