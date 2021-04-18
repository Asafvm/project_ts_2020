import 'package:flutter/material.dart';
import 'package:teamshare/models/site.dart';
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/providers/firebase_firestore_cloud_functions.dart';

class AddRoomForm extends StatefulWidget {
  final String siteId;

  const AddRoomForm({this.siteId});
  @override
  _AddRoomFormState createState() => _AddRoomFormState();
}

class _AddRoomFormState extends State<AddRoomForm> {
  bool _uploading = false;
  Room _newRoom;

  @override
  void initState() {
    _newRoom = Room();
    super.initState();
  }

  final _roomForm = GlobalKey<FormState>();

  Widget _buildBuildingField() {
    return TextFormField(
      decoration: InputDecoration(labelText: "Building"),
      keyboardType: TextInputType.text,
      onSaved: (val) {
        _newRoom.building = val;
      },
    );
  }

  Widget _buildfloorField() {
    return TextFormField(
      decoration: InputDecoration(labelText: "Floor"),
      keyboardType: TextInputType.text,
      onSaved: (val) {
        _newRoom.floor = val;
      },
      validator: (value) {
        if (value.trim().isEmpty) return "This is a mandatory field";
        return null;
      },
    );
  }

  Widget _buildRoomNumberField() {
    return TextFormField(
      decoration: InputDecoration(labelText: "Room Number"),
      keyboardType: TextInputType.text,
      onSaved: (val) {
        _newRoom.roomNumber = val;
      },
      validator: (value) {
        if (value.trim().isEmpty) return "This is a mandatory field";
        return null;
      },
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      decoration: InputDecoration(labelText: "Title"),
      keyboardType: TextInputType.text,
      onSaved: (val) {
        _newRoom.roomTitle = val;
      },
      validator: (value) {
        if (value.trim().isEmpty) return "Must enter a valid designation";
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      decoration: InputDecoration(labelText: "Decription"),
      keyboardType: TextInputType.text,
      onSaved: (val) {
        _newRoom.decription = val;
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
              key: _roomForm,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _buildTitleField(),
                  Row(
                    children: [
                      Expanded(child: _buildBuildingField()),
                      Expanded(child: _buildfloorField()),
                      Expanded(child: _buildRoomNumberField()),
                    ],
                  ),
                  _buildDescriptionField(),
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 20),
                      child: TextButton(
                        onPressed: _uploadRoomDetails,
                        child: Text(
                          'Add Room',
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

  Future<void> _uploadRoomDetails() async {
    FormState formState = _roomForm.currentState;
    if (formState != null && formState.validate()) {
      formState.save();
      setState(() {
        _uploading = true;
      });
      //send to server
      try {
        await FirebaseFirestoreCloudFunctions.uploadRoom(
                widget.siteId, _newRoom)
            .then((_) async => await showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                      title: Text('Success!'),
                      content: Text('New Room created!\n'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: Navigator.of(context).pop,
                          child: Text('Ok'),
                        ),
                      ],
                    )).then((_) => Navigator.of(context).pop()));
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
          _newRoom = Room();
          _uploading = false;
        });
      }
    }
  }
}
