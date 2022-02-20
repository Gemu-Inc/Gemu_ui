import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/helpers/helpers.dart';
import 'package:gemu/views/Welcome/welcome_screen.dart';
import 'package:gemu/widgets/text_field_custom.dart';
import 'package:gemu/services/auth_service.dart';
import 'package:helpers/helpers.dart';

class LoginScreen extends StatefulWidget {
  @override
  Loginviewstate createState() => Loginviewstate();
}

class Loginviewstate extends State<LoginScreen> {
  bool isDayMood = false;
  bool isLoading = false;

  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  late FocusNode _focusNodeEmail;
  late FocusNode _focusNodePassword;

  UserCredential? result;

  void timeMood() {
    int hour = DateTime.now().hour;

    if (hour >= 8 && hour <= 18) {
      setState(() {
        isDayMood = true;
      });
    } else {
      setState(() {
        isDayMood = false;
      });
    }
  }

  Future<bool> _willPopCallback() async {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => WelcomeScreen()),
        (route) => false);
    return true;
  }

  _signIn(String email, String password) async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(Duration(seconds: 2));

    AuthService.signIn(context: context, email: email, password: password);

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    timeMood();
    _emailController = TextEditingController();
    _focusNodeEmail = FocusNode();
    _passwordController = TextEditingController();
    _focusNodePassword = FocusNode();

    _emailController.addListener(() {
      setState(() {});
    });
    _passwordController.addListener(() {
      setState(() {});
    });
    _focusNodeEmail.addListener(() {
      setState(() {});
    });
    _focusNodePassword.addListener(() {
      setState(() {});
    });
  }

  @override
  void deactivate() {
    _emailController.removeListener(() {
      setState(() {});
    });
    _focusNodeEmail.removeListener(() {
      setState(() {});
    });
    _passwordController.removeListener(() {
      setState(() {});
    });
    _focusNodePassword.removeListener(() {
      setState(() {});
    });
    super.deactivate();
  }

  @override
  void dispose() {
    _focusNodeEmail.dispose();
    _focusNodePassword.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            body: AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness:
                        Theme.of(context).brightness == Brightness.dark
                            ? Brightness.light
                            : Brightness.dark),
                child: GestureDetector(
                  onTap: () => Helpers.hideKeyboard(context),
                  child: Column(children: [
                    topLoginEmail(),
                    Container(
                      height: MediaQuery.of(context).size.height / 6,
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      alignment: Alignment.center,
                      child: Text(
                        "Plus que ton email et ton mot de passe à te souvenir et c'est parti!",
                        style: mystyle(12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                        child: Container(
                      child: loginEmail(),
                    ))
                  ]),
                ))),
        onWillPop: () => _willPopCallback());
  }

  Widget topLoginEmail() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: AppBar(
        elevation: 0,
        shadowColor: Colors.transparent,
        leading: IconButton(
            onPressed: () {
              Helpers.hideKeyboard(context);
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => WelcomeScreen()),
                  (route) => false);
            },
            icon: Icon(Icons.arrow_back_ios,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                size: 25)),
        title: Text(
          "Connexion",
          style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 23),
        ),
        centerTitle: false,
      ),
    );
  }

  Widget loginEmail() {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Container(
            height: MediaQuery.of(context).size.height / 12,
            child: TextFieldCustom(
              context: context,
              controller: _emailController,
              focusNode: _focusNodeEmail,
              label: 'Email',
              obscure: false,
              icon: Icons.mail,
              textInputAction: TextInputAction.next,
              textInputType: TextInputType.emailAddress,
              clear: () {
                setState(() {
                  _emailController.clear();
                });
              },
              submit: (value) {
                value = _emailController.text;
                _focusNodeEmail.unfocus();
                FocusScope.of(context).requestFocus(_focusNodePassword);
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 25.0),
          child: Container(
            height: MediaQuery.of(context).size.height / 12,
            child: TextFieldCustom(
              context: context,
              controller: _passwordController,
              focusNode: _focusNodePassword,
              label: 'Mot de passe',
              obscure: true,
              icon: Icons.lock,
              textInputAction: TextInputAction.go,
              clear: () {
                setState(() {
                  _passwordController.clear();
                });
              },
              submit: (value) {
                value = _passwordController.text;
                _focusNodePassword.unfocus();
                _signIn(_emailController.text, value);
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 25.0),
          child: Container(
            height: MediaQuery.of(context).size.height / 12,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  _signIn(_emailController.text, _passwordController.text),
              style: ElevatedButton.styleFrom(
                  elevation: 6,
                  shadowColor: Theme.of(context).shadowColor,
                  primary: isDayMood ? Color(0xFFE38048) : Color(0xFF947B8F),
                  onPrimary: Theme.of(context).canvasColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  )),
              child: isLoading
                  ? SizedBox(
                      height: 15,
                      width: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.0,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    )
                  : Text(
                      'Se connecter',
                      style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ),
        const SizedBox(
          height: 15.0,
        ),
        RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: "Mot de passe oublié",
              recognizer: TapGestureRecognizer()
                ..onTap = () => print("Mot de passe oublié"),
              style: mystyle(12, Theme.of(context).primaryColor),
            )),
        const SizedBox(
          height: 5.0,
        ),
        RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                text: "Vous n'avez pas encore un compte? ",
                style: mystyle(
                  12,
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
                children: [
                  TextSpan(
                    text: "Inscription",
                    style: mystyle(12, Theme.of(context).primaryColor),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Helpers.inscriptionBottomSheet(context),
                  )
                ])),
      ],
    );
  }
}
