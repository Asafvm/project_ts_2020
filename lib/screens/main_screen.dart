import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/models/team.dart';
import 'package:teamshare/providers/applogger.dart';
import 'package:teamshare/providers/authentication.dart';
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
    return StreamProvider.value(
      value: FirebaseFirestoreProvider.getUserTeamList(),
      initialData: [],
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("Team Share"),
            actions: [
              IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () => Authentication().logout())
            ],
          ),
          body: Consumer<List<String>>(
            builder: (context, teamIds, child) => teamIds.isEmpty
                ? Center(
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
                  )
                : Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(10),
                          itemBuilder: (ctx, index) {
                            return FutureBuilder<Team>(
                              initialData: null,
                              future: FirebaseFirestoreProvider.getTeamInfo(
                                  teamIds[index]),
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data != null) {
                                  Team team = snapshot.data;
                                  return TeamThumbnail(
                                    key: UniqueKey(),
                                    team: team,
                                  );
                                } else {
                                  return Container();
                                }
                              },
                            );
                          },
                          itemCount: teamIds.length,
                          shrinkWrap: true,
                        ),
                      ),
                    ],
                  ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => createTeam(context),
            child: Icon(Icons.group_add),
            focusElevation: 6,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ),
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
