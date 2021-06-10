import 'package:flutter/material.dart';
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/widgets/forms/auth_form.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = '/login';

  @override
  Widget build(BuildContext context) {
    MediaQueryData mqd = MediaQuery.of(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blueGrey[900],
        body: Padding(
          padding: EdgeInsets.symmetric(
              vertical: 20,
              horizontal:
                  (mqd.orientation == Orientation.portrait) ? 20.0 : 100.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                  flex: 2, child: Center(child: logoText)), //defined in consts
              Flexible(flex: 3, fit: FlexFit.tight, child: AuthForm()),
            ],
          ),
        ),
      ),
    );
  }
}
