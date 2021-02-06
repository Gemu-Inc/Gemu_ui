import 'package:Gemu/constants/route_names.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/size_config.dart';
import 'package:Gemu/constants/variables.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Body extends StatefulWidget {
  @override
  BodyState createState() => BodyState();
}

class BodyState extends State<Body> {
  Duration _duration = Duration(seconds: 1);
  bool isDayMood = false;
  TextEditingController _emailController;
  TextEditingController _passwordController;

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
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Login', style: mystyle(30)),
                VerticalSpacing(
                  of: 40,
                ),
                Container(
                  width: SizeConfig.screenWidth,
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                          fillColor: Color(0xFF222831),
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
                          fillColor: Color(0xFF222831),
                          filled: true,
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          labelStyle: mystyle(15),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)))),
                ),
                VerticalSpacing(
                  of: 20,
                ),
                InkWell(
                  onTap: () async {
                    try {
                      print(_emailController.text);
                      print(_passwordController.text);
                      var result = await FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                              email: _emailController.text,
                              password: _passwordController.text);
                      if (result != null) {
                        Navigator.pushNamedAndRemoveUntil(
                            context, ConnectionScreenRoute, (route) => false);
                      }
                    } catch (e) {
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
                      Scaffold.of(context).showSnackBar(snackBar);
                    }
                  },
                  child: Container(
                    width: SizeConfig.screenWidth / 2,
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10)),
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
                        style: mystyle(12, Colors.purple),
                      ),
                    )
                  ],
                )
              ],
            ),
          )),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
