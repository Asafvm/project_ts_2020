import 'package:flutter/material.dart';
import 'package:teamshare/screens/admin_menu_screen.dart';

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
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.store),
            title: Text('Inventory'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.library_books),
            title: Text('Files'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.map),
            title: Text('Map'),
            onTap: () {},
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Admin'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AdminMenuScreen.routeName);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {},
          ),
          Divider(),
        ],
      ),
    );
  }
}
