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
