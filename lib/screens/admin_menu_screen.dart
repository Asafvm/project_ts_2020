import 'package:flutter/material.dart';
import 'package:teamshare/screens/admin_instrument_screen.dart';
import 'package:teamshare/screens/admin_part_screen.dart';
import 'package:teamshare/screens/admin_site_screen.dart';

class AdminMenuScreen extends StatelessWidget {
  static const String routeName = '/admin_menu_screen';

  Widget createButton(
      IconData icon, Function click, String title, BuildContext context) {
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
            splashRadius: 30,
            splashColor: Theme.of(context).primaryColor,
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
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: createButton(Icons.location_city, () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => AdminSiteScreen()),
                  );
                }, 'Site', context)),
                Expanded(
                  child: createButton(Icons.computer, () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => AdminInstrumentScreen()),
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
                      MaterialPageRoute(builder: (_) => AdminPartScreen()),
                    );
                  }, 'Parts', context),
                ),
                Expanded(
                    child: createButton(Icons.perm_contact_calendar, null,
                        'Contacts', context)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
