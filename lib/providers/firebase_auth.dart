import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class FirebaseAuth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

  Future<void> signup(String email, String password) async {
    const key = 'AIzaSyAfy1vsq7uZuBvrFH831MAqtRh1zywnJ68';
    const url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=' + key;

    final respose = await http.post(
      url,
      body: jsonEncode(
        {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      ),
    );
    //print(json.decode(respose.body));
  }

  Future<void> signin(String email, String password) async {
    const key = 'AIzaSyAfy1vsq7uZuBvrFH831MAqtRh1zywnJ68';
    const url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=' +
            key;

    final respose = await http.post(
      url,
      body: jsonEncode(
        {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      ),
    );
    print(json.decode(respose.body));
  }
}
