import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teamshare/screens/team_create_screen.dart';

class MainScreen extends StatefulWidget {
  static const String routeName = '/main_screen';

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Team Share"),
        ),
        //drawer: CustomDrawer(),
        body: StreamBuilder<Map<String, dynamic>>(
            stream: Firestore.instance
                .collection("userEmail")
                .document("ts@ts.com")
                .get()
                .then((value) => value.data)
                .asStream(),
            builder: (context, snapshot) {
              if (snapshot == null || snapshot.data == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("You are not part of a team... yet"),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => TeamCreateScreen()),
                            );
                          },
                          icon: Icon(Icons.create),
                          label: Text("Create"),
                        ),
                      ),
                      Text("Your team now!"),
                    ],
                  ),
                );
              } else {
                return Center(
                  child: Text(snapshot.data.toString()),
                );
              }
            }),
      ),
    );
  }
}
