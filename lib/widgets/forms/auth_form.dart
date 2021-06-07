import 'dart:core';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  Animation<double> _opacityAnimation;
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
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _animationContainerController, curve: Curves.easeInOut),
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

    InputDecoration _getInputDecoration(
        IconData icon, String label, String hint) {
      final inputDecoration = InputDecoration(
        icon: Icon(icon, color: Colors.white),
        hintStyle: textStyleWhite.copyWith(color: Colors.grey[500]),
        labelText: label,
        labelStyle: textStyleWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 1,
              style: BorderStyle.solid),
        ),
      );
      return inputDecoration;
    }

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
            height: signMode == AuthState.signup ? 350 : 280,
            child: SingleChildScrollView(
              child: Form(
                key: _loginKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      style: textStyleWhite,
                      decoration: _getInputDecoration(
                          Icons.email, "Email", "Enter Email"),
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
                      decoration: _getInputDecoration(
                          Icons.lock, "Password", "Enter Password"),
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
                      constraints: BoxConstraints(
                          minHeight: signMode == AuthState.signup ? 60 : 0,
                          maxHeight: signMode == AuthState.signup ? 120 : 0),
                      child: FadeTransition(
                        opacity: _opacityAnimation,
                        child: TextFormField(
                          style: textStyleWhite,
                          decoration: _getInputDecoration(
                              Icons.lock, "Confirm Password", "Enter Password"),
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
                        onPressed: () {
                          if (_authData["email"].isNotEmpty &&
                              !emailRegExp.hasMatch(_authData["email"]))
                            Authentication()
                                .forgotPassword(_authData["email"], context);
                        },
                      ),
                  ],
                ),
              ),
            ),
          );
  }

  _setSigningMode() {
    setState(() {
      FormState formState = _loginKey.currentState;
      if (formState != null) formState.reset();
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
              .then((value) => _setLogging());
        } catch (error) {
          var errorMessage = 'Authentication failed';
          if (error.toString().contains('EMAIL_EXISTS'))
            errorMessage = 'Email already in use';
          else if (error.toString().contains('ERROR_EMAIL_ALREADY_IN_USE'))
            errorMessage = 'This email already registered';
          else if (error.toString().contains('ERROR_WRONG_PASSWORD'))
            errorMessage = 'Wrong password';
          else if (error.toString().contains('INVALID_EMAIL'))
            errorMessage = 'Please use a valid email';
          else if (error.toString().contains('WEAK_PASSWORD'))
            errorMessage = 'Your password is too weak';
          else if (error.toString().contains('INVALID_PASSWORD'))
            errorMessage = 'Wrong password';
          else if (error.toString().contains('EMAIL_NOT_FOUND'))
            errorMessage = 'This email is not registered';
          else
            errorMessage = 'Unknown problem occured. $error';
          showMessage(errorMessage);
          _setLogging();
        }
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
        child: ch,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          textStyle: TextStyle(
            color: Colors.white,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
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
    );
  }

  _setLogging() {
    setState(() {
      _logging = !_logging;
    });
  }
}
