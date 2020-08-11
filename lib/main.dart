import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teamshare/providers/authentication.dart';
import 'package:teamshare/providers/team_provider.dart';
import 'package:teamshare/screens/admin_menu_screen.dart';
import 'package:teamshare/screens/login_screen.dart';
import 'package:teamshare/screens/main_screen.dart';
import 'package:provider/provider.dart';

import 'models/instrument.dart';
import 'models/part.dart';

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
        if (Authentication().isAuth && TeamProvider().getCurrentTeam != null)
          StreamProvider<List<Part>>.value(
            value: Firestore.instance
                .collection('teams')
                .document(TeamProvider().getCurrentTeam.getTeamId)
                .collection("parts")
                .snapshots()
                .map(
                  (query) => query.documents
                      .map(
                        (doc) => Part.fromFirestore(doc),
                      )
                      .toList(),
                ),
          ),
        if (Authentication().isAuth && TeamProvider().getCurrentTeam != null)
          StreamProvider<List<Instrument>>.value(
            value: Firestore.instance
                .collection("teams")
                .document(TeamProvider().getCurrentTeam.getTeamId)
                .collection("Instruments")
                .snapshots()
                .map(
                  (query) => query.documents
                      .map(
                        (doc) => Instrument.fromFirestore(doc),
                      )
                      .toList(),
                ),
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
