import 'package:flutter/material.dart';
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/widgets/auth_form.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = '/login';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blueGrey[900],
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              logoText, //defined in consts
              AuthForm(),
            ],
          ),
        ),
      ),
    );
  }
}
