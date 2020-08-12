import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teamshare/models/team.dart';
import 'package:teamshare/screens/team_home_screen.dart';

class TeamThumbnail extends StatelessWidget {
  final String teamDocId;

  const TeamThumbnail({Key key, this.teamDocId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: StreamBuilder<Map<String, dynamic>>(
          stream: Firestore.instance
              .collection("teams")
              .document(teamDocId)
              .get()
              .then((value) => value.data)
              .asStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              if (snapshot.connectionState == ConnectionState.done)
                return Container(); //error getting data
              else
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: LinearProgressIndicator(),
                );
            } else {
              String teamName = snapshot.data['name'] ?? "";
              return ListTile(
                leading: Hero(
                  tag: key,
                  child: Image(
                    image: AssetImage('assets/pics/unknown.jpg'),
                  ),
                ),
                title: Text(teamName),
                subtitle: Text(
                  snapshot.data['description'] ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.clip,
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TeamHomeScreen(
                      team: Team(id: teamDocId, name: teamName),
                      teamLogo: key,
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
