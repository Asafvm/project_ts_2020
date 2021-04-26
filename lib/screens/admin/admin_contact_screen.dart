import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/models/contact.dart';
import 'package:teamshare/widgets/forms/add_contact_form.dart';

class AdminContactScreen extends StatefulWidget {
  final String siteId;

  const AdminContactScreen({this.siteId});
  @override
  _AdminContactScreenState createState() => _AdminContactScreenState();
}

class _AdminContactScreenState extends State<AdminContactScreen> {
  bool _sortByFirstName = true;
  @override
  Widget build(BuildContext context) {
    List<Contact> contacts = Provider.of<List<Contact>>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Contacts"),
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _openAddContactForm(context))
        ],
      ),
      body: contacts.isEmpty
          ? Center(child: Text("No contacts registered for this site"))
          : ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.person),
                  title: Text(
                      '${contacts[index].getFullName(soreByFirstName: _sortByFirstName)}'),
                  subtitle: Text('${contacts[index].phone}'),
                );
              },
            ),
    );
  }

  _openAddContactForm(BuildContext context) {
    showModalBottomSheet(
        enableDrag: false,
        isDismissible: true,
        context: context,
        builder: (_) {
          return AddContactForm(siteId: widget.siteId);
        }).whenComplete(() => setState(() {}));
  }
}
