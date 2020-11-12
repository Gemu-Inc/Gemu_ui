import 'package:Gemu/screens/Profil/profil_screen.dart';
import 'package:Gemu/screens/Welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:Gemu/core/services/auth_service.dart';
import 'package:Gemu/screens/Navigation/nav_screen.dart';

class LoginScreen extends StatefulWidget {
  static final String routeName = 'login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  String _email;
  String _password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).accentColor
            ]),
        title: Text("Sign In"),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: 20.0),
                TextFormField(
                  style: Theme.of(context).textTheme.bodyText1,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: "Email Address"),
                  onSaved: (value) => _email = value,
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  style: Theme.of(context).textTheme.bodyText1,
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                  obscureText: true,
                  decoration: InputDecoration(labelText: "Password"),
                  onSaved: (value) => _password = value,
                ),
                SizedBox(height: 40.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Material(
                    borderRadius: BorderRadius.circular(30.0),
                    color: Theme.of(context).primaryColor,
                    child: MaterialButton(
                      minWidth: 400,
                      child: Text("SIGN IN"),
                      onPressed: _validateAndSignInWithEmailAndPassword,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _validateAndSignInWithEmailAndPassword() async {
    final form = _formKey.currentState;
    form.save();
    // Validate information was correctly entered
    if (form.validate()) {
      print('Form was successfully validated');
      print('Signing in user: Email: $_email Password: $_password');
      // Call the login method with the enter information
      _signInUserWithEmailAndPassword();
    }
  }

  void _signInUserWithEmailAndPassword() async {
    try {
      auth.User signedInUser = await Provider.of<AuthService>(context,
              listen: false)
          .signInUserWithEmailAndPassword(email: _email, password: _password);
      if (signedInUser != null) {
        print(
            'Signed in user: Email: ${signedInUser.email} Password: $_password}');
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) => NavScreen(
                      firebaseUser: signedInUser,
                    )),
            (Route<dynamic> route) => false);
      } else {
        print('Signed in user is null!');
      }
    } on auth.FirebaseAuthException catch (error) {
      print('AuthException: ' + error.message.toString());
      return _buildErrorDialog(context, error.message.toString());
    } on Exception catch (error) {
      print('Exception: ' + error.toString());
      return _buildErrorDialog(context, error.toString());
    }
  }

  Future _buildErrorDialog(BuildContext context, _message) {
    String errorMessage = 'error';
    bool returnToWelcomeScreen = false;

    return showDialog(
      builder: (context) {
        switch (_message) {
          case 'The password is invalid or the user does not have a password.':
            errorMessage = 'Invalid password';
            returnToWelcomeScreen = false;
            break;
          case 'There is no user record corresponding to this identifier. The user may have been deleted.':
            errorMessage = 'Account not found. Please register an account';
            returnToWelcomeScreen = true;
            break;
          case 'The email address is badly formatted.':
            errorMessage = 'Invalid email. Please enter a valid email';
            returnToWelcomeScreen = false;
            break;
          case 'We have blocked all requests from this device due to unusual activity. Try again later. [ Too many unsuccessful login attempts. Please try again later. ]':
            errorMessage =
                'Too many unsuccessful login attempts. Please try again later';
            returnToWelcomeScreen = true;
            break;
          case 'The user account has been disabled by an administrator.':
            errorMessage = 'Your account has been disabled';
            returnToWelcomeScreen = true;
            break;
          case 'The given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section.':
            print(
                'The given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section.');
            break;
          default:
            errorMessage = 'Unknown error occurred';
            returnToWelcomeScreen = true;
            break;
        }
        return AlertDialog(
          title: Text(
            'Error Message',
            style: Theme.of(context).textTheme.headline6,
          ),
          content: Text(
            errorMessage,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          actions: [
            FlatButton(
                child: Text('OK'),
                onPressed: () {
                  returnToWelcomeScreen
                      ? Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  WelcomeScreen()),
                          (Route<dynamic> route) => false)
                      : Navigator.of(context).pop();
                })
          ],
        );
      },
      context: context,
    );
  }
}
