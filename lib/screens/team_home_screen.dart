import 'package:flutter/material.dart';
import 'package:teamshare/models/team.dart';
import 'package:teamshare/providers/team_provider.dart';
import 'package:teamshare/widgets/custom_drawer.dart';

class TeamHomeScreen extends StatefulWidget {
  final Team team;
  const TeamHomeScreen({Key key, this.team}) : super(key: key);

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
      ),
      drawer: CustomDrawer(),
      body: Center(
        child: Text('This view will update in the future'),
      ),
    );
  }

  @override
  void dispose() {
    TeamProvider().clearCurrentTeam();
    super.dispose();
  }
}
