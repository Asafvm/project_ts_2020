import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/models/site.dart';
import 'package:teamshare/providers/authentication.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/providers/team_provider.dart';
import 'package:teamshare/screens/drawer_screens/FileExplorer.dart';
import 'package:teamshare/screens/drawer_screens/admin_menu_screen.dart';
import 'package:teamshare/screens/drawer_screens/map_screen.dart';
import 'package:teamshare/screens/drawer_screens/reports_screen.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Hello!'),
            automaticallyImplyLeading: false,
          ),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Reports'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MultiProvider(providers: [
                    StreamProvider<List<Site>>(
                      create: (context) => FirebaseFirestoreProvider.getSites(),
                      initialData: [],
                    ),
                    StreamProvider<List<Instrument>>(
                      create: (context) =>
                          FirebaseFirestoreProvider.getInstruments(),
                      initialData: [],
                    ),
                    StreamProvider<List<InstrumentInstance>>(
                      create: (context) => FirebaseFirestoreProvider
                          .getAllInstrumentsInstances(),
                      initialData: [],
                    ),
                  ], child: ReportsScreen()),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.store),
            title: Text('Inventory'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.library_books),
            title: Text('Files'),
            onTap: () async {
              Future<Directory> dir = Directory(
                      '${(await getTemporaryDirectory()).path}/${TeamProvider().getCurrentTeam.name}')
                  .create(recursive: true);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FileExplorer(
                    path: dir,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.map),
            title: Text('Map'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapScreen()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Admin'),
            onTap: () {
              Navigator.of(context).pushNamed(AdminMenuScreen.routeName);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {},
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.loop),
            title: Text('Switch Team'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();

              Provider.of<Authentication>(context, listen: false).logout();
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}
