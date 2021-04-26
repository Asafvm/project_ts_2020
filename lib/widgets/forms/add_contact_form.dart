import 'package:flutter/material.dart';
import 'package:teamshare/models/contact.dart';
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/providers/firebase_firestore_cloud_functions.dart';

class AddContactForm extends StatefulWidget {
  final String siteId;
  final String roomId;

  const AddContactForm({this.siteId, this.roomId});
  @override
  _AddContactFormState createState() => _AddContactFormState();
}

class _AddContactFormState extends State<AddContactForm> {
  bool _uploading = false;

  Contact _newContact = Contact();

  @override
  void initState() {
    super.initState();
  }

  final _contactForm = GlobalKey<FormState>();

  Widget _buildFirstNameField() {
    return TextFormField(
      decoration: InputDecoration(labelText: "First Name"),
      keyboardType: TextInputType.text,
      onSaved: (val) {
        _newContact.firstName = val;
      },
      validator: _textvalidator,
    );
  }

  Widget _buildLastNameField() {
    return TextFormField(
      decoration: InputDecoration(labelText: "Last Name"),
      keyboardType: TextInputType.text,
      onSaved: (val) {
        _newContact.lastName = val;
      },
      validator: _textvalidator,
    );
  }

  Widget _buildPhoneNumberField() {
    return TextFormField(
      decoration: InputDecoration(labelText: "Phone Number"),
      keyboardType: TextInputType.phone,
      onSaved: (val) {
        _newContact.phone = val;
      },
      validator: _phoneValidator,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      decoration: InputDecoration(labelText: "Email"),
      keyboardType: TextInputType.emailAddress,
      onSaved: (val) {
        _newContact.email = val;
      },
      validator: _emailValidator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
          left: 15,
          top: 5,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 10),
      child: Form(
        key: _contactForm,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Row(
              children: [
                Expanded(child: _buildFirstNameField()),
                Expanded(child: _buildLastNameField()),
              ],
            ),
            _buildPhoneNumberField(),
            _buildEmailField(),
            Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              child: _uploading
                  ? CircularProgressIndicator()
                  : OutlinedButton(
                      onPressed: _uploadContactDetails,
                      child: Text(
                        'Add Contact',
                      ),
                      style: outlinedButtonStyle,
                    ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _uploadContactDetails() async {
    FormState formState = _contactForm.currentState;
    if (formState != null && formState.validate()) {
      formState.save();
      setState(() {
        _uploading = true;
      });
      try {
        await FirebaseFirestoreCloudFunctions.uploadContact(
                widget.siteId, _newContact)
            .then((value) => {
                  Navigator.of(context).pop(),
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Contact Added Successfully!'))),
                });
      } catch (error) {
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('Error!'),
                  content: Text('Operation failed\n' +
                      (error.toString().isEmpty
                          ? 'Unknown Error'
                          : error.toString())),
                  actions: <Widget>[
                    TextButton(
                      onPressed: Navigator.of(context).pop,
                      child: Text('Ok'),
                    ),
                  ],
                ));
      } finally {
        setState(() {
          _uploading = false;
        });
      }
    }
  }

  String _textvalidator(String value) {
    if (value.trim().isEmpty) return "Must enter a valid designation";
    return null;
  }

  String _phoneValidator(String value) {
    return null;
  }

  String _emailValidator(String value) {
    return null;
  }
}
