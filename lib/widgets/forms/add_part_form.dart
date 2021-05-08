import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/part.dart';
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/providers/firebase_firestore_cloud_functions.dart';

class AddPartForm extends StatefulWidget {
  final Part part;

  AddPartForm({this.part});
  @override
  _AddPartFormState createState() => _AddPartFormState();
}

class _AddPartFormState extends State<AddPartForm>
    with AutomaticKeepAliveClientMixin<AddPartForm> {
  bool _uploading = false;
  Part _newPart = Part(
      manifacturer: "",
      reference: "",
      altreference: "",
      instrumentId: [],
      model: "",
      description: "",
      price: 0.0,
      mainStockMin: 0,
      personalStockMin: 0,
      serialTracking: false,
      active: true);

  final _partForm = GlobalKey<FormState>();
  List<Instrument> instrumentList = List.empty();
  List<bool> instrumentListCheck = List<bool>.empty();

  int _selectedInstruments = 0;

  Widget _buildDescFormField() {
    return TextFormField(
      decoration: InputDecoration(labelText: "Description"),
      keyboardType: TextInputType.text,
      onChanged: (value) => _newPart.description = value,
      initialValue: (_newPart != null) ? _newPart.description : "",
      onSaved: (val) {
        _newPart.setDescription(val);
      },
      validator: (value) {
        if (value.trim().isEmpty) return "Mandatory field";
        return null;
      },
    );
  }

  Widget _buildMinStorageFormField() {
    return TextFormField(
      decoration: InputDecoration(labelText: "Main Storage Min"),
      keyboardType: TextInputType.number,
      onChanged: (value) => _newPart.mainStockMin = int.tryParse(value) ?? 0,
      initialValue: (_newPart != null) ? _newPart.mainStockMin.toString() : "",
      onSaved: (val) {
        int min = int.tryParse(val) ?? 0;
        _newPart.setmainStockMin(min);
      },
      validator: (value) {
        int number = int.tryParse(value);
        if (number == null)
          return "Mandatory field!";
        else if (number < 0) return "Illegal input";
        return null;
      },
    );
  }

  Widget _buildPerStorageFormField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Personal Storage Min'),
      keyboardType: TextInputType.number,
      onChanged: (value) =>
          _newPart.personalStockMin = int.tryParse(value) ?? 0,
      initialValue:
          (_newPart != null) ? _newPart.personalStockMin.toString() : "",
      onSaved: (val) {
        int min = int.tryParse(val) ?? 0;
        _newPart.setpersonalStockMin(min);
      },
      validator: (value) {
        int number = int.tryParse(value);
        if (number == null)
          return "Mandatory field!";
        else if (number < 0) return "Illegal input";
        return null;
      },
    );
  }

  Widget _buildRefFormField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Reference'),
      keyboardType: TextInputType.text,
      onChanged: (value) => _newPart.reference = value,
      initialValue: (_newPart != null) ? _newPart.reference : "",
      onSaved: (val) {
        _newPart.setReference(val);
      },
      validator: (value) {
        if (value.trim().isEmpty) return "Mandatory field";
        return null;
      },
    );
  }

  Widget _buildAltRefFormField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Alt. Reference'),
      keyboardType: TextInputType.text,
      onChanged: (value) => _newPart.altreference = value,
      initialValue: (_newPart != null) ? _newPart.altreference : "",
      onSaved: (val) {
        _newPart.setAltreference(val);
      },
    );
  }

  Widget _buildManFormField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Manifacturer'),
      keyboardType: TextInputType.text,
      onChanged: (value) => _newPart.manifacturer = value,
      initialValue: (_newPart != null) ? _newPart.manifacturer : "",
      onSaved: (val) {
        _newPart.setManifacturer(val);
      },
    );
  }

  Widget _buildModelFormField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Model'),
      keyboardType: TextInputType.text,
      onChanged: (value) => _newPart.model = value,
      initialValue: (_newPart != null) ? _newPart.model : "",
      onSaved: (val) {
        _newPart.setModel(val);
      },
    );
  }

  Widget _buildPriceFormField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Price'),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      onChanged: (value) => _newPart.price = double.tryParse(value) ?? 0,
      initialValue: (_newPart != null) ? _newPart.price.toString() : "",
      onSaved: (val) {
        var price = double.tryParse(val) ?? 0.0;
        _newPart.setPrice(price);
      },
      validator: (value) {
        if (value.trim().isEmpty) return null;
        double number = double.tryParse(value);
        if (number == null)
          return "Illegal input!";
        else if (number < 0) return "Illegal input";
        return null;
      },
    );
  }

  @override
  void initState() {
    if (widget.part != null) _newPart = widget.part;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    instrumentList = Provider.of<List<Instrument>>(context);
    _initInstrumentChecks();
    _selectedInstruments =
        instrumentListCheck.where((element) => element == true).length;

    var reqTab = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: IconButton(
                icon: Icon(Icons.add_a_photo),
                iconSize: 50,
                onPressed: () {},
              ),
            ),
            Flexible(
              flex: 3,
              fit: FlexFit.tight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDescFormField(),
                  _buildRefFormField(),
                ],
              ),
            )
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(child: _buildMinStorageFormField()),
            Expanded(child: _buildPerStorageFormField()),
          ],
        ),
      ],
    );
    var optTab = Column(
      children: [
        Row(
          children: <Widget>[
            Expanded(child: _buildManFormField()),
            Expanded(child: _buildModelFormField()),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(child: _buildAltRefFormField()),
            Expanded(child: _buildPriceFormField())
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: SwitchListTile(
                title: Text("Track Serials"),
                value: _newPart.serialTracking,
                onChanged: (val) {
                  setState(() {
                    _newPart.serialTracking = val;
                  });
                },
              ),
            ),
            Expanded(
              child: SwitchListTile(
                  title: Text("Active"),
                  value: _newPart.active,
                  onChanged: (val) {
                    setState(() {
                      _newPart.setActive(val);
                    });
                  }),
            ),
          ],
        ),
        Expanded(
          flex: 3,
          child: instrumentList.isEmpty
              ? Text(
                  "No Instruments listed",
                  style: TextStyle(color: Colors.red),
                )
              : DropdownButton(
                  hint: Text('$_selectedInstruments selected'),
                  items: instrumentList
                      .map((e) => DropdownMenuItem<String>(
                            child: StatefulBuilder(
                              builder: (context, setState) {
                                return Row(
                                  children: [
                                    Checkbox(
                                      value: instrumentListCheck[
                                          instrumentList.indexOf(e)],
                                      onChanged: (value) {
                                        setState.call(() {
                                          if (value) {
                                            setState(() {
                                              _newPart.instrumentId
                                                  .add(e.getCodeName());
                                              _selectedInstruments++;
                                            });
                                          } else {
                                            setState(() {
                                              _newPart.instrumentId
                                                  .remove(e.getCodeName());

                                              _selectedInstruments--;
                                            });
                                          }
                                          instrumentListCheck[instrumentList
                                              .indexOf(e)] = value;
                                        });
                                      },
                                    ),
                                    Text(e.getCodeName()),
                                  ],
                                );
                              },
                            ),
                          ))
                      .toList(),
                  onChanged: (_) {
                    setState(() {});
                  },
                ),
        ),
      ],
    );

    return SingleChildScrollView(
      child: Form(
        key: _partForm,
        child: DefaultTabController(
          initialIndex: 0,
          length: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              tabbar, //defined in consts
              Container(
                padding: const EdgeInsets.all(10),
                height: 250,
                child: TabBarView(
                  children: [
                    //REQUIRED TAB
                    reqTab,
                    //OPTIONAL TAB
                    optTab,
                  ],
                ),
              ),

              Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                child: _uploading
                    ? CircularProgressIndicator()
                    : OutlinedButton(
                        onPressed: _addPart,
                        child: Text(
                          widget.part == null ? 'Add New Part' : 'Update Part',
                        ),
                        style: outlinedButtonStyle,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addPart() async {
    {
      FormState formState = _partForm.currentState;
      if (formState != null && formState.validate()) {
        formState.save();
        setState(() {
          _uploading = true;
        });
        // send to server
        try {
          if (widget.part == null)
            await FirebaseFirestoreCloudFunctions.uploadPart(_newPart)
                .then((_) async => {
                      Navigator.of(context).pop(),
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Part Added Successfully!'),
                        ),
                      ),
                    });
          else
            await FirebaseFirestoreCloudFunctions.updatePart(_newPart)
                .then((_) async => {
                      Navigator.of(context).pop(),
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Part Updated Successfully!'),
                        ),
                      ),
                    });
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
            _newPart = Part(
                manifacturer: "",
                reference: "",
                altreference: "",
                instrumentId: [],
                model: "",
                description: "",
                price: 0.0,
                mainStockMin: 0,
                personalStockMin: 0,
                serialTracking: false,
                active: true);
            _uploading = false;
          });
        }
      }
    }
  }

  void _initInstrumentChecks() {
    if (instrumentListCheck.length != instrumentList.length) {
      instrumentListCheck = List<bool>.filled(instrumentList.length, false);
    }
    if (widget.part != null)
      instrumentList.forEach((instrument) =>
          instrumentListCheck[instrumentList.indexOf(instrument)] =
              widget.part.instrumentId.contains(instrument.codeName));
  }

  @override
  bool get wantKeepAlive => true;
}
