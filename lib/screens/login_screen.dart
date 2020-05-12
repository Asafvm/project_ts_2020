

import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/providers/firebase_auth.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = '/login';

  @override
  Widget build(BuildContext context) {
    bool _loading = false;
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
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
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Team Share\n',
                        style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        children: [
                          TextSpan(
                            text: 'Anytime,\tAnywhere',
                            style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.normal,
                                color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ),
                  if (_loading) CircularProgressIndicator(),
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
              validator: (value) {
                RegExp regExp = RegExp(r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$',caseSensitive: false,multiLine: false);
                //RegExp regExp = RegExp(r'^[a-zA-Z0-9]+@.[a-zA-Z]+.[a-zA-Z]+', caseSensitive: false, multiLine: false);

                if (value.isEmpty || !regExp.hasMatch(value))
                  return 'Insert a valid eMail address';
                return null;
              },
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
              validator: (value) {
                if (value.isEmpty) return 'Password cannot be empty';
                return null;
              },
              onSaved: (val) {
                _authData['password'] = val;
              },
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  RaisedButton(
                    color: Theme.of(context).accentColor,
                    elevation: 10,
                    child: Text('Log Me In'),
                    onPressed: () => _authUser(context),
                  ),
                  GoogleSignInButton(
                    onPressed: () => {},//_authUserWithGoogle(context),
                    darkMode: false,
                    text: 'Sign in with Google',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _authUser(BuildContext context) async {
    _loginKey.currentState.save();
    if (_loginKey.currentState.validate()) {
      await Provider.of<FirebaseAuth>(context, listen: false).signup(
        _authData['email'],
        _authData['password'],
      ).then((value) => print('Success')).catchError((e)  => print('Failed'));

      //Navigator.of(context).pushReplacementNamed(MainScreen.routeName);

    }
  }

  // Future<void> _authUserWithGoogle(BuildContext context) async {
  //   GoogleSignIn _googleSignIn = GoogleSignIn(clientId: '181561501538-51ph5llcgp6gm2pj6mte0jeqeg1dpgps.apps.googleusercontent.com',signInOption: SignInOption.standard,
  //     scopes: [
  //       'email',
  //       'https://www.googleapis.com/auth/contacts.readonly',
  //     ],
  //   );
  //   Future<void> _handleSignIn() async {
  //     try {
  //       await _googleSignIn.signIn().then((value) => print('Success!'));
  //     } catch (error) {
  //       print(error);
  //     }
  //   }

  //   //Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
  // }
}
