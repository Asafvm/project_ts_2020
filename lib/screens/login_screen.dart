import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/providers/firebase_auth.dart';
import 'package:teamshare/screens/main_screen.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = '/login';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: Text('Login'),),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.lightBlue, Colors.lightGreen],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Stack(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    transform: Matrix4.rotationZ(-8 * pi / 180)
                      ..translate(-20.0, 120),
                    decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.black),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 8,
                              color: Colors.lightBlue,
                              offset: Offset(0, 2))
                        ]),
                    child: Text(
                      'Team Share',
                      style:
                          TextStyle(fontSize: 52, fontWeight: FontWeight.bold),
                    ),
                  ),
                  CircularProgressIndicator(),
                  Padding(padding: EdgeInsets.all(10), child: AuthForm()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthForm extends StatefulWidget {
  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _loginKey = GlobalKey<FormState>();
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Form(
        key: _loginKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(
                icon: Icon(Icons.person),
                hintText: 'Enter eMail',
                labelText: 'eMail',
              ),
              onSaved: (val) {
                _authData['email'] = val.trim();
              },
            ),
            TextFormField(
              decoration: const InputDecoration(
                icon: Icon(Icons.lock),
                hintText: 'Enter Password',
                labelText: 'Password',
              ),
              onSaved: (val) {
                _authData['password'] = val;
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                RaisedButton(
                  color: Theme.of(context).accentColor,
                  elevation: 10,
                  child: Text('Log Me In'),
                  onPressed: () => _authUser(context),
                ),
                GoogleSignInButton(
                  onPressed: () => _authUser(context),
                  darkMode: false,
                  text: 'Sign in with Google',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _authUser(BuildContext context) async {
    //TODO: do more error handling
    _loginKey.currentState.save();
    // setState(() {

    // });
    //auth using firebase
    await Provider.of<FirebaseAuth>(context, listen: false).signup(
      _authData['email'],
      _authData['password'],
    );

    //TODO: fix login first!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! <===<===<===<===<===<===<===<===<===<===<===<===<===<===<===<===<===<===<===<===<===<===<===<===<===<===<===<=== DO THIS!
    //skip for now
    Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
  }
}
