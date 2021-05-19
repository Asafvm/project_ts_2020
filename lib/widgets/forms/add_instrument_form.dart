import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teamshare/helpers/decoration_library.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/providers/firebase_firestore_cloud_functions.dart';

class AddInstrumentForm extends StatefulWidget {
  @override
  _AddInstrumentFormState createState() => _AddInstrumentFormState();
}

class _AddInstrumentFormState extends State<AddInstrumentForm>
    with AutomaticKeepAliveClientMixin<AddInstrumentForm> {
  bool _uploading = false;
  Instrument _newInstrument = Instrument();
  final _instrumentForm = GlobalKey<FormState>();

  Widget _buildNameField() {
    return TextFormField(
      decoration: DecorationLibrary.inputDecoration("Instrument Name", context),
      keyboardType: TextInputType.text,
      onChanged: (value) => _newInstrument.setCodeName(value),
      onSaved: (val) {
        _newInstrument.setCodeName(val.trim());
      },
      validator: (value) {
        if (value.trim() == "") {
          return "An instrument must have a name";
        } else {
          return null;
        }
      },
      initialValue:
          (_newInstrument != null) ? _newInstrument.getCodeName() : "",
    );
  }

  Widget _buildCodeField() {
    return TextFormField(
      decoration:
          DecorationLibrary.inputDecoration("Reference Number", context),
      keyboardType: TextInputType.text,
      onChanged: (value) => _newInstrument.setReference(value),
      onSaved: (val) {
        _newInstrument.setReference(val.trim());
      },
      validator: (value) {
        if (value.trim() == "") {
          return "An instrument must have a unique reference";
        } else {
          return null;
        }
      },
      initialValue: _newInstrument != null ? _newInstrument.getReference() : "",
    );
  }

  Widget _buildManifacturerField() {
    return TextFormField(
      decoration: DecorationLibrary.inputDecoration("Manifacturer", context),
      keyboardType: TextInputType.text,
      onChanged: (val) {
        _newInstrument.setManifacturer(val);
      },
      onSaved: (val) {
        if (val.trim() == "") val = "Unknown";
        _newInstrument.setManifacturer(val);
      },
      initialValue:
          _newInstrument != null ? _newInstrument.getManifacturer() : "",
    );
  }

  Widget _buildModelField() {
    return TextFormField(
      decoration: DecorationLibrary.inputDecoration("Model", context),
      keyboardType: TextInputType.text,
      onChanged: (val) {
        _newInstrument.setModel(val);
      },
      onSaved: (val) {
        if (val.trim() == "") val = "1";
        _newInstrument.setModel(val);
      },
      initialValue: _newInstrument != null ? _newInstrument.getModel() : "",
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      decoration: DecorationLibrary.inputDecoration("Price", context),
      keyboardType:
          TextInputType.numberWithOptions(decimal: true, signed: false),
      onChanged: (val) {
        double price = double.tryParse(val) ?? 0.0;
        _newInstrument.setPrice(price);
      },
      onSaved: (val) {
        if (val.isEmpty) val = "0.0";
        double price = double.tryParse(val) ?? 0.0;
        _newInstrument.setPrice(price);
      },
      initialValue:
          _newInstrument != null ? _newInstrument.getPrice().toString() : "",
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      padding: EdgeInsets.only(
          left: 25,
          top: 5,
          right: 25,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Form(
        key: _instrumentForm,
        child: DefaultTabController(
          initialIndex: 0,
          length: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              tabbar, //defined in consts
              Container(
                height: 200,
                child: TabBarView(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        _buildNameField(),
                        _buildCodeField(),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        _buildManifacturerField(),
                        _buildModelField(),
                        _buildPriceField(),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: _uploading
                    ? CircularProgressIndicator()
                    : OutlinedButton(
                        onPressed: _uploadInstrument,
                        child: Text(
                          'Add New Instrument',
                        ),
                        style: outlinedButtonStyle,
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _uploadInstrument() async {
    FormState formState = _instrumentForm.currentState;

    if (formState != null && manualValidation()) {
      formState.save();
      setState(() {
        _uploading = true;
      });
      try {
        var result = await FirebaseFirestoreCloudFunctions.uploadInstrument(
                _newInstrument, Operation.CREATE)
            .then((_) async => {
                  Navigator.of(context).pop(),
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Instrument Added Successfully!'),
                    ),
                  ),
                });
        print(result);
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
          ),
        );
      } finally {
        setState(
          () {
            _uploading = false;
          },
        );
      }
    }
  }

  bool manualValidation() {
    if (_newInstrument.getReference().isEmpty ||
        _newInstrument.getCodeName().isEmpty) {
      return false;
    } else {
      if (_newInstrument.getManifacturer().isEmpty)
        _newInstrument.setManifacturer("Unknown");
      if (_newInstrument.getModel().isEmpty) _newInstrument.setModel("1");
      if (_newInstrument.getPrice().isNaN ||
          _newInstrument.getPrice().isNegative) _newInstrument.setPrice(0.0);
      return true;
    }
  }

  @override
  bool get wantKeepAlive => true;
}
