import 'package:Gemu/constants/route_names.dart';
import 'package:flutter/material.dart';

import 'package:Gemu/size_config.dart';
import 'package:Gemu/constants/variables.dart';

class Body extends StatefulWidget {
  @override
  BodyState createState() => BodyState();
}

class BodyState extends State<Body> {
  Duration _duration = Duration(seconds: 1);
  bool isDayMood = false;

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
                Text(
                  'Sign up',
                  style: mystyle(30),
                ),
                VerticalSpacing(
                  of: 40,
                ),
                InkWell(
                  onTap: () =>
                      Navigator.pushNamed(context, RegisterFirstScreenRoute),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2,
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Text(
                        "Start",
                        style: mystyle(15, Colors.white, FontWeight.w700),
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
                      'I agree to',
                      style: mystyle(10),
                    ),
                    SizedBox(
                      width: 1.0,
                    ),
                    InkWell(
                      onTap: null,
                      child: Text(
                        'terms of policy',
                        style: mystyle(12, Colors.purple),
                      ),
                    )
                  ],
                ),
                VerticalSpacing(
                  of: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already an account?',
                      style: mystyle(12),
                    ),
                    SizedBox(
                      width: 5.0,
                    ),
                    InkWell(
                      onTap: () =>
                          Navigator.pushNamed(context, LoginScreenRoute),
                      child: Text(
                        'Login',
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
}
