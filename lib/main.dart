import 'package:cloud_firestore/cloud_firestore.dart';
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
  //get domain from user
  //final domain = 
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: FirebaseAuth()),
        StreamProvider<List<DocumentSnapshot>>.value(
          value: Firestore.instance.collection('test').snapshots().map(
                (list) => list.documents
              ),
              //updateShouldNotify: (previous, current) => previous != current,
        ),
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
          AdminMenuScreen.routeName: (ctx) => AdminMenuScreen(),
        },
      ),
    );
  }
}
