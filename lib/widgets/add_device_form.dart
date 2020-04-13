import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teamshare/models/device.dart';

import 'custom_textformfield.dart';

class AddDeviceForm extends StatefulWidget {
  @override
  _AddDeviceFormState createState() => _AddDeviceFormState();
}

class _AddDeviceFormState extends State<AddDeviceForm> {
  bool _uploading = false;
  Device _newDevice = Device(
      manifacturer: "", codeName: "", codeNumber: "", model: "", price: 0.0);
  final _deviceForm = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return _uploading
        ? Padding(
            padding: const EdgeInsets.all(20.0),
            child: FittedBox(child: CircularProgressIndicator()),
          )
        : SingleChildScrollView(
            padding: EdgeInsets.only(
                left: 10,
                top: 10,
                right: 10,
                bottom: MediaQuery.of(context).viewInsets.bottom + 10),
            child: Form(
              key: _deviceForm,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: CustomTextFormField(
                      label: 'Manifacturer',
                      keyType: TextInputType.text,
                      onSavedFunction: (val) {
                        _newDevice = Device(
                          manifacturer: val,
                          codeName: _newDevice.codeName,
                          codeNumber: _newDevice.codeNumber,
                          model: _newDevice.model,
                          price: _newDevice.price,
                        );
                      },
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Flexible(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: CustomTextFormField(
                            label: 'Code Number',
                            keyType: TextInputType.text,
                            onSavedFunction: (val) {
                              _newDevice = Device(
                                manifacturer: _newDevice.manifacturer,
                                codeName: _newDevice.codeName,
                                codeNumber: val,
                                model: _newDevice.model,
                                price: _newDevice.price,
                              );
                            },
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: CustomTextFormField(
                            label: 'Code Name',
                            keyType: TextInputType.text,
                            onSavedFunction: (val) {
                              _newDevice = Device(
                                manifacturer: _newDevice.manifacturer,
                                codeName: val,
                                codeNumber: _newDevice.codeNumber,
                                model: _newDevice.model,
                                price: _newDevice.price,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Flexible(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: CustomTextFormField(
                            label: 'Model',
                            keyType: TextInputType.text,
                            onSavedFunction: (val) {
                              _newDevice = Device(
                                manifacturer: _newDevice.manifacturer,
                                codeName: _newDevice.codeName,
                                codeNumber: _newDevice.codeNumber,
                                model: val,
                                price: _newDevice.price,
                              );
                            },
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: CustomTextFormField(
                            label: 'price',
                            keyType:
                                TextInputType.numberWithOptions(decimal: true),
                            onSavedFunction: (val) {
                              _newDevice = Device(
                                manifacturer: _newDevice.manifacturer,
                                codeName: _newDevice.codeName,
                                codeNumber: _newDevice.codeNumber,
                                model: _newDevice.model,
                                price: double.parse(val),
                              );
                            },
                          ),
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
                            await _uploadDevice();
                          } catch (error) {
                            showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                      title: Text('Error!'),
                                      content: Text('Operation failed\n' +
                                          error.toString()),
                                      actions: <Widget>[
                                        FlatButton(
                                            onPressed:
                                                Navigator.of(context).pop,
                                            child: Text('Ok'))
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

  Future<void> _uploadDevice() async {
    await CloudFunctions.instance
        .getHttpsCallable(functionName: "addDevice")
        .call(<String, dynamic>{
      "manifacturer": _newDevice.manifacturer,
      "codeName": _newDevice.codeName,
      "codeNumber": _newDevice.codeNumber,
      "model": _newDevice.model,
      "price": _newDevice.price,
    });
  }
}
