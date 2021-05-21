import 'package:flutter/material.dart';
import 'package:teamshare/models/team.dart';
import 'package:teamshare/screens/team/team_home_screen.dart';

class TeamThumbnail extends StatelessWidget {
  final Team team;

  const TeamThumbnail({Key key, this.team}) : super(key: key);

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
        child: ListTile(
          leading: Hero(
            tag: team.id,
            child: Image(
              width: 60,
              image: team.logoUrl == null
                  ? AssetImage('assets/pics/unknown.jpg')
                  : NetworkImage(team.logoUrl),
            ),
          ),
          title: Text(team.name),
          subtitle: Text(
            team.description ?? "",
            maxLines: 2,
            overflow: TextOverflow.clip,
          ),
          onTap: () => {
            Navigator.of(context)
                .pushNamed(TeamHomeScreen.routeName, arguments: team)
          },
        ),
      ),
    );
  }
}
