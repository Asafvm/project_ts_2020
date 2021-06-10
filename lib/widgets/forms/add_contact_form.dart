import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart' as picker;
import 'package:teamshare/helpers/decoration_library.dart';
import 'package:teamshare/models/contact.dart';
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/providers/firebase_firestore_cloud_functions.dart';
import 'package:teamshare/widgets/form_title.dart';

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

  final _controllerFirstName = TextEditingController();
  final _controllerEmail = TextEditingController();
  final _controllerPhone = TextEditingController();
  final _controllerLastName = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  final _contactForm = GlobalKey<FormState>();

  Widget _buildFirstNameField() {
    return TextFormField(
      controller: _controllerFirstName,
      decoration: DecorationLibrary.inputDecoration("First Name", context),
      keyboardType: TextInputType.text,
      onSaved: (val) {
        _newContact.firstName = val;
      },
      validator: _textvalidator,
    );
  }

  Widget _buildLastNameField() {
    return TextFormField(
      controller: _controllerLastName,
      decoration: DecorationLibrary.inputDecoration("Last Name", context),
      keyboardType: TextInputType.text,
      onSaved: (val) {
        _newContact.lastName = val;
      },
      validator: _textvalidator,
    );
  }

  Widget _buildPhoneNumberField() {
    return TextFormField(
      controller: _controllerPhone,
      decoration: DecorationLibrary.inputDecoration("Phone Number", context),
      keyboardType: TextInputType.phone,
      onSaved: (val) {
        _newContact.phone = val;
      },
      validator: _phoneValidator,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _controllerEmail,
      decoration: DecorationLibrary.inputDecoration("Email", context),
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
      child: Container(
        decoration: BoxDecoration(border: Border.all(width: 5)),
        padding: EdgeInsets.only(
            left: 5,
            right: 5,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Form(
          key: _contactForm,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              FormTitle(title: 'Add Contact'),
              Row(
                children: [
                  Expanded(flex: 4, child: _buildFirstNameField()),
                  Spacer(),
                  Expanded(flex: 4, child: _buildLastNameField()),
                ],
              ),
              _buildPhoneNumberField(),
              _buildEmailField(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
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
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    child: _uploading
                        ? CircularProgressIndicator()
                        : OutlinedButton(
                            onPressed: _pickFromContacts,
                            child: Text(
                              'Pick Contact',
                            ),
                            style: outlinedButtonStyle,
                          ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFromContacts() async {
    final picker.FullContact contact =
        await picker.FlutterContactPicker.pickFullContact(
            askForPermission: true);
    if (contact != null) {
      setState(() {
        try {
          _controllerFirstName.text = contact.name.firstName;
        } on Exception {
          _controllerFirstName.text = '';
        }
        try {
          _controllerLastName.text = contact.name.lastName;
        } on Exception {
          _controllerLastName.text = '';
        }
        try {
          _controllerPhone.text = contact.phones.first.number;
        } on Exception {
          _controllerPhone.text = '';
        }
        try {
          _controllerEmail.text = contact.emails.first.email;
        } on Exception {
          _controllerEmail.text = '';
        }
      });
    }
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
    if (value.isEmpty) return null;
    return phoneRegExp.hasMatch(value) ? null : 'Not a valid phone number';
  }

  String _emailValidator(String value) {
    if (value.isEmpty) return null;
    return emailRegExp.hasMatch(value) ? null : 'Not a valid email';
  }
}
