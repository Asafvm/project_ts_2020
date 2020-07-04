import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teamshare/models/part.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';

class AddPartForm extends StatefulWidget {
  @override
  _AddPartFormState createState() => _AddPartFormState();
}

class _AddPartFormState extends State<AddPartForm> {
  bool _uploading = false;
  Part _newPart = Part(
    deviceId: "",
    manifacturer: "",
    serial: "",
    description: "",
  );
  final _PartForm = GlobalKey<FormState>();

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
              //TODO: recycler the addDevice form
              key: _PartForm,
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _buildTextFormField(
                    "Manifacturer",
                    TextInputType.text,
                    (val) {},
                  ),
                  Row(
                    children: <Widget>[
                      Flexible(
                        flex: 3,
                        child: _buildTextFormField(
                          "Code Number",
                          TextInputType.text,
                          (val) {},
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
                          (val) {},
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
                          (val) {},
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
                          (val) {},
                        ),
                      ),
                    ],
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 20),
                      child: FlatButton(
                        onPressed: () async {
                          _PartForm.currentState.save();
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
