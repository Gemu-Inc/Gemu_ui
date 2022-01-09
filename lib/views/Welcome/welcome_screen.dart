import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:gemu/constants/constants.dart';

import 'package:gemu/views/Login/login_screen.dart';
import 'package:gemu/views/Register/register_screen.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  WelcomeviewState createState() => WelcomeviewState();
}

class WelcomeviewState extends State<WelcomeScreen> {
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
  void dispose() {
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
    return Scaffold(
        body: AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark),
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
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.1),
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8)
                  ]),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                      icon: Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 26,
                      ),
                      onPressed: () =>
                          Navigator.pushNamed(context, GetStarted)),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Welcome to",
                          style: Theme.of(context)
                              .textTheme
                              .headline3!
                              .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                        ),
                        Row(
                          children: [
                            Text(
                              "Gemu",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline3!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.black),
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: AssetImage(
                                            "assets/icons/icon_round.png"),
                                        fit: BoxFit.cover)),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Expanded(
                    child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 35.0),
                        child: Row(
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
                      ),
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height / 14,
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: ElevatedButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        RegisterScreen())),
                            style: TextButton.styleFrom(
                                backgroundColor: Theme.of(context).canvasColor,
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0))),
                            child: Text(
                              'Sign up',
                              style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700),
                            )),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 35.0),
                        child: Row(
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
                      ),
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height / 14,
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: ElevatedButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        LoginScreen())),
                            style: TextButton.styleFrom(
                                backgroundColor: Theme.of(context).canvasColor,
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0))),
                            child: Text(
                              'Sign in',
                              style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700),
                            )),
                      ),
                    ],
                  ),
                )),
                Container(
                  height: MediaQuery.of(context).size.height / 15,
                  child: Column(
                    children: [
                      Container(
                        height: 5,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary
                        ])),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Expanded(
                          child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: () => print('Terms and Conditions'),
                          child: Text(
                            'Terms and Conditions',
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
