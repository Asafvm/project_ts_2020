import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';

class Strings {
  static String randomString(int length) {
    var rand = new Random();
    var codeUnits = new List.generate(length, (index) {
      return rand.nextInt(33) + 89;
    });
    return new String.fromCharCodes(codeUnits);
  }
}

const tabbar = TabBar(
  labelColor: Colors.black,
  tabs: [
    Tab(
      child: Text(
        "Required",
      ),
    ),
    Tab(
      text: "Optional",
    ),
  ],
);

const tabInstrument = TabBar(
  labelColor: Colors.black,
  tabs: [
    Tab(
      text: "Log",
    ),
    Tab(
      text: "Reports",
    ),
  ],
);

final logoText = Container(
  //margin: EdgeInsets.only(top: 40),
  //padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
  child: RichText(
    textAlign: TextAlign.center,
    text: TextSpan(
      text: 'Team',
      style: const TextStyle(
          fontSize: 52, fontWeight: FontWeight.bold, color: Colors.blue),
      children: [
        TextSpan(
          text: 'Share\n',
          style: const TextStyle(
              fontSize: 52, fontWeight: FontWeight.bold, color: Colors.cyan),
        ),
        TextSpan(
          text: 'Insert a slogan here',
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.normal, color: Colors.white),
        )
      ],
    ),
  ),
);

const double a4Width = 1240; //150dpi
const double a4Height = 1754; //150dpi
final RegExp emailRegExp =
    RegExp(r"(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)",
        //r'^[a-zA-Z0-9._]+@.[a-zA-Z0-9]+.[a-zA-Z]+',
        caseSensitive: false,
        multiLine: false);

//Button colors
Color getColor(Set<MaterialState> states) {
  const Set<MaterialState> interactiveStates = <MaterialState>{
    MaterialState.pressed,
    MaterialState.hovered,
    MaterialState.focused,
    MaterialState.selected,
  };

  if (states.any(interactiveStates.contains)) {
    return Colors.lightBlue;
  }
  return Colors.blue;
}

var outlinedButtonStyle = OutlinedButton.styleFrom(
  side: BorderSide(color: Colors.blue),
);

//Firestore consts
const String instruments = "instruments";
const String instances = "instances";
const String users = "users";
const String teams = "teams";
const String sites = "sites";
const String rooms = "rooms";
const String contacts = "contacts";
const String members = "members";
const String parts = "parts";
const String inventory = "inventory";
const String storage = "storage";
const String entries = "entries";
const String reports = "reports";
const String report_templates = "report_templates";
const String images = "images";
