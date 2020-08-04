import 'package:flutter/material.dart';
import 'package:teamshare/providers/authentication.dart';
import 'package:teamshare/screens/admin_menu_screen.dart';
import 'package:teamshare/screens/login_screen.dart';
import 'package:teamshare/screens/main_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(TeamShare());
}

class TeamShare extends StatelessWidget {
  //get domain from user
  //final domain =
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Authentication(),
        ),
      ],
      child: Consumer<Authentication>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Team Share',
          theme: ThemeData(
            primarySwatch: Colors.green,
            accentColor: Colors.lightGreen,
          ),
          home: auth.isAuth ? MainScreen() : LoginScreen(),
          routes: {
            MainScreen.routeName: (ctx) => MainScreen(),
            AdminMenuScreen.routeName: (ctx) => AdminMenuScreen(),
          },
        ),
      ),
    );
  }
}
