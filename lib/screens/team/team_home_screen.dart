import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/models/entry.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/part.dart';
import 'package:teamshare/models/site.dart';
import 'package:teamshare/models/team.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/providers/team_provider.dart';
import 'package:teamshare/screens/drawer_screens/inventory_screen.dart';
import 'package:teamshare/widgets/custom_drawer.dart';
import 'package:teamshare/widgets/list_items/entry_list_item.dart';

class TeamHomeScreen extends StatefulWidget {
  final Team team;

  static const String routeName = '/team_home_screen';
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
    List<Entry> entryList = Provider.of<List<Entry>>(context);
    return MultiProvider(
      providers: [
        StreamProvider<List<Site>>.value(
          value: FirebaseFirestoreProvider.getSites(),
          initialData: [],
        ),
        StreamProvider<List<Instrument>>.value(
            value: FirebaseFirestoreProvider.getInstruments(), initialData: []),
        StreamProvider<List<Part>>.value(
            value: FirebaseFirestoreProvider.getCatalogParts(),
            initialData: []),
      ],
      child: Scaffold(
        drawer: CustomDrawer(),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text(TeamProvider().getCurrentTeam.getTeamName),
              expandedHeight: 200,
              stretch: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
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
                          color: Colors.black.withOpacity(.2),
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
            ),
            SliverFillRemaining(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Consumer<List<Site>>(
                        builder: (context, value, child) => InfoCube(
                          title: 'Sites',
                          child: Center(
                            child: Text(
                              value.length.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Consumer<List<Instrument>>(
                        builder: (context, value, child) => InfoCube(
                          title: 'Instruments',
                          child: Center(
                            child: Text(
                              value.length.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Consumer<List<Part>>(
                        builder: (context, value, child) => InfoCube(
                          title: 'Parts',
                          child: Center(
                            child: Text(
                              value.length.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: InfoCube(
                    title: 'Recent Activity',
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: entryList.length,
                        itemBuilder: (context, index) => EntryListItem(
                          entry: entryList[index],
                          showSub: true,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Consumer<List<Part>>(
                    builder: (context, value, child) => InfoCube(
                      title: 'Missing Inventroy',
                      child: MissingPartWindow(catalog: value),
                    ),
                  ),
                )
              ],
            ))
          ],
        ),
      ),
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
  final Widget child;

  const InfoCube({this.title, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(3),
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: Colors.black, width: 3, style: BorderStyle.solid),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 0,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: Colors.black, width: 1, style: BorderStyle.solid),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
