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
          text: 'Team Share\n',
          style: TextStyle(
              fontSize: 52, fontWeight: FontWeight.bold, color: Colors.white),
          children: [
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
        backgroundColor: Colors.blueGrey[800],
        body: ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  headerText,
                  AuthForm(),
                ]),
          ),
        ),
      ),
    );
  }
}
