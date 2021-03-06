import 'package:flutter/material.dart';
import 'package:teamshare/models/team.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/screens/team/team_home_screen.dart';

class TeamThumbnail extends StatelessWidget {
  final String teamDocId;

  const TeamThumbnail({Key key, this.teamDocId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      background: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
        padding: EdgeInsets.all(15),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Icon(Icons.delete),
          Icon(Icons.delete),
        ]),
      ),
      onDismissed: (_) => {
        FirebaseFirestoreProvider.removeTeam(teamDocId),
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Expanded(
                  child: Text('Team deleted!'),
                ),
                TextButton(
                  onPressed: () {}, //TODO: reverse time here!
                  child: Text(
                    'Undo',
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      },
      key: Key(teamDocId),
      child: Card(
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
            stream: FirebaseFirestoreProvider.getTeamInfo(teamDocId),
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
                Team temp = Team.fromJson(snapshot.data);
                temp.setTeamId(teamDocId);

                String teamName = snapshot.data['name'] ?? "";
                return ListTile(
                    leading: Hero(
                      tag: teamDocId,
                      child: Image(
                        width: 60,
                        image: snapshot.data['logoUrl'] == null
                            ? AssetImage('assets/pics/unknown.jpg')
                            : NetworkImage(snapshot.data['logoUrl']),
                      ),
                    ),
                    title: Text(teamName),
                    subtitle: Text(
                      snapshot.data['description'] ?? "",
                      maxLines: 2,
                      overflow: TextOverflow.clip,
                    ),
                    onTap: () => {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TeamHomeScreen(
                                team: temp,
                              ),
                            ),
                          ),
                        });
              }
            },
          ),
        ),
      ),
    );
  }
}
