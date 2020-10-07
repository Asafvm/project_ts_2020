import 'package:flutter/material.dart';
import 'package:teamshare/providers/consts.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(color: Colors.blueGrey[900]),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [Center(child: logoText), CircularProgressIndicator()],
          )),
    );
  }
}
