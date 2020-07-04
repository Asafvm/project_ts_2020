import 'package:flutter/material.dart';
import 'package:teamshare/screens/admin_device_screen.dart';
import 'package:teamshare/screens/admin_part_screen.dart';

class AdminMenuScreen extends StatelessWidget {
  static const String routeName = '/admin_menu_screen';

  Widget createButton(IconData icon, Function click, String title) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      margin: EdgeInsets.all(15),
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          IconButton(
            icon: Icon(
              icon,
            ),
            iconSize: 100,
            onPressed: click,
            splashRadius: null,
          ),
          Text(title),
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
                    child: createButton(Icons.location_city, null, 'Location')),
                Expanded(
                  child: createButton(Icons.computer, () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => AdminDeviceScreen()),
                    );
                  }, 'Devices'),
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
                  }, 'Parts'),
                ),
                Expanded(
                    child: createButton(
                        Icons.perm_contact_calendar, null, 'Contacts')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
