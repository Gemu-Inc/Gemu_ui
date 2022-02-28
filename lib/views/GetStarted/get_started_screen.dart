import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';

import 'package:gemu/constants/constants.dart';

class GetStartedScreen extends StatefulWidget {
  @override
  _GetStartedScreenState createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  List<Slide> slides = [];

  void onDonePress() {
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();

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
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness:
                    Theme.of(context).brightness == Brightness.dark
                        ? Brightness.light
                        : Brightness.dark),
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.1),
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8)
                  ])),
              child: IntroSlider(
                colorDot: Theme.of(context).primaryColor.withOpacity(0.5),
                colorActiveDot: Theme.of(context).primaryColor,
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
            )));
  }
}
