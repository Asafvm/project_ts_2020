import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/models/contact.dart';

class ContactSelectionScreen extends StatefulWidget {
  final String siteId;
  final String roomId;

  const ContactSelectionScreen({this.siteId, this.roomId});
  @override
  _ContactSelectionScreenState createState() => _ContactSelectionScreenState();
}

class _ContactSelectionScreenState extends State<ContactSelectionScreen> {
  List<Contact> _selectedContacts = [];
  List<Contact> _contactList;
  List<bool> _selectableList;
  int _oldSelectableListLength = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _contactList = Provider.of<List<Contact>>(context, listen: true);
    _initSelectableList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Contacts'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _selectedContacts.isEmpty
                ? null
                : () {
                    Navigator.of(context).pop(_selectedContacts);
                  },
          )
        ],
      ),
      body: ListView(
        shrinkWrap: true,
        children: _contactList
            .map(
              (contact) => CheckboxListTile(
                value: _selectableList[_contactList.indexOf(contact)],
                onChanged: (value) => {
                  setState(() {
                    if (value)
                      _selectedContacts.add(contact);
                    else
                      _selectedContacts.remove(contact);

                    _selectableList[_contactList.indexOf(contact)] = value;
                  })
                },
                title: Text(contact.getFullName()),
              ),
            )
            .toList(),
      ),
    );
  }

  void _initSelectableList() {
    if (_contactList.length != _oldSelectableListLength) {
      _selectableList = List<bool>.filled(_contactList.length, false);
      _oldSelectableListLength = _contactList.length;
    }
  }
}
