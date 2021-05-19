import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/models/part.dart';
import 'package:teamshare/models/site.dart';
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
    List<Site> siteList = Provider.of<List<Site>>(context);
    List<InstrumentInstance> instrumentList =
        Provider.of<List<InstrumentInstance>>(context);
    List<Part> partList = Provider.of<List<Part>>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(TeamProvider().getCurrentTeam.getTeamName),
        actions: [],
      ),
      drawer: CustomDrawer(),
      body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image(
                    fit: BoxFit.fitWidth,
                    image: widget.team.logoUrl == null
                        ? AssetImage('assets/pics/unknown.jpg')
                        : NetworkImage(widget.team.logoUrl),
                  ),
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
                      child: Container(
                        color: Colors.black.withOpacity(0),
                      ),
                    ),
                  ),
                  Hero(
                    tag: widget.team.getTeamId,
                    child: Image(
                      fit: BoxFit.fitHeight,
                      image: widget.team.logoUrl == null
                          ? AssetImage('assets/pics/unknown.jpg')
                          : NetworkImage(widget.team.logoUrl),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Row(
                      children: [
                        InfoCube(
                          title: 'Sites',
                          data: siteList.length,
                        ),
                        InfoCube(
                          title: 'Instruments',
                          data: instrumentList.length,
                        ),
                        InfoCube(
                          title: 'Parts',
                          data: partList.length,
                        ),
                      ],
                    ),
                    InfoCube(title: 'Recent Activity', data: 1)
                  ],
                )),
          ]),
    );
  }

  @override
  void dispose() {
    TeamProvider().clearCurrentTeam();
    super.dispose();
  }
}

class InfoCube extends StatelessWidget {
  final String title;
  final int data;

  const InfoCube({this.title, this.data});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(3),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: Colors.black, width: 3, style: BorderStyle.solid)),
        child: Column(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.black,
                        width: 1,
                        style: BorderStyle.solid)),
                child: Center(
                  child: Text(
                    data.toString(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                        fontSize: 24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
