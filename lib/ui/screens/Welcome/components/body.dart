import 'package:Gemu/constants/route_names.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/size_config.dart';
//import 'package:slider_button/slider_button.dart';
import 'package:Gemu/constants/variables.dart';

import 'land.dart';
import 'sun.dart';

class Body extends StatefulWidget {
  @override
  BodyState createState() => BodyState();
}

class BodyState extends State<Body> {
  bool isFullSun = true;
  bool isDayMood = true;
  Duration _duration = Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    timeMood();
  }

  void timeMood() {
    int hour = DateTime.now().hour;

    if (hour >= 8 && hour <= 18) {
      setState(() {
        isDayMood = true;
        isFullSun = true;
      });
    } else {
      setState(() {
        isFullSun = false;
        isDayMood = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Color> lightBgColors = [
      Color(0xFF947B8F),
      Color(0xFFB27D75),
      Color(0xFFE38048),
      if (isFullSun) Color(0xFFFF9D80),
    ];
    var darkBgColors = [
      Color(0xFF4075DA),
      Color(0xFF6E78B1),
      Color(0xFF947B8F),
      if (isFullSun) Color(0xFFE3DDB9)
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
      child: Stack(
        children: [
          Sun(isFullSun: isFullSun),
          Land(
            dayMood: isDayMood,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VerticalSpacing(of: 50),
                  Text(
                    "Welcome to Gemu",
                    style: Theme.of(context).textTheme.headline3!.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  VerticalSpacing(of: 10),
                  Text(
                    "Create your own virtual world",
                    style: TextStyle(color: Colors.white),
                  ),
                  VerticalSpacing(of: 40),
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushNamed(GetStartedRoute),
                    child: Container(
                      height: 50,
                      width: 150,
                      color: Colors.pink,
                      child: Text('Slider button'),
                    ),
                  )
                  /*SliderButton(
                    dismissible: false,
                    vibrationFlag: false,
                    height: 50,
                    width: SizeConfig.screenWidth! / 2,
                    buttonSize: 50,
                    action: () {
                      Navigator.of(context).pushNamed(GetStartedRoute);
                    },
                    label:
                        Text('Get started', style: mystyle(12, Colors.white)),
                    icon: Center(
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF222831),
                        size: 23,
                      ),
                    ),
                    buttonColor: Colors.white,
                    backgroundColor: Color(0xFF222831),
                    baseColor: Colors.white,
                    highlightedColor:
                        isDayMood ? Color(0xFFB27D75) : Color(0xFF6E78B1),
                  )*/
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
