import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:teamshare/providers/authentication.dart';
import 'package:teamshare/screens/admin_menu_screen.dart';
import 'package:teamshare/screens/login_screen.dart';
import 'package:teamshare/screens/main_screen.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(TeamShare());
}

class TeamShare extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  //get domain from user
  //final domain =
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return MaterialApp(
              title: 'Team Share',
              theme: ThemeData(
                primarySwatch: Colors.green,
                accentColor: Colors.lightGreen,
              ),
              home: Scaffold(
                body: Center(
                  child: Text(
                    "There was an error conneting to TeamShare service.\n please try again later!",
                    textAlign: TextAlign.center,
                  ),
                ),
              ));
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
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

        // Otherwise, show something whilst waiting for initialization to complete
        // splash screen here?
        return FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.center,
            child: CircularProgressIndicator());
      },
    );
  }
}
