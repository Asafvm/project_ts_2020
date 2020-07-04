import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:provider/provider.dart';
import 'package:teamshare/providers/authentication.dart';
import 'package:teamshare/providers/http_exception.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = '/login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.lightBlue, Colors.lightGreen],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Team Share\n',
                    style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    children: [
                      TextSpan(
                        text: 'Big Solution for Small Buisness',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                            color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
              SingleChildScrollView(child: AuthForm()),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthForm extends StatefulWidget {
  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> with TickerProviderStateMixin {
  final _loginKey = GlobalKey<FormState>();

  AnimationController _animationController;

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  bool _signup = false;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _passwordController = TextEditingController();

    return Form(
      key: _loginKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
              icon: Icon(Icons.person),
              hintText: 'Enter Email',
              labelText: 'Email',
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              //RegExp regExp = RegExp(r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$',caseSensitive: false,multiLine: false);
              RegExp regExp = RegExp(r'^[a-zA-Z0-9]+@.[a-zA-Z0-9]+.[a-zA-Z]+',
                  caseSensitive: false, multiLine: false);

              if (value.isEmpty || !regExp.hasMatch(value))
                return 'Insert a valid eMail address';
              return null;
            },
            onSaved: (val) {
              _authData['email'] = val.trim();
            },
          ),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              icon: Icon(Icons.lock),
              hintText: 'Enter Password',
              labelText: 'Enter Password',
            ),
            validator: (value) {
              if (value.isEmpty) return 'Password cannot be empty';
              return null;
            },
            onSaved: (val) {
              _authData['password'] = val;
            },
          ),
          if (_signup)
            TextFormField(
              decoration: const InputDecoration(
                icon: Icon(Icons.lock),
                hintText: 'Confirm Password',
                labelText: 'Confirm Password',
              ),
              obscureText: true,
              validator: (value) {
                if (value.isEmpty)
                  return 'Password cannot be empty';
                else if (_passwordController.text.compareTo(value) != 0)
                  return 'Passwords do not match';
                return null;
              },
              onSaved: (val) {
                _authData['password'] = val;
              },
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                AnimatedContainer(
                  duration: Duration(seconds: 1),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: getRaisedButton('Signin', !_signup),
                      ),
                      Expanded(
                        child: getRaisedButton('Signup', _signup),
                      )
                    ],
                  ),
                ),
                // GoogleSignInButton(
                //   onPressed: () async => {
                //     await _googleSignIn.signIn()
                //   }, //_authUserWithGoogle(context),
                //   darkMode: false,
                //   text: 'Sign in with Google',
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _setSigningMode() {
    setState(() {
      _signup = !_signup;
    });
    _animationController.forward();
  }

  Future<void> _authUser(BuildContext context) async {
    _loginKey.currentState.save();
    if (_loginKey.currentState.validate()) {
      try {
        await Provider.of<Authentication>(context, listen: false)
            .authenticate(_authData['email'], _authData['password'], _signup)
            .then((value) => print('Success'));

        //Navigator.of(context).pushReplacementNamed(MainScreen.routeName);

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
          FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Widget getRaisedButton(String text, bool signup) {
    return RaisedButton(
      animationDuration: Duration(milliseconds: 300),
      textColor: signup ? Colors.black : Colors.white,
      shape: signup
          ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
          : RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      color: signup ? Theme.of(context).accentColor : Colors.white24,
      elevation: 12,
      child: Text(text),
      onPressed: signup ? () => _authUser(context) : _setSigningMode,
    );
  }
}
