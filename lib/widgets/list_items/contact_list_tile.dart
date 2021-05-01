import 'package:flutter/material.dart';
import 'package:teamshare/models/contact.dart';
import 'package:teamshare/models/site.dart';

class ContactListTile extends StatelessWidget {
  final Contact contact;
  final String siteName;
  final Room room;

  ContactListTile({this.contact, this.siteName, this.room});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.person),
      title: Text(contact.getFullName()),
      subtitle: Text('$siteName - ${room.toString()}'),
    );
  }
}
