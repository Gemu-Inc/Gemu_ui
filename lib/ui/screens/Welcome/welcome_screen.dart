import 'package:flutter/material.dart';

import 'package:gemu/ui/constants/size_config.dart';
import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/ui/constants/route_names.dart';
import 'package:gemu/ui/screens/Login/login_screen.dart';
import 'package:gemu/ui/screens/Register/register_screen.dart';
import 'package:gemu/ui/widgets/bouncing_button.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Body(),
    );
  }
}

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
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                Theme.of(context).scaffoldBackgroundColor
              ]),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                    icon: Icon(Icons.info_outline),
                    onPressed: () =>
                        Navigator.pushNamed(context, GetStartedRoute)),
              ),
              VerticalSpacing(
                of: 10.0,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  height: 130,
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 30.0, bottom: 10.0),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(10.0),
                                image: DecorationImage(
                                    image:
                                        AssetImage("assets/icons/icon.png"))),
                          ),
                        ),
                      ),
                      Text(
                        "Welcome to Gemu",
                        style: Theme.of(context).textTheme.headline3!.copyWith(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              VerticalSpacing(
                of: 60.0,
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 2,
                        width: MediaQuery.of(context).size.width / 4,
                        color: Theme.of(context).canvasColor,
                      ),
                      Text(
                        'Start the adventure',
                        style: mystyle(12),
                      ),
                      Container(
                        height: 2,
                        width: MediaQuery.of(context).size.width / 4,
                        color: Theme.of(context).canvasColor,
                      )
                    ],
                  ),
                  VerticalSpacing(
                    of: 40,
                  ),
                  BouncingButton(
                    title: 'Sign up',
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  RegisterScreen()));
                    },
                  ),
                  VerticalSpacing(
                    of: 60,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 2,
                        width: MediaQuery.of(context).size.width / 4,
                        color: Theme.of(context).canvasColor,
                      ),
                      Text(
                        'Already an account?',
                        style: mystyle(12),
                      ),
                      Container(
                        height: 2,
                        width: MediaQuery.of(context).size.width / 4,
                        color: Theme.of(context).canvasColor,
                      )
                    ],
                  ),
                  VerticalSpacing(
                    of: 40,
                  ),
                  BouncingButton(
                    title: 'Login',
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  LoginScreen()));
                    },
                  )
                ],
              )),
              VerticalSpacing(
                of: 60.0,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  children: [
                    Container(
                      height: 5,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).accentColor
                      ])),
                    ),
                    VerticalSpacing(
                      of: 10.0,
                    ),
                    InkWell(
                      onTap: () => print('Terms and Conditions'),
                      child: Text(
                        'Terms and Conditions',
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
