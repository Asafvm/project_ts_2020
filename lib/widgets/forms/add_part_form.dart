import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/part.dart';
import 'package:teamshare/providers/consts.dart';
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
      instrumentId: "",
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
  StreamSubscription<List<Instrument>> subscription;
  List<Instrument> instrumentList = List.empty();

  Widget _buildDescFormField() {
    return TextFormField(
      decoration: InputDecoration(labelText: "Description"),
      keyboardType: TextInputType.text,
      onSaved: (val) {
        _newPart.setDescription(val);
      },
    );
  }

  Widget _buildMinStorageFormField() {
    return TextFormField(
      decoration: InputDecoration(labelText: "Main Storage Min"),
      keyboardType: TextInputType.number,
      onSaved: (val) {
        int min = int.tryParse(val) ?? 0;
        _newPart.setmainStockMin(min);
      },
    );
  }

  Widget _buildPerStorageFormField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Personal Storage Min'),
      keyboardType: TextInputType.number,
      onSaved: (val) {
        int min = int.tryParse(val) ?? 0;
        _newPart.setpersonalStockMin(min);
      },
    );
  }

  Widget _buildRefFormField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Reference'),
      keyboardType: TextInputType.text,
      onSaved: (val) {
        _newPart.setReference(val);
      },
    );
  }

  Widget _buildAltRefFormField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Alt. Reference'),
      keyboardType: TextInputType.text,
      onSaved: (val) {
        _newPart.setAltreference(val);
      },
    );
  }

  Widget _buildManFormField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Manifacturer'),
      keyboardType: TextInputType.text,
      onSaved: (val) {
        _newPart.setManifacturer(val);
      },
    );
  }

  Widget _buildModelFormField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Model'),
      keyboardType: TextInputType.text,
      onSaved: (val) {
        _newPart.setModel(val);
      },
    );
  }

  Widget _buildPriceFormField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Price'),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      onSaved: (val) {
        var price = double.tryParse(val) ?? 0.0;
        _newPart.setPrice(price);
      },
    );
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    subscription = FirebaseFirestoreProvider.getInstruments().listen((event) {
      setState(() {
        instrumentList = event;
        subscription.cancel();
      });
    });

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
                left: 5,
                right: 5,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20),
            child: Form(
              key: _partForm,
              child: DefaultTabController(
                initialIndex: 0,
                length: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    tabbar, //defined in consts
                    SizedBox(
                      height: 200,
                      child: TabBarView(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    flex: 1,
                                    fit: FlexFit.tight,
                                    child: IconButton(
                                      icon: Icon(Icons.add_a_photo),
                                      iconSize: 50,
                                      onPressed: () {},
                                    ),
                                  ),
                                  Flexible(
                                    flex: 3,
                                    fit: FlexFit.tight,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _buildDescFormField(),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Expanded(
                                                child: _buildRefFormField()),
                                            Expanded(
                                                child: _buildAltRefFormField()),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(child: _buildMinStorageFormField()),
                                  Expanded(child: _buildPerStorageFormField()),
                                ],
                              ),
                              Expanded(
                                flex: 3,
                                child: instrumentList.isEmpty
                                    ? Text(
                                        "No Instruments listed",
                                        style: TextStyle(color: Colors.red),
                                      )
                                    : DropdownButton(
                                        hint: Text("Device"),
                                        items: instrumentList
                                            .map((e) =>
                                                DropdownMenuItem<String>(
                                                  child: Text(e.getCodeName()),
                                                ))
                                            .toList(),
                                        onChanged: (val) {},
                                      ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Row(
                                children: <Widget>[
                                  Expanded(child: _buildManFormField()),
                                  Expanded(child: _buildModelFormField()),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(child: _buildPriceFormField())
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
                            ],
                          ),
                        ],
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.symmetric(vertical: 20),
                      child: TextButton(
                        onPressed: _addPart,
                        child: Text(
                          'Add New Part',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  void _addPart() async {
    {
      FormState formState = _partForm.currentState;
      if (formState != null) {
        formState.save();
        setState(() {
          _uploading = true;
        });
        //send to server
        try {
          await FirebaseFirestoreProvider.uploadPart(_newPart)
              .then((_) async => await showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                        title: Text('Success!'),
                        content: Text('New Part created!\n'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: Navigator.of(context).pop,
                            child: Text('Ok'),
                          ),
                        ],
                      )).then((_) => Navigator.of(context).pop()));
        } catch (error) {
          showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                    title: Text('Error!'),
                    content: Text('Operation failed\n' + error.toString()),
                    actions: <Widget>[
                      TextButton(
                        onPressed: Navigator.of(context).pop,
                        child: Text('Ok'),
                      ),
                    ],
                  ));
        } finally {
          setState(() {
            _newPart = Part(
                manifacturer: "",
                reference: "",
                altreference: "",
                instrumentId: "",
                model: "",
                description: "",
                price: 0.0,
                mainStockMin: 0,
                personalStockMin: 0,
                serialTracking: false,
                active: true);
            _uploading = false;
          });
        }
      }
    }
    ;
  }
}
