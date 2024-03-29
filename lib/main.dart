import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:teamshare/helpers/custom_route.dart';
import 'package:teamshare/helpers/route_generator.dart';
import 'package:teamshare/providers/authentication.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/screens/login_screen.dart';
import 'package:teamshare/screens/main_screen.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(TeamShare());
}

class TeamShare extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
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
            ),
          );
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider.value(
                value: Authentication(),
              ),
              StreamProvider<List<String>>(
                create: (context) =>
                    FirebaseFirestoreProvider.getUserTeamList(),
                initialData: [],
              ),
              // StreamProvider<List<Site>>(
              //   create: (context) => FirebaseFirestoreProvider.getSites(),
              //   initialData: [],
              //   updateShouldNotify: (previous, current) => previous != current,
              // ),
              // StreamProvider<List<Instrument>>(
              //     create: (context) =>
              //         FirebaseFirestoreProvider.getInstruments(),
              //     initialData: []),
              // StreamProvider<List<Part>>(
              //     create: (context) =>
              //         FirebaseFirestoreProvider.getCatalogParts(),
              //     initialData: []),
            ],
            child: Consumer<Authentication>(
              builder: (ctx, auth, _) {
                return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    title: 'Team Share',
                    theme: ThemeData(
                      primarySwatch: Colors.blue,
                      accentColor: Colors.blueAccent,
                      pageTransitionsTheme: PageTransitionsTheme(
                        builders: {
                          TargetPlatform.android: CustomPageTransitionBuilder(),
                          TargetPlatform.iOS: CustomPageTransitionBuilder(),
                        },
                      ),
                    ),
                    home: auth.isAuth
                        ? MainScreen()
                        : FutureBuilder(
                            future: auth.tryAutoLogin(),
                            builder: (ctx, authResultSnapshot) =>
                                authResultSnapshot.connectionState ==
                                        ConnectionState.waiting
                                    ? SplashScreen()
                                    : LoginScreen()),
                    onGenerateRoute: (settings) =>
                        RouteGenerator.generateRoute(settings)
                    // routes: {
                    //   MainScreen.routeName: (ctx) => MainScreen(),
                    //   AdminMenuScreen.routeName: (ctx) => AdminMenuScreen()
                    //   // ),
                    // },
                    );
              },
            ),
          );
        }

        // splash screen while loading
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SplashScreen(),
        );
      },
    );
  }
}
