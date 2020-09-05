import 'package:flutter/material.dart';
import 'package:teamshare/widgets/auth_form.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = '/login';

  @override
  Widget build(BuildContext context) {
    var headerText = Container(
      //margin: EdgeInsets.only(top: 40),
      //padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: 'Team',
          style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700]),
          children: [
            TextSpan(
              text: 'Share\n',
              style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[400]),
            ),
            TextSpan(
              text: 'Insert a slogan here',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                  color: Colors.white),
            )
          ],
        ),
      ),
    );

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
              headerText,
              AuthForm(),
            ],
          ),
        ),
      ),
    );
  }
}
