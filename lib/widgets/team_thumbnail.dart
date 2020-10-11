import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teamshare/models/team.dart';
import 'package:teamshare/screens/team_home_screen.dart';

class TeamThumbnail extends StatelessWidget {
  final String teamDocId;

  const TeamThumbnail({Key key, this.teamDocId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 7,
      margin: EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ),
        side: BorderSide(
            color: Colors.blueGrey, width: 2, style: BorderStyle.solid),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: StreamBuilder<Map<String, dynamic>>(
          stream: FirebaseFirestore.instance
              .collection("teams")
              .doc(teamDocId)
              .get()
              .then((value) => value.data())
              .asStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              if (snapshot.connectionState == ConnectionState.done ||
                  snapshot.connectionState == ConnectionState.active)
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
                  tag: teamDocId,
                  child: Image(
                    image: snapshot.data['logo'] == null
                        ? AssetImage('assets/pics/unknown.jpg')
                        : NetworkImage(snapshot.data['logo']),
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
                      teamLogoUrl: snapshot.data['logo'],
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
