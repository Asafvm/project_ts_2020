import 'dart:core';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/helpers/decoration_library.dart';
import 'package:teamshare/providers/authentication.dart';
import 'package:teamshare/providers/consts.dart';

enum AuthState { signin, signup }

class AuthForm extends StatefulWidget {
  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> with TickerProviderStateMixin {
  final _loginKey = GlobalKey<FormState>();

  AnimationController _animationContainerController;
  AnimationController _animationButtonController;
  Animation<double> _buttonAnimation;
  // Animation<Size> _heightAnimation;

  double screenWidth;

  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  AuthState signMode = AuthState.signin;
  bool _logging = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width - 80;
    _animationContainerController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animationButtonController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _buttonAnimation =
        Tween(begin: screenWidth / 3, end: screenWidth / 3 * 2).animate(
      CurvedAnimation(
          parent: _animationButtonController, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _passwordController = TextEditingController();

    const textStyleWhite = TextStyle(color: Colors.white);

    return _logging
        ? FittedBox(
            fit: BoxFit.none,
            child: CircularProgressIndicator(
              strokeWidth: 3,
            ),
          )
        : AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
            height: signMode == AuthState.signup ? 390 : 300,
            child: SingleChildScrollView(
              child: Form(
                key: _loginKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  // mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    TextFormField(
                      style: textStyleWhite,
                      onChanged: (value) => _authData['email'] = value,
                      decoration: DecorationLibrary.loginDecoration(
                          Icons.email, "Email", "Enter Email", context),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value.isEmpty || !emailRegExp.hasMatch(value))
                          return 'Insert a valid Email address';
                        return null;
                      },
                      onSaved: (val) {
                        _authData['email'] = val.trim();
                      },
                    ),
                    TextFormField(
                      style: textStyleWhite,
                      controller: _passwordController,
                      obscureText: true,
                      decoration: DecorationLibrary.loginDecoration(
                          Icons.lock, "Password", "Enter Password", context),
                      validator: (value) {
                        if (value.isEmpty) return 'Password cannot be empty';
                        return null;
                      },
                      onSaved: (val) {
                        _authData['password'] = val;
                      },
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      height: signMode == AuthState.signup ? 60 : 0,
                      child: TextFormField(
                        style: textStyleWhite,
                        decoration: DecorationLibrary.loginDecoration(
                            Icons.lock,
                            "Confirm Password",
                            "Enter Password",
                            context,
                            signMode == AuthState.signup),
                        obscureText: true,
                        validator: signMode == AuthState.signup
                            ? (value) {
                                if (value.isEmpty)
                                  return 'Password cannot be empty';
                                else if (_passwordController.text
                                        .compareTo(value) !=
                                    0) return 'Passwords do not match';
                                return null;
                              }
                            : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              getSigninButton(),
                              getSignupButton(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (signMode == AuthState.signin)
                      TextButton(
                        child: Text(
                          "Forgot password?",
                          textAlign: TextAlign.start,
                        ),
                        onPressed: () async {
                          if (_authData["email"].isNotEmpty &&
                              emailRegExp.hasMatch(_authData["email"])) {
                            try {
                              await Authentication()
                                  .forgotPassword(_authData["email"], context);
                            } on FirebaseAuthException {}
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Reset password email sent to your account'),
                            ));
                          } else
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Enter email to proceed')));
                        },
                      ),
                  ],
                ),
              ),
            ),
          );
  }

  _setSigningMode() {
    FormState formState = _loginKey.currentState;
    if (formState != null) formState.reset();
    setState(() {
      if (signMode == AuthState.signup)
        signMode = AuthState.signin;
      else
        signMode = AuthState.signup;
    });

    if (signMode == AuthState.signup) {
      _animationContainerController.forward();
      _animationButtonController.forward();
    } else {
      _animationContainerController.reverse();
      _animationButtonController.reverse();
    }
  }

  Future<void> _authUser(BuildContext context) async {
    FormState formState = _loginKey.currentState;
    if (formState != null) {
      formState.save();
      if (formState.validate()) {
        FocusScope.of(context).unfocus();
        try {
          setState(() {
            _logging = true;
          });

          await Provider.of<Authentication>(context, listen: false)
              .authenticate(_authData['email'], _authData['password'],
                  signMode == AuthState.signup)
              .then((value) {
            setState(() {
              _logging = false;
            });
          });
        } on FirebaseAuthException catch (error) {
          var errorMessage = 'Authentication failed';
          switch (error.code) {
            case 'wrong-password':
              errorMessage = 'There was a problem with your email or password';
              break;
            case 'user-not-found':
              errorMessage = 'There was a problem with your email or password';
              break;
            case 'email-already-in-use':
              errorMessage = 'There was a problem with your email or password';
              break;
            case 'account-exists-with-different-credential':
              errorMessage = 'There was a problem with your email or password';
              break;
            case 'user-disabled':
              errorMessage =
                  'Your account has been disabled. Please contact an administrator.';
              break;
            case 'invalid-email':
              errorMessage = 'Please enter a valid email address';
              break;
            case 'weak-password':
              errorMessage = 'Your password is too weak';
              break;
            case 'too-many-requests':
              errorMessage =
                  'Your account is temporarily blocked due to consecutive failed login attempts';
              break;
            default:
              errorMessage = 'Unknown problem occured. Please try again later.';
          }

          showMessage(errorMessage);
        }
        setState(() {
          _logging = false;
        });
      }
    }
  }

  void showMessage(String errorMessage) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("An Error Occured!"),
        content: Text(errorMessage),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Widget getSigninButton() {
    return AnimatedBuilder(
      animation: _buttonAnimation,
      builder: (context, ch) => Container(
        width: screenWidth - _buttonAnimation.value,
        child: ch,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          textStyle: TextStyle(
            color: Colors.white,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          primary: signMode == AuthState.signin
              ? Theme.of(context).accentColor
              : Colors.blueGrey,
          elevation: 12,
        ),
        child: Text('Signin'),
        onPressed: signMode == AuthState.signin
            ? () => _authUser(context)
            : _setSigningMode,
      ),
    );
  }

  Widget getSignupButton() {
    return AnimatedBuilder(
      animation: _buttonAnimation,
      builder: (context, ch) => Container(
        width: _buttonAnimation.value,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            textStyle: TextStyle(
              color: Colors.white,
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            primary: signMode == AuthState.signup
                ? Theme.of(context).accentColor
                : Colors.blueGrey,
            elevation: 12,
          ),
          child: Text('Signup'),
          onPressed: signMode == AuthState.signup
              ? () => _authUser(context)
              : _setSigningMode,
        ),
      ),
    );
  }
}
