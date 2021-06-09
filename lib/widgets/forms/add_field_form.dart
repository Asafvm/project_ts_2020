import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teamshare/models/field.dart';
import 'package:teamshare/providers/applogger.dart';
import 'package:teamshare/providers/consts.dart';

class AddFieldForm extends StatefulWidget {
  final Field field;
  AddFieldForm(this.field);
  @override
  _AddFieldFormState createState() => _AddFieldFormState();
}

class _AddFieldFormState extends State<AddFieldForm> {
  final _fieldForm = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    switch (widget.field.type) {
      case FieldType.Text:
        return _buildGeneralField(context);
        break;
      case FieldType.Num:
        return _buildGeneralField(context);
        break;
      case FieldType.Date:
        return _buildDateField(context);
        break;
      case FieldType.Check:
        return _buildCheckboxField(context);
        break;
      case FieldType.Signature:
        return _buildSignatureField(context);
        break;
      default:
        return _buildGeneralField(context);
        break;
    }
  }

  SingleChildScrollView _buildGeneralField(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
          left: 10,
          top: 10,
          right: 10,
          bottom: MediaQuery.of(context).viewInsets.bottom + 10),
      child: Form(
        key: _fieldForm,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text(
              widget.field.type == FieldType.Text
                  ? 'Text Field'
                  : 'Numeric Field',
              textAlign: TextAlign.center,
            ),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    initialValue: widget.field.hint,
                    decoration: InputDecoration(labelText: 'Description'),
                    keyboardType: TextInputType.text,
                    onSaved: (val) {
                      widget.field.hint = val ?? '';
                    },
                    validator: (value) {
                      if (value.isEmpty) return "Enter field's name";
                      return null;
                    },
                  ),
                ),
                Row(
                  children: [
                    Text("Mandatory?"),
                    Switch.adaptive(
                      value: widget.field.isMandatory,
                      onChanged: (value) {
                        setState(() {
                          widget.field.isMandatory = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Flexible(
                  flex: 3,
                  child: TextFormField(
                    initialValue: widget.field.prefix,
                    decoration: InputDecoration(labelText: 'Prefix'),
                    keyboardType: TextInputType.text,
                    onSaved: (val) {
                      widget.field.prefix = val ?? '';
                    },
                  ),
                ),
                Spacer(),
                Flexible(
                  flex: 3,
                  child: TextFormField(
                    initialValue: widget.field.defaultValue,
                    decoration: InputDecoration(labelText: 'Default Value'),
                    keyboardType: widget.field.type == FieldType.Text
                        ? TextInputType.text
                        : TextInputType.number,
                    onSaved: (val) {
                      widget.field.defaultValue = val;
                    },
                    validator: (value) {
                      if (widget.field.type == FieldType.Num) {
                        try {
                          int.parse(value);
                        } catch (e) {
                          return "Numbers only";
                        }
                      }
                      return null;
                    },
                  ),
                ),
                Spacer(),
                Flexible(
                  flex: 3,
                  child: TextFormField(
                    initialValue: widget.field.suffix,
                    decoration: InputDecoration(labelText: 'Suffix'),
                    keyboardType: TextInputType.number,
                    onSaved: (val) {
                      widget.field.suffix = val;
                    },
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              child: TextButton(
                onPressed: () async {
                  FormState formState = _fieldForm.currentState;
                  if (formState != null) {
                    if (formState.validate()) {
                      formState.save();
                      Navigator.of(context)
                          .pop(widget.field); //retuen the new Field object}
                    }
                  } else {
                    Applogger.consoleLog(
                        MessegeType.error, 'Error saving form');
                  }
                },
                child: Text(
                  'Save Field',
                  style: TextStyle(color: Colors.white),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith(getColor),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxField(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
          left: 10,
          top: 10,
          right: 10,
          bottom: MediaQuery.of(context).viewInsets.bottom + 10),
      child: Form(
        key: _fieldForm,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            TextFormField(
              initialValue: widget.field.prefix,
              decoration: InputDecoration(labelText: 'Prefix'),
              keyboardType: TextInputType.text,
              validator: (value) => value.isEmpty ? 'Must not be empty' : null,
              onSaved: (val) {
                if (val.isEmpty) return 'Must not be empty';
                widget.field.hint = val;
                widget.field.prefix = val;
                return null;
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Check by default?"),
                Switch.adaptive(
                  value: widget.field.isMandatory,
                  onChanged: (value) {
                    setState(() {
                      widget.field.isMandatory = value;
                    });
                  },
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              child: TextButton(
                onPressed: () async {
                  FormState formState = _fieldForm.currentState;
                  if (formState != null) {
                    if (formState.validate()) {
                      formState.save();
                      Navigator.of(context)
                          .pop(widget.field); //retuen the new Field object}
                    }
                  } else {
                    Applogger.consoleLog(
                        MessegeType.error, 'Error saving form');
                  }
                },
                child: Text(
                  'Save Field',
                  style: TextStyle(color: Colors.white),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith(getColor),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
          left: 10,
          top: 10,
          right: 10,
          bottom: MediaQuery.of(context).viewInsets.bottom + 10),
      child: Form(
        key: _fieldForm,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 20),
          child: TextButton(
            onPressed: () async {
              FormState formState = _fieldForm.currentState;
              if (formState != null) {
                if (formState.validate()) {
                  formState.save();
                  Navigator.of(context)
                      .pop(widget.field); //retuen the new Field object}
                }
              } else {
                Applogger.consoleLog(MessegeType.error, 'Error saving form');
              }
            },
            child: Text(
              'Save Field',
              style: TextStyle(color: Colors.white),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith(getColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignatureField(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
          left: 10,
          top: 10,
          right: 10,
          bottom: MediaQuery.of(context).viewInsets.bottom + 10),
      child: Form(
        key: _fieldForm,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 20),
          child: TextButton(
            onPressed: () async {
              FormState formState = _fieldForm.currentState;
              if (formState != null) {
                if (formState.validate()) {
                  formState.save();
                  Navigator.of(context)
                      .pop(widget.field); //retuen the new Field object}
                }
              } else {
                Applogger.consoleLog(MessegeType.error, 'Error saving form');
              }
            },
            child: Text(
              'Save Field',
              style: TextStyle(color: Colors.white),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith(getColor),
            ),
          ),
        ),
      ),
    );
  }
}
