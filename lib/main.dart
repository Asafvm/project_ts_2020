import 'package:flutter/material.dart';
import 'package:teamshare/providers/firebase_auth.dart';
import 'package:teamshare/screens/admin_menu_screen.dart';
import 'package:teamshare/screens/login_screen.dart';
import 'package:teamshare/screens/main_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(TeamShare());
}

class TeamShare extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: FirebaseAuth()),
      ],
      child: MaterialApp(
        title: 'Team Share',
        theme: ThemeData(
          primarySwatch: Colors.green,
          accentColor: Colors.lightGreen,
        ),
        home: SafeArea(child: LoginScreen()),
        routes: {
          MainScreen.routeName: (ctx) => MainScreen(),
          //LoginScreen.routeName: (ctx) => LoginScreen(),
          AdminMenuScreen.routeName: (ctx) => AdminMenuScreen(),
        },
      ),
    );
  }
}
