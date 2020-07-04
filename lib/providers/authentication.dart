import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:teamshare/providers/http_exception.dart';

class Authentication with ChangeNotifier {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  String _token;
  DateTime _expiryDate;
  String _userId;

  bool get isAuth {
    return token != null;
  }

  String get userId {
    return isAuth ? _userId : null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) return _token;
    return null;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    // const key = 'AIzaSyAfy1vsq7uZuBvrFH831MAqtRh1zywnJ68';
    // final url =
    //     'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=' +
    //         key;
    // try {
    //   final response = await http.post(
    //     url,
    //     body: jsonEncode(
    //       {
    //         'email': email,
    //         'password': password,
    //         'returnSecureToken': true,
    //       },
    //     ),
    //   );
    //   final responseData = json.decode(response.body);
    //   if (responseData['error'] != null) {
    //     throw HttpException(responseData['error']['message']);
    //   }
    //   _token = responseData['idToken'];
    //   _userId = responseData['localId'];
    //   _expiryDate = DateTime.now().add(
    //     Duration(
    //       seconds: int.parse(
    //         responseData['expiresIn'],
    //       ),
    //     ),
    //   );
    //   notifyListeners();
    // } catch (e) {
    //   throw e;
    // }
  }

  Future<void> signup(String email, String password) async {
    try {
      AuthResult result = await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      IdTokenResult usertoken = await result.user.getIdToken();
      _token = usertoken.token;
      _expiryDate = usertoken.expirationTime;
      _userId = result.user.uid;

      notifyListeners();
    } catch (e) {
      if (e.runtimeType == PlatformException) {
        throw (e as PlatformException).code;
      } else {
        throw e;
      }
    }

    //return _authenticate(email, password, "signUp");
  }

  Future<void> signin(String email, String password) async {
    try {
      AuthResult result = await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      IdTokenResult usertoken = await result.user.getIdToken();
      _token = usertoken.token;
      _expiryDate = usertoken.expirationTime;
      _userId = result.user.uid;
      notifyListeners();
    } catch (e) {
      if (e.runtimeType == PlatformException) {
        throw (e as PlatformException).code;
      } else {
        throw e;
      }
    }
    //return _authenticate(email, password, "signInWithPassword");
  }
}
