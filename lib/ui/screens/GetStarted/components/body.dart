import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';

import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/ui/constants/size_config.dart';

class Body extends StatefulWidget {
  @override
  BodyState createState() => BodyState();
}

class BodyState extends State<Body> {
  bool isDayMood = true;
  Duration _duration = Duration(seconds: 1);

  List<Slide> slides = [];

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

  void onDonePress() {
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    timeMood();

    slides.add(Slide(
        title: 'COMMUNITY',
        styleTitle: mystyle(15),
        pathImage: 'assets/images/signup.png',
        description: "Create, share, watch and more",
        styleDescription: mystyle(11),
        backgroundColor: Colors.transparent));
    slides.add(Slide(
        title: 'RECORD',
        styleTitle: mystyle(15),
        pathImage: 'assets/images/login.png',
        description: "Record and save everywhere and everything",
        styleDescription: mystyle(11),
        backgroundColor: Colors.transparent));
    slides.add(Slide(
        title: 'DISCOVER',
        styleTitle: mystyle(15),
        pathImage: 'assets/images/chat.png',
        description: "Discover new games and communities",
        styleDescription: mystyle(11),
        backgroundColor: Colors.transparent));
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
          child: IntroSlider(
            colorDot: Theme.of(context).accentColor.withOpacity(0.5),
            colorActiveDot: Theme.of(context).accentColor,
            sizeDot: 13.0,

            // Skip button
            colorSkipBtn: Color(0x33000000),
            highlightColorSkipBtn: Color(0xff000000),

            // Next button
            showNextBtn: true,

            // Done button
            colorDoneBtn: Color(0x33000000),
            highlightColorDoneBtn: Color(0xff000000),
            onDonePress: this.onDonePress,

            slides: this.slides,
          ),
        ));
  }
}
