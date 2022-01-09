import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:gemu/services/auth_service.dart';

import 'package:gemu/constants/constants.dart';

import 'package:gemu/views/Welcome/welcome_screen.dart';
import 'package:gemu/widgets/text_field_custom.dart';

class LoginScreen extends StatefulWidget {
  @override
  Loginviewstate createState() => Loginviewstate();
}

class Loginviewstate extends State<LoginScreen> {
  Duration _duration = Duration(seconds: 1);
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
    List<Color> lightBgColors = [
      Color(0xFF947B8F),
      Color(0xFFB27D75),
      Color(0xFFE38048),
    ];
    var darkBgColors = [
      Color(0xFF4075DA),
      Color(0xFF6E78B1),
      Color(0xFF947B8F),
    ];
    return WillPopScope(
        child: Scaffold(
          body: AnimatedContainer(
              duration: _duration,
              curve: Curves.easeInOut,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDayMood ? lightBgColors : darkBgColors,
                ),
              ),
              child: SafeArea(
                child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                          Theme.of(context)
                              .scaffoldBackgroundColor
                              .withOpacity(0.1),
                          Theme.of(context)
                              .scaffoldBackgroundColor
                              .withOpacity(0.8)
                        ])),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height / 8,
                          child: Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 6,
                                alignment: Alignment.center,
                                child: IconButton(
                                    onPressed: () =>
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        WelcomeScreen()),
                                            (route) => false),
                                    icon: Icon(Icons.arrow_back_ios,
                                        color: Theme.of(context).canvasColor)),
                              ),
                              Expanded(
                                  child: Center(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      right: MediaQuery.of(context).size.width /
                                          6),
                                  child: Text(
                                    'Login',
                                    style: mystyle(25, Colors.white),
                                  ),
                                ),
                              ))
                            ],
                          ),
                        ),
                        Expanded(child: login()),
                      ],
                    )),
              )),
        ),
        onWillPop: () => _willPopCallback());
  }

  Widget login() {
    return ListView(
      shrinkWrap: true,
      children: [
        const SizedBox(
          height: 60.0,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(left: 20, right: 20),
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
        const SizedBox(
          height: 20.0,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(left: 20, right: 20),
          child: TextFieldCustom(
            context: context,
            controller: _passwordController,
            focusNode: _focusNodePassword,
            label: 'Password',
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
        const SizedBox(
          height: 80.0,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 45.0),
          child: Container(
            height: MediaQuery.of(context).size.height / 14,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: ElevatedButton(
              onPressed: () =>
                  _signIn(_emailController.text, _passwordController.text),
              style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).canvasColor,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0))),
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
                      'Login',
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
          height: 20.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account?",
              style: mystyle(12),
            ),
            SizedBox(
              width: 5,
            ),
            InkWell(
              onTap: () => Navigator.pushNamed(context, Register),
              child: Text(
                'Register',
                style: mystyle(12, Theme.of(context).primaryColor),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 20.0,
        ),
      ],
    );
  }
}
