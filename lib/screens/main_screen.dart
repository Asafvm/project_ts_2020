import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:teamshare/providers/authentication.dart';
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
              Text("You are not part of a team... yet"),
              RaisedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => TeamCreateScreen()),
                  );
                },
                icon: Icon(Icons.create),
                label: Text("Create"),
              ),
              Text("Your team now!"),
              FloatingActionButton(
                  onPressed: () async => {
                        CloudFunctions.instance
                            .getHttpsCallable(functionName: "findTeam")
                            .call(<String, dynamic>{
                              "user": await Authentication().userEmail
                            })
                            .then((value) => print(value.data))
                            .catchError((e) => print("Error: ${e.toString()}"))
                      })
            ],
          ),
        ),
      ),
    );
  }
}
