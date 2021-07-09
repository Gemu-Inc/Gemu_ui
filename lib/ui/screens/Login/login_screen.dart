import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gemu/services/auth_service.dart';

import 'package:gemu/ui/constants/size_config.dart';
import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/ui/constants/route_names.dart';
import 'package:gemu/ui/screens/Welcome/welcome_screen.dart';
import 'package:gemu/ui/widgets/bouncing_loading_button.dart';
import 'package:gemu/ui/widgets/text_field_custom.dart';

class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  Duration _duration = Duration(seconds: 1);
  bool isDayMood = false;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

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

  _hideKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  _signIn(String email, String password) {
    _hideKeyboard();

    AuthService.instance
        .signIn(context: context, email: email, password: password);
  }

  @override
  void initState() {
    super.initState();
    timeMood();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
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
            width: double.infinity,
            height: SizeConfig.screenHeight,
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
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                    Theme.of(context).scaffoldBackgroundColor
                  ])),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 75,
                    child: Padding(
                      padding: EdgeInsets.only(top: 25.0, left: 15.0),
                      child: GestureDetector(
                        onTap: () => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    WelcomeScreen()),
                            (route) => false),
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_back_ios,
                              size: 25,
                            ),
                            Text(
                              'Back',
                              style: mystyle(16, Colors.white60),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Text('Login', style: mystyle(30)),
                  Expanded(child: login()),
                  Expanded(
                      child: Column(
                    children: [
                      BouncingLoadingButton(
                          title: 'Login',
                          onPressed: () {
                            _signIn(_emailController.text,
                                _passwordController.text);
                          }),
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
                            onTap: () => Navigator.pushNamed(
                                context, RegisterScreenRoute),
                            child: Text(
                              'Register',
                              style: mystyle(12, Theme.of(context).accentColor),
                            ),
                          )
                        ],
                      ),
                      VerticalSpacing(
                        of: 10.0,
                      )
                    ],
                  ))
                ],
              ),
            ),
          ),
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
              label: 'Email',
              obscure: false,
              icon: Icons.mail),
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
              label: 'Password',
              obscure: true,
              icon: Icons.lock),
        ),
        VerticalSpacing(
          of: 80,
        ),
      ],
    );
  }
}
