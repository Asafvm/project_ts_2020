import 'package:flutter/material.dart';
import 'package:teamshare/screens/team_create_screen.dart';

class MainScreen extends StatefulWidget {
  static const String routeName = '/main_screen';

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Team Share"),
        ),
        //drawer: CustomDrawer(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RaisedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.group),
                  label: Text("Join a team")),
              Text("Or"),
              RaisedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => TeamCreateScreen()),
                    );
                  },
                  icon: Icon(Icons.create),
                  label: Text("Create a team")),
            ],
          ),
        ),
      ),
    );
  }
}
