import 'package:flutter/material.dart';
import 'package:teamshare/models/team.dart';
import 'package:teamshare/providers/team_provider.dart';
import 'package:teamshare/widgets/custom_drawer.dart';

class TeamHomeScreen extends StatefulWidget {
  final Team team;
  final String teamLogoUrl;
  const TeamHomeScreen({Key key, this.team, this.teamLogoUrl})
      : super(key: key);

  @override
  _TeamHomeScreenState createState() => _TeamHomeScreenState();
}

class _TeamHomeScreenState extends State<TeamHomeScreen> {
  @override
  void initState() {
    TeamProvider().setCurrentTeam(widget.team);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TeamProvider().getCurrentTeam.getTeamName),
        actions: [],
      ),
      drawer: CustomDrawer(),
      body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 1,
              child: Hero(
                tag: widget.team.getTeamId,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image(
                    image: widget.teamLogoUrl == null
                        ? AssetImage('assets/pics/unknown.jpg')
                        : NetworkImage(widget.teamLogoUrl),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Center(
                child: Text('TODO: Insert cool time saving stuff here'),
              ),
            ),
          ]),
    );
  }

  @override
  void dispose() {
    TeamProvider().clearCurrentTeam();
    super.dispose();
  }
}
