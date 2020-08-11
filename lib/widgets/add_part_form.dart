import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/models/instrument.dart';
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
      InstrumentId: "",
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
    final InstrumentList = Provider.of<List<Instrument>>(context, listen: true);
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: IconButton(
                            icon: Icon(Icons.add_a_photo),
                            iconSize: 50,
                            onPressed: () {}),
                      ),
                      Flexible(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                                scrollPadding:
                                    EdgeInsets.symmetric(horizontal: 5),
                                decoration:
                                    InputDecoration(labelText: "Description"),
                                keyboardType: TextInputType.text,
                                onSaved: (val) {
                                  _newPart.setDescription(val);
                                }),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                _buildTextFormField(
                                  "Reference",
                                  TextInputType.text,
                                  (val) {
                                    _newPart.setReference(val);
                                  },
                                ),
                                _buildTextFormField(
                                  'Alt. Reference',
                                  TextInputType.text,
                                  (val) {
                                    _newPart.setAltreference(val);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
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
                        child: InstrumentList == null
                            ? Text(
                                "No Instruments listed",
                                style: TextStyle(color: Colors.red),
                              )
                            : DropdownButton(
                                items:
                                    InstrumentList.map((e) => DropdownMenuItem(
                                          child: Text(e.getCodeName()),
                                        )).toList(),
                                onChanged: (val) {}),
                      ),
                      // _buildTextFormField(
                      //   "Target Instrument",
                      //   TextInputType.text,
                      //   (val) {
                      //     _newPart.setInstrumentId(val);
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
