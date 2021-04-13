import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teamshare/providers/applogger.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/screens/team/team_create_screen.dart';
import 'package:teamshare/widgets/team_thumbnail.dart';

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
        body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestoreProvider.getUserTeamList(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done ||
                  snapshot.connectionState == ConnectionState.active) {
                if (snapshot.error == null && snapshot.hasData) {
                  var data = snapshot.data.docs;
                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(10),
                          itemBuilder: (ctx, index) {
                            return TeamThumbnail(
                              key: UniqueKey(),
                              teamDocId: data[index].id,
                            );
                          },
                          itemCount: data.length,
                          shrinkWrap: true,
                        ),
                      ),
                    ],
                  );
                } else {
                  // if (snapshot.error != null) {
                  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  //       content: Text('Error getting data from server!')));
                  // }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("You are not part of a team... yet"),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              createTeam(context);
                            },
                            icon: Icon(Icons.create),
                            label: Text("Create"),
                          ),
                        ),
                        Text("Your team now!"),
                      ],
                    ),
                  );
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () => createTeam(context),
          child: Icon(Icons.group_add),
          focusElevation: 6,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  void createTeam(BuildContext context) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (_) => TeamCreateScreen()),
        )
        .then((value) => setState(() {
              Applogger.consoleLog(MessegeType.info, "Refreshing");
            }));
  }
}
