import 'package:flutter/material.dart';
import 'package:teamshare/screens/admin_menu_screen.dart';
import 'package:teamshare/screens/login_screen.dart';
import 'package:teamshare/screens/main_screen.dart';

void main() {
  runApp(TeamShare());
}

class TeamShare extends StatefulWidget {
  @override
  _TeamShareState createState() => _TeamShareState();
}

class _TeamShareState extends State<TeamShare> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Team Share',
        theme: ThemeData(
    primarySwatch: Colors.green,
    accentColor: Colors.lightGreen,
        ),
        home: SafeArea(child: LoginScreen()),
        routes: {
    MainScreen.routeName: (ctx) => MainScreen(),
    LoginScreen.routeName: (ctx) => LoginScreen(),
    AdminMenuScreen.routeName: (ctx) => AdminMenuScreen(),
        },
      );
  }
}
