import 'package:Gemu/constants/route_names.dart';
import 'package:Gemu/constants/variables.dart';
import 'package:Gemu/ui/screens/Register/register_screen.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/size_config.dart';
import 'package:intro_slider/slide_object.dart';

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
    Navigator.pushNamed(context, RegisterScreenRoute);
  }

  @override
  void initState() {
    super.initState();
    timeMood();

    slides.add(Slide(
        title: 'COMMUNITY',
        styleTitle: mystyle(15),
        pathImage: 'lib/assets/images/signup.png',
        description: "Create, share, watch and more",
        styleDescription: mystyle(11),
        backgroundColor: Colors.transparent));
    slides.add(Slide(
        title: 'RECORD',
        styleTitle: mystyle(15),
        pathImage: 'lib/assets/images/login.png',
        description: "Record and save everywhere and evrything",
        styleDescription: mystyle(11),
        backgroundColor: Colors.transparent));
    slides.add(Slide(
        title: 'DISCOVER',
        styleTitle: mystyle(15),
        pathImage: 'lib/assets/images/chat.png',
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
        child: IntroSlider(slides: this.slides, onDonePress: this.onDonePress));
  }
}
