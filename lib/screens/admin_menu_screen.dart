import 'package:flutter/material.dart';
import 'package:teamshare/screens/admin_device_screen.dart';
import 'package:teamshare/widgets/custom_appbar.dart';

class AdminMenuScreen extends StatelessWidget {
  static const String routeName = '/admin_menu_screen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar('Admin Menu',null,null),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 2,
          ),
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.lightBlue[100],
                border: Border.all(
                  width: 1,
                  color: Colors.black,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.location_city),
                    iconSize: 50,
                    onPressed: () {},
                  ),
                  Text(
                    'Location',
                    style: TextStyle(fontSize: 20),
                  )
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.lightBlue[100],
                border: Border.all(
                  width: 1,
                  color: Colors.black,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.computer),
                    iconSize: 50,
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => AdminDeviceScreen()));
                    },
                  ),
                  Text(
                    'Device',
                    style: TextStyle(fontSize: 20),
                  )
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.lightBlue[100],
                border: Border.all(
                  width: 1,
                  color: Colors.black,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.developer_board),
                    iconSize: 50,
                    onPressed: () {},
                  ),
                  Text(
                    'Part',
                    style: TextStyle(fontSize: 20),
                  )
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.lightBlue[100],
                border: Border.all(
                  width: 1,
                  color: Colors.black,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.perm_contact_calendar),
                    iconSize: 50,
                    onPressed: () {},
                  ),
                  Text(
                    'Contact',
                    style: TextStyle(fontSize: 20),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
