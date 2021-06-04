import 'package:Gemu/constants/route_names.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/size_config.dart';
import 'package:Gemu/constants/variables.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class Body extends StatefulWidget {
  @override
  BodyState createState() => BodyState();
}

class BodyState extends State<Body> {
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
    return AnimatedContainer(
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
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_back_ios,
                        size: 25,
                      ),
                      Text(
                        'Back',
                        style: mystyle(16, Colors.black38),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(child: login())
          ],
        ),
      ),
    );
  }

  Widget login() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('Login', style: mystyle(30)),
        Expanded(
            child: ListView(
          shrinkWrap: true,
          children: [
            VerticalSpacing(
              of: 60.0,
            ),
            Container(
              width: SizeConfig.screenWidth,
              margin: EdgeInsets.only(left: 20, right: 20),
              child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                      fillColor: Theme.of(context).canvasColor,
                      filled: true,
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      labelStyle: mystyle(15),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)))),
            ),
            VerticalSpacing(
              of: 20,
            ),
            Container(
              width: SizeConfig.screenWidth,
              margin: EdgeInsets.only(left: 20, right: 20),
              child: TextField(
                  obscureText: true,
                  controller: _passwordController,
                  decoration: InputDecoration(
                      fillColor: Theme.of(context).canvasColor,
                      filled: true,
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      labelStyle: mystyle(15),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)))),
            ),
            VerticalSpacing(
              of: 60,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              margin: EdgeInsets.symmetric(horizontal: 30.0),
              decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor,
                      offset: Offset(-5.0, 5.0),
                    )
                  ]),
              child: GestureDetector(
                onTap: () {
                  _signIn(_emailController.text, _passwordController.text);
                },
                child: Center(
                  child: Text(
                    'Login',
                    style: mystyle(15),
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
                  onTap: () =>
                      Navigator.pushNamed(context, RegisterScreenRoute),
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
        )),
      ],
    );
  }

  Future<void> _signIn(String email, String password) async {
    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        Navigator.pushNamedAndRemoveUntil(
            context, ConnectionScreenRoute, (route) => false);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'invalid-email') {
          print('Invalid email');
          SnackBar snackBar = SnackBar(
              backgroundColor: Color(0xFF222831),
              content: Container(
                height: 30,
                width: SizeConfig.screenWidth,
                alignment: Alignment.center,
                child: Text(
                  'Try again, invalid email',
                  style: mystyle(12, Colors.white),
                ),
              ));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else if (e.code == 'user-disabled') {
          print('user disabled');
          SnackBar snackBar = SnackBar(
              backgroundColor: Color(0xFF222831),
              content: Container(
                height: 30,
                width: SizeConfig.screenWidth,
                alignment: Alignment.center,
                child: Text(
                  'Try again, user disabled',
                  style: mystyle(12, Colors.white),
                ),
              ));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else if (e.code == 'user-not-found') {
          print('No user found for that email.');
          SnackBar snackBar = SnackBar(
              backgroundColor: Color(0xFF222831),
              content: Container(
                height: 30,
                width: SizeConfig.screenWidth,
                alignment: Alignment.center,
                child: Text(
                  'Try again, no user found for that email',
                  style: mystyle(12, Colors.white),
                ),
              ));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
          SnackBar snackBar = SnackBar(
              backgroundColor: Color(0xFF222831),
              content: Container(
                height: 30,
                width: SizeConfig.screenWidth,
                alignment: Alignment.center,
                child: Text(
                  'Try again, email or passord are wrong',
                  style: mystyle(12, Colors.white),
                ),
              ));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          print('Try again');
          SnackBar snackBar = SnackBar(
              backgroundColor: Color(0xFF222831),
              content: Container(
                height: 30,
                width: SizeConfig.screenWidth,
                alignment: Alignment.center,
                child: Text(
                  'Try again',
                  style: mystyle(12, Colors.white),
                ),
              ));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    } else {
      SnackBar snackBar = SnackBar(
          backgroundColor: Color(0xFF222831),
          content: Container(
            height: 30,
            width: SizeConfig.screenWidth,
            alignment: Alignment.center,
            child: Text(
              'Try again, no email, password',
              style: mystyle(12, Colors.white),
            ),
          ));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
