import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';

class AddInstrumentForm extends StatefulWidget {
  @override
  _AddInstrumentFormState createState() => _AddInstrumentFormState();
}

class _AddInstrumentFormState extends State<AddInstrumentForm> {
  bool _uploading = false;
  Instrument _newInstrument;
  final _instrumentForm = GlobalKey<FormState>();

  Widget _buildTextFormField(
      String label, TextInputType type, Function onSave) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      keyboardType: type,
      onSaved: onSave,
    );
  }

  @override
  void initState() {
    _newInstrument = Instrument();
    super.initState();
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
              key: _instrumentForm,
              child: DefaultTabController(
                initialIndex: 0,
                length: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  //mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TabBar(
                      labelColor: Colors.black,
                      tabs: [
                        Tab(
                          text: "Required",
                        ),
                        Tab(
                          text: "Optional",
                        ),
                      ],
                    ),
                    Container(
                      height: 200,
                      child: TabBarView(
                        children: [
                          Column(
                            children: <Widget>[
                              Flexible(
                                flex: 3,
                                child: _buildTextFormField(
                                  'Instrument Name',
                                  TextInputType.text,
                                  (val) {
                                    _newInstrument.setCodeName(val);
                                  },
                                ),
                              ),
                              Flexible(
                                flex: 3,
                                child: _buildTextFormField(
                                  "Code Number",
                                  TextInputType.text,
                                  (val) {
                                    _newInstrument.setReference(val);
                                  },
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              _buildTextFormField(
                                "Manifacturer",
                                TextInputType.text,
                                (val) {
                                  _newInstrument.setManifacturer(val);
                                },
                              ),
                              Flexible(
                                flex: 3,
                                child: _buildTextFormField(
                                  "Model",
                                  TextInputType.text,
                                  (val) {
                                    _newInstrument.setModel(val);
                                  },
                                ),
                              ),
                              Flexible(
                                flex: 3,
                                child: _buildTextFormField(
                                  "price",
                                  TextInputType.numberWithOptions(
                                      decimal: true),
                                  (val) {
                                    double price = double.tryParse(val);
                                    _newInstrument
                                        .setPrice(price == null ? 0.0 : price);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.symmetric(vertical: 20),
                        child: FlatButton(
                          onPressed: () async {
                            if (_instrumentForm.currentState.validate()) {
                              _instrumentForm.currentState.save();
                              setState(() {
                                _uploading = true;
                              });
                              //send to server
                              try {
                                await FirebaseFirestoreProvider()
                                    .uploadInstrument(_newInstrument)
                                    .then((_) async => await showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                              title: Text('Success!'),
                                              content: Text(
                                                  'New Instrument created!\n'),
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
                                              onPressed:
                                                  Navigator.of(context).pop,
                                              child: Text('Ok'),
                                            ),
                                          ],
                                        ));
                              } finally {
                                setState(() {
                                  _uploading = false;
                                });
                              }
                            }
                          },
                          child: Text(
                            'Add New Instrument',
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Theme.of(context).primaryColor,
                        ))
                  ],
                ),
              ),
            ),
          );
  }
}
