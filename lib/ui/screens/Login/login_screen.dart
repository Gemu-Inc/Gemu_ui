import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gemu/services/auth_service.dart';

import 'package:gemu/ui/constants/size_config.dart';
import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/ui/constants/route_names.dart';
import 'package:gemu/ui/screens/Welcome/welcome_screen.dart';
import 'package:gemu/ui/widgets/text_field_custom.dart';

class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
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

    AuthService.instance
        .signIn(context: context, email: email, password: password);

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
        child: AnimatedContainer(
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
          child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.1),
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8)
                  ])),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: Container(
                    padding: EdgeInsets.all(7.5),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  WelcomeScreen()),
                          (route) => false),
                      style: TextButton.styleFrom(
                          alignment: Alignment.center,
                          backgroundColor: Colors.black.withOpacity(0.3),
                          elevation: 0,
                          shape: CircleBorder(
                              side: BorderSide(color: Colors.black))),
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 16,
                      ),
                    ),
                  ),
                  title: Text('Login', style: mystyle(25, Colors.white)),
                  centerTitle: true,
                ),
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(child: login()),
                  ],
                ),
              )),
        ),
        onWillPop: () => _willPopCallback());
  }

  Widget login() {
    return ListView(
      shrinkWrap: true,
      children: [
        VerticalSpacing(
          of: 60.0,
        ),
        Container(
          width: SizeConfig.screenWidth,
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
        VerticalSpacing(
          of: 20,
        ),
        Container(
          width: SizeConfig.screenWidth,
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
        VerticalSpacing(
          of: 80,
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
        VerticalSpacing(
          of: 20,
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
              onTap: () => Navigator.pushNamed(context, RegisterScreenRoute),
              child: Text(
                'Register',
                style: mystyle(12, Theme.of(context).primaryColor),
              ),
            )
          ],
        ),
        VerticalSpacing(
          of: 20.0,
        )
      ],
    );
  }
}
