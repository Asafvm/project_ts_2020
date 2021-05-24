import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/main.dart';
import 'package:teamshare/models/entry.dart';
import 'package:teamshare/models/team.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/screens/drawer_screens/admin_menu_screen.dart';
import 'package:teamshare/screens/main_screen.dart';
import 'package:teamshare/screens/team/team_home_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (context) => TeamShare());
      case '/main_screen':
        return MaterialPageRoute(builder: (context) => MainScreen());
      case '/team_home_screen':
        if (args is Team)
          return MaterialPageRoute(
              builder: (context) => MultiProvider(
                    providers: [
                      StreamProvider<List<Entry>>(
                          create: (context) =>
                              FirebaseFirestoreProvider.getTeamEntries(),
                          initialData: [])
                    ],
                    child: TeamHomeScreen(
                      team: args,
                    ),
                  ));
        break;

      case '/team_home_screen/admin_menu_screen':
        return MaterialPageRoute(
            builder: (context) => MultiProvider(
                  providers: [
                    StreamProvider<List<Entry>>(
                        create: (context) =>
                            FirebaseFirestoreProvider.getTeamEntries(),
                        initialData: [])
                  ],
                  child: AdminMenuScreen(
                    siteId: args,
                  ),
                ));
      default:
        return _errorRoute();
    }
    return _errorRoute();
  }

  static Route _errorRoute() {
    return MaterialPageRoute(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Error!'),
          ),
          body: Center(
            child: Text("You reached a deadend, go back!"),
          ),
        );
      },
    );
  }
}
