import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/models/contact.dart';
import 'package:teamshare/models/instrument.dart';
import 'package:teamshare/models/part.dart';
import 'package:teamshare/models/site.dart';
import 'package:teamshare/providers/firebase_firestore_provider.dart';
import 'package:teamshare/screens/admin/admin_contact_screen.dart';
import 'package:teamshare/screens/admin/admin_instrument_screen.dart';
import 'package:teamshare/screens/admin/admin_part_screen.dart';
import 'package:teamshare/screens/admin/admin_site_screen.dart';
import 'package:teamshare/screens/admin/admin_team_managment_screen.dart';

class AdminMenuScreen extends StatelessWidget {
  static const String routeName = '/admin_menu_screen';
  final String siteId;

  const AdminMenuScreen({this.siteId});

  Widget createButton(IconData icon, void Function() click, String title,
      BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 3, color: Colors.black),
        borderRadius: BorderRadius.all(Radius.circular(25)),
        boxShadow: [
          BoxShadow(
              color: Theme.of(context).accentColor.withOpacity(0.3),
              offset: Offset(0, 0),
              blurRadius: 3.0,
              spreadRadius: 1.0)
        ],
      ),
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(5),
      child: Column(
        children: [
          IconButton(
            icon: Icon(
              icon,
            ),
            iconSize: 100,
            onPressed: click,
            focusColor: Theme.of(context).primaryColor,
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Menu"),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              children: [
                Expanded(
                  child: createButton(Icons.group, () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StreamProvider<List<String>>(
                          initialData: [],
                          create: (context) =>
                              FirebaseFirestoreProvider.getTeamMembers(),
                          child: AdminTeamManagmentScreen(),
                        ),
                      ),
                    );
                  }, 'Team Managment', context),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: createButton(Icons.location_city, () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StreamProvider<List<Site>>(
                        create: (context) =>
                            FirebaseFirestoreProvider.getSites(),
                        initialData: [],
                        child: AdminSiteScreen(),
                      ),
                    ),
                  );
                }, 'Site', context)),
                Expanded(
                  child: createButton(Icons.computer, () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StreamProvider<List<Instrument>>(
                          create: (context) =>
                              FirebaseFirestoreProvider.getInstruments(),
                          initialData: [],
                          child: AdminInstrumentScreen(),
                        ),
                      ),
                    );
                  }, 'Instruments', context),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: createButton(Icons.developer_board, () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StreamProvider<List<Part>>(
                          create: (context) =>
                              FirebaseFirestoreProvider.getParts(),
                          initialData: [],
                          child: AdminPartScreen(),
                        ),
                      ),
                    );
                  }, 'Parts', context),
                ),
                Expanded(
                    child: createButton(Icons.perm_contact_calendar, () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StreamProvider<List<Contact>>(
                        create: (context) =>
                            FirebaseFirestoreProvider.getContacts(),
                        initialData: [],
                        child: AdminContactScreen(
                          siteId: siteId,
                        ),
                      ),
                    ),
                  );
                }, 'Contacts', context)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
