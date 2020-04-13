import 'package:flutter/material.dart';
import 'package:teamshare/widgets/custom_appbar.dart';
import 'package:teamshare/widgets/custom_drawer.dart';

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
        appBar: CustomAppBar('Team Share', null, null),
        drawer: CustomDrawer(),
        body: Center(child: Text('Main View')),
      ),
    );
  }
}
