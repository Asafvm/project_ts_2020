import 'package:flutter/material.dart';
import 'package:teamshare/widgets/auth_form.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = '/login';

  @override
  Widget build(BuildContext context) {
    var headerText = Container(
      margin: EdgeInsets.only(top: 40),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: 'Team Share\n',
          style: TextStyle(
              fontSize: 52, fontWeight: FontWeight.bold, color: Colors.white),
          children: [
            TextSpan(
              text: 'Big Solution for Small Buisness',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                  color: Colors.white),
            )
          ],
        ),
      ),
    );

    return Scaffold(
      body:
          //TEXT HEADER
          Container(
        decoration: BoxDecoration(color: Colors.blueGrey[800]),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              headerText,
              AuthForm(),
            ]),
      ),
    );
  }
}
