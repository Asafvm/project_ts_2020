import 'package:flutter/material.dart';
import 'package:teamshare/helpers/decoration_library.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/providers/firebase_firestore_cloud_functions.dart';
import 'package:teamshare/widgets/form_title.dart';

class AddInstrumentInstanceForm extends StatefulWidget {
  final String instrumentId;
  AddInstrumentInstanceForm(this.instrumentId);

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
      decoration: DecorationLibrary.inputDecoration("Serial", context),
      keyboardType: TextInputType.text,
      onSaved: (val) {
        _newInstInstrument = InstrumentInstance.newInstrument(
            instrumentId: widget.instrumentId, serial: val);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(border: Border.all(width: 5)),
        padding: EdgeInsets.only(
            left: 5,
            right: 5,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Form(
          key: _instrumentForm,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              FormTitle(title: 'Add Instrument Details'),
              _buildSerialField(),
              Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                child: _uploading
                    ? FittedBox(
                        child: CircularProgressIndicator(),
                      )
                    : OutlinedButton(
                        child: Text(
                          'Add New Instrument',
                        ),
                        style: outlinedButtonStyle,
                        onPressed: _uploadInstance,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadInstance() async {
    FormState formState = _instrumentForm.currentState;
    if (formState != null) {
      formState.save();
      setState(() {
        _uploading = true;
      });
      //send to server
      try {
        var result =
            await FirebaseFirestoreCloudFunctions.uploadInstrumentInstance(
                _newInstInstrument, Operation.CREATE);
        Navigator.of(context).pop();

        if (result.data["status"] == "success")
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Instrument Added Successfully!'),
            ),
          );
        else
          throw result.data["messege"]["details"];
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
          _uploading = false;
        });
      }
    }
  }
}
