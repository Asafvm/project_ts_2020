import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/providers/authentication.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/screens/team_create_screen.dart';
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
        //drawer: CustomDrawer(),
        body: StreamBuilder<List<DocumentSnapshot>>(
            stream: FirebaseFirestoreProvider().getTeamList(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.data.length == 0) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("You are not part of a team... yet"),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton.icon(
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
              } else {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // ignore: missing_return
                      RefreshIndicator(
                        onRefresh: () async {
                          return await Future.delayed(
                              Duration(seconds: 1), _refresh);
                        },
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(10),
                          itemBuilder: (ctx, index) {
                            return TeamThumbnail(
                              key: UniqueKey(),
                              teamDocId: snapshot.data[index].documentID,
                            );
                          },
                          itemCount: snapshot.data.length,
                          shrinkWrap: true,
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          createTeam(context);
                        },
                        child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.all(15),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.circular(15),
                              color: Theme.of(context).accentColor,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 5,
                                    offset: Offset(0, 10))
                              ]),
                          child: Icon(Icons.add_circle_outline),
                        ),
                      ),
                    ],
                  ),
                );
              }
            }),
      ),
    );
  }

  void createTeam(BuildContext context) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (_) => TeamCreateScreen()),
        )
        .then((value) => setState(() {
              print("refreshing");
            }));
  }

  void _refresh() {
    setState(() {});
  }
}
