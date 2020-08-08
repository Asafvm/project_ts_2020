import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/models/device.dart';
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
      drawer: StreamProvider.value(
        value: Firestore.instance
            .collection("teams")
            .document(TeamProvider().getCurrentTeam.getTeamId)
            .collection("devices")
            .snapshots()
            .map(
              (query) => query.documents
                  .map(
                    (doc) => Device.fromFirestore(doc),
                  )
                  .toList(),
            ),
        child: CustomDrawer(),
      ),
      body: Center(
        child: Text('Placeholder text'),
      ),
    );
  }

  @override
  void dispose() {
    TeamProvider().clearCurrentTeam();
    super.dispose();
  }
}
