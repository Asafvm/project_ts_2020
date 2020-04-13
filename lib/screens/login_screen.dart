import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:teamshare/screens/main_screen.dart';
import 'package:teamshare/widgets/custom_appbar.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = '/login';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar('Login',null,null),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
        'Team Share Login!',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                CircularProgressIndicator(),
                Padding(
        padding: EdgeInsets.all(10),
        child: Form(
            child: Column(
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(
                icon: Icon(Icons.person),
                hintText: 'Enter User Name',
                labelText: 'User',
              ),
            ),
            TextFormField(
              decoration: const InputDecoration(
                icon: Icon(Icons.lock),
                hintText: 'Enter Password',
                labelText: 'Password',
              ),
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
        )),
                )
              ],
            ),
          ),
      ),
    );
  }

  void _authUser(BuildContext context) {
    //auth using firebase

    //skip for now
    Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
  }
}
