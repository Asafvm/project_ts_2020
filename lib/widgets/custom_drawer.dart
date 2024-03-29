import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/helpers/firebase_paths.dart';
import 'package:teamshare/models/instrument_instance.dart';
import 'package:teamshare/models/part.dart';
import 'package:teamshare/providers/authentication.dart';
import 'package:teamshare/providers/consts.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/screens/drawer_screens/file_explorer.dart';
import 'package:teamshare/screens/drawer_screens/admin_menu_screen.dart';
import 'package:teamshare/screens/drawer_screens/inventory_screen.dart';
import 'package:teamshare/screens/drawer_screens/map_screen.dart';
import 'package:teamshare/screens/drawer_screens/reports_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureProvider.value(
      value: FirebaseFirestoreProvider.getPermissions(),
      initialData: false,
      child: Drawer(
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
                Navigator.of(context).pop();

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MultiProvider(providers: [
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
              onTap: () {
                Navigator.of(context).pop();

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MultiProvider(providers: [
                      StreamProvider<Iterable<MapEntry<String, bool>>>(
                        create: (context) =>
                            FirebaseFirestoreProvider.getTeamMembers(),
                        initialData: [],
                      ),
                      StreamProvider<List<MapEntry<String, dynamic>>>(
                          create: (context) =>
                              FirebaseFirestoreProvider.getInventoryParts(
                                  '$storage'),
                          initialData: []),
                      StreamProvider<List<Part>>(
                          create: (context) =>
                              FirebaseFirestoreProvider.getCatalogParts(),
                          initialData: [])
                    ], child: InventoryScreen()),
                  ),
                );
              },
            ),
            if (!kIsWeb)
              ListTile(
                leading: Icon(Icons.library_books),
                title: Text('Files'),
                onTap: () async {
                  Navigator.of(context).pop();

                  Future<Directory> dir =
                      Directory('${await FirebasePaths.rootTeamFolder()}')
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
                Navigator.of(context).pop();

                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MapScreen()));
              },
            ),
            Divider(),
            Consumer<bool>(
              builder: (context, admin, child) => admin ?? false
                  ? ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Admin'),
                      onTap: () {
                        Navigator.of(context).pop();

                        Navigator.of(context).pushNamed(
                          AdminMenuScreen.routeName,
                        );
                      },
                    )
                  : Container(),
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
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () async {
                PackageInfo packageInfo = await PackageInfo.fromPlatform();

                Navigator.of(context).pop();

                showAboutDialog(
                    context: context,
                    applicationIcon: Icon(Icons.group),
                    applicationName: 'TeamShare',
                    applicationVersion:
                        'version: ${packageInfo.version} build: ${packageInfo.buildNumber}');
              },
            ),
          ],
        ),
      ),
    );
  }
}
