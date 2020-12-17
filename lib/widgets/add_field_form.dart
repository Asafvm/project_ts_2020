import 'package:flutter/material.dart';
import 'package:teamshare/models/field.dart';

//TODO: finish form

class AddFieldForm extends StatefulWidget {
  final Field field;
  AddFieldForm(this.field);
  @override
  _AddFieldFormState createState() => _AddFieldFormState();
}

class _AddFieldFormState extends State<AddFieldForm> {
  String _typeValue = 'Text';
  String _mandatoryValue = 'No';
  final _fieldForm = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
              initialValue: widget.field.hint,
              decoration: InputDecoration(labelText: 'Description'),
              keyboardType: TextInputType.text,
              onSaved: (val) {
                widget.field.hint = val;
              },
              validator: (value) {
                if (value.isEmpty) return "Enter field's name";
                return null;
              },
            ),
            Row(
              children: <Widget>[
                Flexible(
                  flex: 3,
                  child: TextFormField(
                    initialValue: widget.field.prefix,
                    decoration: InputDecoration(labelText: 'Prefix'),
                    keyboardType: TextInputType.number,
                    onSaved: (val) {
                      widget.field.prefix = val;
                    },
                  ),
                ),
                Spacer(
                  flex: 1,
                ),
                Flexible(
                  flex: 3,
                  child: TextFormField(
                    initialValue: widget.field.defaultValue,
                    decoration: InputDecoration(labelText: 'Default Value'),
                    keyboardType: TextInputType.number,
                    onSaved: (val) {
                      widget.field.defaultValue = val;
                    },
                    validator: (value) {
                      if (widget.field.isText) {
                        try {} catch (e) {
                          return "Text only";
                        }
                      } else {
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
                Spacer(
                  flex: 1,
                ),
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
            Row(
              children: <Widget>[
                Flexible(
                  flex: 3,
                  child: DropdownButtonFormField(
                    value: _typeValue,
                    decoration: InputDecoration(labelText: 'Input Type'),
                    onSaved: (val) {
                      widget.field.isText = (val == 'Text');
                    },
                    onChanged: (newValue) {
                      setState(() {
                        widget.field.isText = (newValue == 'Text');
                        _typeValue = newValue;
                      });
                    },
                    items: <String>['Text', 'Number', 'Decimal']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                Spacer(
                  flex: 1,
                ),
                Flexible(
                  flex: 3,
                  child: DropdownButtonFormField(
                    value: _mandatoryValue,
                    decoration: InputDecoration(labelText: 'Mandatory?'),
                    onSaved: (val) {
                      widget.field.isMandatory = (val == 'Yes');
                    },
                    onChanged: (String newValue) {
                      setState(() {
                        _mandatoryValue = newValue;
                        widget.field.isMandatory = (newValue == 'Yes');
                      });
                    },
                    items: <String>['Yes', 'No']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                child: FlatButton(
                  onPressed: () async {
                    if (_fieldForm.currentState.validate()) {
                      _fieldForm.currentState.save();
                      Navigator.of(context)
                          .pop(widget.field); //retuen the new Field object
                    }
                  },
                  child: Text(
                    'Save Field',
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
