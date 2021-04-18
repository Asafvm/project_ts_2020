import 'package:flutter/material.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/providers/firebase_firestore_cloud_functions.dart';

class AddInstrumentInstanceForm extends StatefulWidget {
  final String instrumentCodeName;
  AddInstrumentInstanceForm(this.instrumentCodeName);

  @override
  _AddInstrumentInstanceFormState createState() =>
      _AddInstrumentInstanceFormState();
}

class _AddInstrumentInstanceFormState extends State<AddInstrumentInstanceForm> {
  bool _uploading = false;
  InstrumentInstance _newInstInstrument;

  final _instrumentForm = GlobalKey<FormState>();

  Widget _buildSerialField() {
    return TextFormField(
      decoration: InputDecoration(labelText: "Serial"),
      keyboardType: TextInputType.text,
      onSaved: (val) {
        _newInstInstrument = InstrumentInstance.newInstrument(
            instrumentCode: widget.instrumentCodeName, serial: val);
      },
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
              key: _instrumentForm,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _buildSerialField(),
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 20),
                      child: TextButton(
                        onPressed: () async {
                          FormState formState = _instrumentForm.currentState;
                          if (formState != null) {
                            formState.save();
                            setState(() {
                              _uploading = true;
                            });
                            //send to server
                            try {
                              await FirebaseFirestoreCloudFunctions
                                      .uploadInstrumentInstance(
                                          _newInstInstrument)
                                  .then((_) => Navigator.of(context).pop());
                            } catch (error) {
                              showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                        title: Text('Error!'),
                                        content: Text('Operation failed\n' +
                                            error.toString()),
                                        actions: <Widget>[
                                          TextButton(
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
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith(getColor),
                        ),
                      ))
                ],
              ),
            ),
          );
  }
}
