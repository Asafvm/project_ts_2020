import 'package:flutter/material.dart';
import 'package:teamshare/models/field.dart';

//TODO: finish form

class AddFieldForm extends StatefulWidget {
  // int index;
  // int page;
  // Offset offset;
  final Field field;
//  AddFieldForm(this.index, this.page, this.offset);
  AddFieldForm(this.field);
  @override
  _AddFieldFormState createState() => _AddFieldFormState();
}

class _AddFieldFormState extends State<AddFieldForm> {
  final double _defaultHeight = 20;
  final double _defaultWidth = 50;
  String _typeValue = 'Text';
  String _mandatoryValue = 'No';
  Field _newField;
  final _fieldForm = GlobalKey<FormState>();

  @override
  void initState() {
    if (widget.field != null) {
      _newField = widget.field;
      _typeValue = (_newField.isText) ? "Text" : "Number";
      _mandatoryValue = (_newField.isMandatory) ? "Yes" : "No";
    } else {
      _newField = Field(
          index: widget.field.index,
          page: widget.field.page,
          offset: widget.field.offset,
          size: Size(_defaultWidth, _defaultHeight),
          isMandatory: false,
          hint: "",
          isText: true,
          suffix: "",
          defaultIValue: 0,
          defaultSValue: "",
          prefix: "");
    }
    super.initState();
  }

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
              initialValue: _newField.hint,
              decoration: InputDecoration(labelText: 'Description'),
              keyboardType: TextInputType.text,
              onSaved: (val) {
                _newField.hint = val;
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
                    initialValue: _newField.prefix,
                    decoration: InputDecoration(labelText: 'Prefix'),
                    keyboardType: TextInputType.number,
                    onSaved: (val) {
                      _newField.prefix = val;
                    },
                  ),
                ),
                Spacer(
                  flex: 1,
                ),
                Flexible(
                  flex: 3,
                  child: TextFormField(
                    initialValue: (_newField.isText)
                        ? _newField.defaultSValue
                        : _newField.defaultIValue.toString(),
                    decoration: InputDecoration(labelText: 'Default Value'),
                    keyboardType: TextInputType.number,
                    onSaved: (val) {
                      if (_newField.isText)
                        _newField.defaultSValue = val;
                      else
                        _newField.defaultIValue = int.parse(val);
                    },
                    validator: (value) {
                      if (_newField.isText) {
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
                    initialValue: _newField.suffix,
                    decoration: InputDecoration(labelText: 'Suffix'),
                    keyboardType: TextInputType.number,
                    onSaved: (val) {
                      _newField.suffix = val;
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
                      _newField.isText = (val == 'Text');
                    },
                    onChanged: (newValue) {
                      setState(() {
                        _newField.isText = (newValue == 'Text');
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
                      _newField.isMandatory = (val == 'Yes');
                    },
                    onChanged: (String newValue) {
                      setState(() {
                        _mandatoryValue = newValue;
                        _newField.isMandatory = (newValue == 'Yes');
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
                          .pop(_newField); //retuen the new Field object
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
