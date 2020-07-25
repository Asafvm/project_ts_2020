import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/models/device.dart';
import 'package:teamshare/models/part.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';

class AddPartForm extends StatefulWidget {
  @override
  _AddPartFormState createState() => _AddPartFormState();
}

class _AddPartFormState extends State<AddPartForm> {
  bool _uploading = false;
  Part _newPart = Part(
      manifacturer: "",
      reference: "",
      altreference: "",
      deviceId: "",
      model: "",
      description: "",
      price: 0.0,
      mainStockMin: 0,
      personalStockMin: 0,
      serialTracking: false,
      active: true);

  final _partForm = GlobalKey<FormState>();
  var _isTracking = false;
  var _isActive = true;

  Widget _buildTextFormField(
      String label, TextInputType type, Function onSave) {
    return Flexible(
      flex: 3,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: TextFormField(
          decoration: InputDecoration(labelText: label),
          keyboardType: type,
          onSaved: onSave,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceList = Provider.of<List<Device>>(context, listen: true);
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
              //TODO: recycle the addDevice form
              key: _partForm,
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  TextFormField(
                      decoration: InputDecoration(labelText: "Description"),
                      keyboardType: TextInputType.text,
                      onSaved: (val) {
                        _newPart.setDescription(val);
                      }),
                  Row(
                    children: <Widget>[
                      _buildTextFormField(
                        "Reference",
                        TextInputType.text,
                        (val) {
                          _newPart.setReference(val);
                        },
                      ),
                      _buildTextFormField(
                        'Alternative Reference',
                        TextInputType.text,
                        (val) {
                          _newPart.setAltreference(val);
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      _buildTextFormField(
                        "Manifacturer",
                        TextInputType.text,
                        (val) {
                          _newPart.setManifacturer(val);
                        },
                      ),
                      _buildTextFormField(
                        'Model',
                        TextInputType.text,
                        (val) {
                          _newPart.setModel(val);
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: DropdownButton(
                            items: deviceList
                                .map((e) => DropdownMenuItem(
                                    child: Text(e.getCodeName())))
                                .toList(),
                            //TODO: update value
                            onChanged: (val) {}),
                      ),
                      // _buildTextFormField(
                      //   "Target Device",
                      //   TextInputType.text,
                      //   (val) {
                      //     _newPart.setDeviceId(val);
                      //   },
                      // ),
                      _buildTextFormField(
                        "price",
                        TextInputType.numberWithOptions(decimal: true),
                        (val) {
                          var price = double.tryParse(val);
                          _newPart.setPrice(price == null ? 0.0 : price);
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      _buildTextFormField(
                        "Main Storage Min",
                        TextInputType.number,
                        (val) {
                          int min = int.tryParse(val);
                          _newPart.setmainStockMin(min == null ? 0 : min);
                        },
                      ),
                      _buildTextFormField(
                        'Personal Storage Min',
                        TextInputType.number,
                        (val) {
                          int min = int.tryParse(val);
                          _newPart.setpersonalStockMin(min == null ? 0 : min);
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: SwitchListTile(
                          title: Text("Track Serials"),
                          value: _isTracking,
                          onChanged: (val) {
                            setState(() {
                              _isTracking = val;
                              _newPart.serialTracking = val;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: SwitchListTile(
                            title: Text("Active"),
                            value: _isActive,
                            onChanged: (val) {
                              setState(() {
                                _isActive = val;
                                _newPart.setActive(val);
                              });
                            }),
                      ),
                    ],
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 20),
                      child: FlatButton(
                        onPressed: () async {
                          _partForm.currentState.save();
                          setState(() {
                            _uploading = true;
                          });
                          //send to server
                          try {
                            await FirebaseFirestoreProvider()
                                .uploadPart(_newPart)
                                .then((_) async => await showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                          title: Text('Success!'),
                                          content: Text('New Part created!\n'),
                                          actions: <Widget>[
                                            FlatButton(
                                              onPressed:
                                                  Navigator.of(context).pop,
                                              child: Text('Ok'),
                                            ),
                                          ],
                                        )).then(
                                    (_) => Navigator.of(context).pop()));
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
                              _newPart = null;
                              _uploading = false;
                            });
                          }
                        },
                        child: Text(
                          'Add New Part',
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
