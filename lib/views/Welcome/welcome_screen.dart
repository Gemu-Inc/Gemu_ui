import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/views/GetStarted/get_started_screen.dart';

import 'package:gemu/views/Login/login_screen.dart';
import 'package:gemu/views/Register/register_screen.dart';
import 'package:gemu/widgets/custom_clipper.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  WelcomeviewState createState() => WelcomeviewState();
}

class WelcomeviewState extends State<WelcomeScreen> {
  bool isDayMood = false;

  List<Color> lightBgColors = [
    Color(0xFF947B8F).withOpacity(0.8),
    Color(0xFFB27D75).withOpacity(0.8),
    Color(0xFFE38048).withOpacity(0.8),
  ];
  List<Color> darkBgColors = [
    Color(0xFF4075DA).withOpacity(0.8),
    Color(0xFF6E78B1).withOpacity(0.8),
    Color(0xFF947B8F).withOpacity(0.8),
  ];

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
    return Scaffold(
        body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness:
                    Theme.of(context).brightness == Brightness.dark
                        ? Brightness.light
                        : Brightness.dark),
            child: Column(children: [
              Expanded(child: topWelcome(lightBgColors, darkBgColors)),
              Expanded(child: bodyWelcome(lightBgColors, darkBgColors)),
            ])));
  }

  Widget topWelcome(List<Color> lightBgColors, List<Color> darkBgColors) {
    return Stack(
      children: [
        ClipPath(
          clipper: MyClipper(),
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDayMood ? lightBgColors : darkBgColors)),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 1.5,
                  alignment: Alignment.bottomCenter,
                  padding:
                      EdgeInsets.symmetric(horizontal: 5.0, vertical: 15.0),
                  child: Text(
                    "Bienvenue sur Gemu",
                    style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 36),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
                Expanded(
                    child: Container(
                        alignment: Alignment.bottomRight,
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        height: MediaQuery.of(context).size.height / 8,
                        child: IconButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => GetStartedScreen())),
                            icon: Icon(Icons.info_outline_rounded,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                                size: 30))))
              ],
            )),
            Expanded(
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Image.asset("assets/images/gameuse.png"),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 75),
                      child: Image.asset("assets/images/gamer.png"),
                    ),
                  ),
                ],
              ),
            )
          ],
        )
      ],
    );
  }

  Widget bodyWelcome(List<Color> lightBgColors, List<Color> darkBgColors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 25.0),
      child: Column(
        children: [
          Expanded(
              flex: 3,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                          "Commencer l'aventure",
                          style: mystyle(12),
                        ),
                        Container(
                          height: 2,
                          width: MediaQuery.of(context).size.width / 4,
                          color: Theme.of(context).canvasColor,
                        )
                      ],
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width - 70,
                      height: MediaQuery.of(context).size.height / 14,
                      child: ElevatedButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      RegisterScreen())),
                          style: ElevatedButton.styleFrom(
                              elevation: 6,
                              shadowColor: Theme.of(context).shadowColor,
                              primary: Theme.of(context).canvasColor,
                              onPrimary: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              )),
                          child: Text(
                            'Inscription',
                            style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          )),
                    ),
                  ],
                ),
              )),
          Expanded(
              flex: 3,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                          "Déjà un compte?",
                          style: mystyle(12),
                        ),
                        Container(
                          height: 2,
                          width: MediaQuery.of(context).size.width / 4,
                          color: Theme.of(context).canvasColor,
                        )
                      ],
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width - 70,
                      height: MediaQuery.of(context).size.height / 14,
                      child: ElevatedButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      LoginScreen())),
                          style: ElevatedButton.styleFrom(
                              elevation: 6,
                              shadowColor: Theme.of(context).shadowColor,
                              primary: Theme.of(context).canvasColor,
                              onPrimary: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              )),
                          child: Text(
                            'Connexion',
                            style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          )),
                    ),
                  ],
                ),
              )),
          Expanded(
              child: Column(
            children: [
              Container(
                height: 4,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: isDayMood ? lightBgColors : darkBgColors)),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    print("terms and conditions");
                  },
                  child: Text(
                    'Termes et conditions',
                    style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ))
        ],
      ),
    );
  }
}
