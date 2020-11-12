import 'package:Gemu/screens/Navigation/nav_screen.dart';
import 'package:Gemu/screens/Welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:Gemu/core/repository/firebase_repository.dart';
import 'package:Gemu/core/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  static final String routeName = 'register';

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _registerFormKey = GlobalKey<FormState>();
  final FirebaseRepository firebaseRepository = FirebaseRepository();

  String _name;
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
        title: Text('Register'),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Form(
            key: _registerFormKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: "Name"),
                    onSaved: (value) => _name = value,
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'Please enter an email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: "Email Adress"),
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (value) => _email = value,
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    validator: (String value) {
                      if (value.isEmpty) {
                        return "Please enter a password";
                      }
                      if (value.length < 6) {
                        return 'Password should be at least 6 characters';
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: "Password"),
                    obscureText: true,
                    onSaved: (value) => _password = value,
                  ),
                  SizedBox(
                    height: 40.0,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Material(
                      borderRadius: BorderRadius.circular(30.0),
                      color: Theme.of(context).accentColor,
                      child: MaterialButton(
                        minWidth: 400,
                        child: Text('SIGN UP'),
                        onPressed: validateAndRegisterUser,
                      ),
                    ),
                  )
                ],
              ),
            )),
      ),
    );
  }

  validateAndRegisterUser() async {
    final form = _registerFormKey.currentState;
    form.save();

    if (form.validate()) {
      print('Form was successfully validated');
      registerUserWithEmailAndPassword();
    }
  }

  void registerUserWithEmailAndPassword() async {
    try {
      auth.User newUser = await Provider.of<AuthService>(context, listen: false)
          .registerUserWithEmailAndPassword(
              name: _name, email: _email, password: _password);
      if (newUser != null) {
        print('Registered new user');
        firebaseRepository.createUserInDatabaseWithEmail(newUser);

        auth.User currentUser =
            await Provider.of<AuthService>(context, listen: false).getUser();
        if (currentUser != null) {
          print('Registered user was signed in');
        } else {
          print('User was registered but not signed in');
        }
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => NavScreen(
                      firebaseUser: newUser,
                    )),
            (route) => false);
      }
    } on auth.FirebaseAuthException catch (error) {
      print('AuthException: ' + error.message.toString());
      return _buildErrorDialog(context, error.toString());
    }
  }

  Future _buildErrorDialog(BuildContext context, _message) {
    String errorMessage = 'error';
    bool returnToWelcomeScreen = false;

    return showDialog(
      builder: (context) {
        switch (_message) {
          case 'PlatformException(ERROR_EMAIL_ALREADY_IN_USE, The email address is already in use by another account., null)':
            errorMessage =
                'This account is already registered. Please return to sign in';
            returnToWelcomeScreen = true;
            break;
          case 'PlatformException(ERROR_NETWORK_REQUEST_FAILED, A network error (such as timeout, interrupted connection or unreachable host) has occurred., null)':
            errorMessage =
                'A network error has occurred. Please try again when the connection is stable';
            returnToWelcomeScreen = true;
            break;
          case 'PlatformException(ERROR_INVALID_EMAIL, The email address is badly formatted., null)':
            errorMessage = 'Invalid email. Please enter a valid email';
            returnToWelcomeScreen = false;
            break;
          default:
            errorMessage = 'Unknown error occurred';
            returnToWelcomeScreen = true;
            break;
        }
        return AlertDialog(
          title: Text('Error Message',
              style: Theme.of(context).textTheme.headline6),
          content:
              Text(errorMessage, style: Theme.of(context).textTheme.bodyText1),
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
