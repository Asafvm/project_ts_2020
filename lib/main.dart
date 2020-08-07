import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teamshare/providers/authentication.dart';
import 'package:teamshare/providers/team_provider.dart';
import 'package:teamshare/screens/admin_menu_screen.dart';
import 'package:teamshare/screens/login_screen.dart';
import 'package:teamshare/screens/main_screen.dart';
import 'package:provider/provider.dart';

import 'models/device.dart';

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
        StreamProvider<List<Device>>(
          create: (ctx) => Firestore.instance
              .collection("teams")
              .document(TeamProvider().getCurrentTeam.getTeamId)
              .collection("devices")
              .snapshots()
              .map(
                (query) => query.documents
                    .map(
                      (doc) => Device.fromFirestore(doc),
                    )
                    .toList(),
              ),
          catchError: (context, error) {
            print("${error.toString()}");
            return null;
          },
        )
        //.map((list) => list.documents),
        ,
        if (Authentication().isAuth && TeamProvider().getCurrentTeam != null)
          StreamProvider<List<DocumentSnapshot>>.value(
            value: Firestore.instance
                .collection('teams')
                .document(TeamProvider().getCurrentTeam.getTeamId)
                .collection("parts")
                .snapshots()
                .map((list) => list.documents),
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
