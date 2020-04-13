import 'package:flutter/material.dart';
import 'package:teamshare/models/field.dart';

//TODO: finish form

class AddFieldForm extends StatefulWidget {
  final int index;
  final int page;
  final Offset offset;
  AddFieldForm(this.index, this.page, this.offset);

  @override
  _AddFieldFormState createState() => _AddFieldFormState();
}

class _AddFieldFormState extends State<AddFieldForm> {
  double _defaultHeight = 20;
  double _defaultWidth = 50;
  Field _newField = Field(
      index: -1,
      page: 0,
      offset: Offset(0, 0),
      size: Size(0, 0),
      isMandatory: false,
      hint: "",
      isText: true,
      suffix: "",
      defaultIValue: 0,
      defaultSValue: "",
      prefix: "");
  final _fieldForm = GlobalKey<FormState>();

  @override
  void initState() {
    _newField = Field(
        index: widget.index,
        page: widget.page,
        offset: widget.offset,
        size: Size(_defaultWidth, _defaultHeight),
        isMandatory: false,
        hint: "",
        isText: true,
        suffix: "",
        defaultIValue: 0,
        defaultSValue: "",
        prefix: "");
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
              initialValue: "",
              decoration: InputDecoration(labelText: 'Description'),
              keyboardType: TextInputType.number,
              onSaved: (val) {
                _newField = Field(
                  index: _newField.index,
                  hint: val,
                  page: _newField.page,
                  offset: _newField.offset,
                  size: _newField.size,
                  regexp: _newField.regexp,
                  prefix: _newField.prefix,
                  suffix: _newField.suffix,
                  isText: _newField.isText,
                  isMandatory: _newField.isMandatory,
                );
              },
            ),
            Row(
              children: <Widget>[
                Flexible(
                  flex: 3,
                  child: TextFormField(
                    initialValue: "",
                    decoration: InputDecoration(labelText: 'Prefix'),
                    keyboardType: TextInputType.number,
                    onSaved: (val) {
                      _newField = Field(
                        index: _newField.index,
                        hint: _newField.hint,
                        page: _newField.page,
                        offset: _newField.offset,
                        size: _newField.size,
                        regexp: _newField.regexp,
                        prefix: val,
                        suffix: _newField.suffix,
                        isText: _newField.isText,
                        isMandatory: _newField.isMandatory,
                      );
                    },
                  ),
                ),
                Spacer(
                  flex: 1,
                ),
                Flexible(
                  flex: 3,
                  child: TextFormField(
                    initialValue: "",
                    decoration: InputDecoration(labelText: 'Default Value'),
                    keyboardType: TextInputType.number,
                    onSaved: (val) {
                      _newField = Field(
                        index: _newField.index,
                        hint: _newField.hint,
                        page: _newField.page,
                        offset: _newField.offset,
                        size: _newField.size,
                        regexp: _newField.regexp,
                        prefix: val,
                        suffix: _newField.suffix,
                        isText: _newField.isText,
                        isMandatory: _newField.isMandatory,
                      );
                    },
                  ),
                ),
                Spacer(
                  flex: 1,
                ),
                Flexible(
                  flex: 3,
                  child: TextFormField(
                    initialValue: "",
                    decoration: InputDecoration(labelText: 'Suffix'),
                    keyboardType: TextInputType.number,
                    onSaved: (val) {
                      _newField = Field(
                        index: _newField.index,
                        hint: _newField.hint,
                        page: _newField.page,
                        offset: _newField.offset,
                        size: _newField.size,
                        regexp: _newField.regexp,
                        prefix: _newField.prefix,
                        suffix: val,
                        isText: _newField.isText,
                        isMandatory: _newField.isMandatory,
                      );
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
                    value: 'Text',
                    decoration: InputDecoration(labelText: 'Input Type'),
                    onSaved: (val) {
                      _newField = Field(
                        index: _newField.index,
                        hint: val,
                        page: _newField.page,
                        offset: _newField.offset,
                        size: _newField.size,
                        regexp: _newField.regexp,
                        prefix: _newField.prefix,
                        suffix: _newField.suffix,
                        isText: _newField.isText,
                        isMandatory: _newField.isMandatory,
                      );
                    },
                    onChanged: (String newValue) {
                      setState(() {
                        _newField = Field(
                          index: _newField.index,
                          hint: _newField.hint,
                          page: _newField.page,
                          offset: _newField.offset,
                          size: _newField.size,
                          regexp: _newField.regexp,
                          prefix: _newField.prefix,
                          suffix: _newField.suffix,
                          isText: newValue == "Text",
                          isMandatory: _newField.isMandatory,
                        );
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
                    value: 'No',
                    decoration: InputDecoration(labelText: 'Mandatory?'),
                    onSaved: (val) {
                      _newField = Field(
                        index: _newField.index,
                        hint: _newField.hint,
                        page: _newField.page,
                        offset: _newField.offset,
                        size: _newField.size,
                        regexp: _newField.regexp,
                        prefix: _newField.prefix,
                        suffix: _newField.suffix,
                        isText: _newField.isText,
                        isMandatory: _newField.isMandatory,
                      );
                    },
                    onChanged: (String newValue) {
                      setState(() {
                        _newField = Field(
                          index: _newField.index,
                          hint: _newField.hint,
                          page: _newField.page,
                          offset: _newField.offset,
                          size: _newField.size,
                          regexp: _newField.regexp,
                          prefix: _newField.prefix,
                          suffix: _newField.suffix,
                          isText: _newField.isText,
                          isMandatory: newValue == 'Yes',
                        );
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
                    _fieldForm.currentState.save();
                    Navigator.of(context)
                        .pop(_newField); //retuen the new Field object
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
