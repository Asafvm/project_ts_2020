import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teamshare/models/device.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';

class AddDeviceForm extends StatefulWidget {
  @override
  _AddDeviceFormState createState() => _AddDeviceFormState();
}

class _AddDeviceFormState extends State<AddDeviceForm> {
  bool _uploading = false;
  Device _newDevice = Device(
      manifacturer: "", codeName: "", reference: "", model: "", price: 0.0);
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
                      _newDevice = Device(
                        manifacturer: val,
                        codeName: _newDevice.codeName,
                        reference: _newDevice.reference,
                        model: _newDevice.model,
                        price: _newDevice.price,
                      );
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
                            _newDevice = Device(
                              manifacturer: _newDevice.manifacturer,
                              codeName: _newDevice.codeName,
                              reference: val,
                              model: _newDevice.model,
                              price: _newDevice.price,
                            );
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
                            _newDevice = Device(
                              manifacturer: _newDevice.manifacturer,
                              codeName: val,
                              reference: _newDevice.reference,
                              model: _newDevice.model,
                              price: _newDevice.price,
                            );
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
                            _newDevice = Device(
                              manifacturer: _newDevice.manifacturer,
                              codeName: _newDevice.codeName,
                              reference: _newDevice.reference,
                              model: val,
                              price: _newDevice.price,
                            );
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
                            _newDevice = Device(
                              manifacturer: _newDevice.manifacturer,
                              codeName: _newDevice.codeName,
                              reference: _newDevice.reference,
                              model: _newDevice.model,
                              price: double.parse(val),
                            );
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
                            await FirebaseFirestoreProvider()
                                .uploadDevice(_newDevice)
                                .then((_) async => await showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                              title: Text('Success!'),
                                              content:
                                                  Text('New device created!\n'),
                                              actions: <Widget>[
                                                FlatButton(
                                                  onPressed:
                                                      Navigator.of(context).pop,
                                                  child: Text('Ok'),
                                                ),
                                              ],
                                            ))
                                    .then((_) => Navigator.of(context).pop()));
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
                              _newDevice = null;
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
