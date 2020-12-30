import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Authentication with ChangeNotifier {
  static final Authentication _instance = Authentication._internal();

  String _authToken;
  String _authUserId;
  String _authUserEmail;
  DateTime _authTokenExpiry;
  User _user;
  IdTokenResult _usertoken;
  Timer _authTimer;

  factory Authentication() => _instance;

  Authentication._internal();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  bool get isAuth {
    return _authToken != null;
  }

  String get userId {
    return isAuth ? _authUserId : null;
  }

  String get userEmail {
    return isAuth ? _authUserEmail : null;
  }

  String get userName {
    return isAuth && _user != null ? _user.displayName : null;
  }

  String get token {
    if (_authTokenExpiry != null &&
        _authToken != null &&
        _authTokenExpiry.isAfter(DateTime.now())) return _authToken;
    return null;
  }

  Future<void> authenticate(String email, String password, bool signup) async {
    UserCredential result;

    try {
      if (signup)
        result = await firebaseAuth.createUserWithEmailAndPassword(
            email: email, password: password);
      else
        result = await firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password);

      _user = result.user;
      _usertoken = await _user.getIdTokenResult();
      _authToken = _usertoken.token;

      _authUserId = _user.uid;
      _authUserEmail = _user.email;
      _authTokenExpiry = _usertoken.expirationTime;

      //store login data
      final pref = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'userEmail': _authUserEmail,
          'userId': _authUserId,
          'token': _authToken,
          'expiry': _authTokenExpiry.toIso8601String(),
        },
      );
      pref.setString('userData', userData);

      autoLogout();
      notifyListeners();
    } on PlatformException catch (e) {
      throw e.code;
    } catch (e) {
      throw e;
    }
  }

  Future<bool> tryAutoLogin() async {
    final pref = await SharedPreferences.getInstance();
    if (!pref.containsKey('userData')) return false;
    final extractedUserData =
        json.decode(pref.getString('userData')) as Map<String, Object>;

    _authTokenExpiry = DateTime.parse(extractedUserData['expiry'] as String);
    if (_authTokenExpiry.isBefore(DateTime.now())) return false;

    _authUserEmail = extractedUserData['userEmail'] as String;
    _authUserId = extractedUserData['userId'] as String;
    _authToken = extractedUserData['token'] as String;

    notifyListeners();
    autoLogout();

    return true;
  }

  Future<void> logout() async {
    _authToken = null;

    if (_authTimer != null) {
      _authTimer?.cancel();
      _authTimer = null;
    }
    final pref = await SharedPreferences.getInstance();
    pref.remove('userData');
    notifyListeners();
  }

  void autoLogout() {
    if (_authTimer != null) _authTimer?.cancel();
    final timeToExpiry = _authTokenExpiry.difference(DateTime.now()).inSeconds;
    Timer(Duration(seconds: timeToExpiry), tryAutoLogin);
    // Timer(Duration(seconds: timeToExpiry), logout);
  }
}
