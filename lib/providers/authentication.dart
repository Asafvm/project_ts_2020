import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class Authentication with ChangeNotifier {
  static final Authentication _instance = Authentication._internal();

  factory Authentication() => _instance;

  Authentication._internal();

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  User _user;
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get userId {
    return isAuth && _user != null ? _userId : null;
  }

  String get userEmail {
    return isAuth && _user != null ? _user.email : null;
  }

  String get userName {
    return isAuth && _user != null ? _user.displayName : null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) return _token;
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

      IdTokenResult usertoken = await result.user.getIdTokenResult();
      _token = usertoken.token;
      _expiryDate = usertoken.expirationTime;
      _user = result.user;
      autoLogout();
      notifyListeners();
    } on PlatformException catch (e) {
      throw e.code;
    } catch (e) {
      throw e;
    }
  }

  void logout() {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
  }

  void autoLogout() {
    if (_authTimer != null) _authTimer.cancel();
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    Timer(Duration(seconds: timeToExpiry), logout);
  }
}
