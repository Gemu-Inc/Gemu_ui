import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/widgets/custom_clipper.dart';
import 'package:gemu/helpers/helpers.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  WelcomeviewState createState() => WelcomeviewState();
}

class WelcomeviewState extends State<WelcomeScreen> {
  bool isDayMood = false;

  List<Color> lightBgColors = [
    Color(0xFF947B8F),
    Color(0xFFB27D75),
    Color(0xFFE38048),
  ];
  List<Color> darkBgColors = [
    Color(0xFF4075DA),
    Color(0xFF6E78B1),
    Color(0xFF947B8F)
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
              Container(
                height: MediaQuery.of(context).size.height / 1.75,
                child: topWelcome(lightBgColors, darkBgColors),
              ),
              Expanded(child: bodyWelcome(lightBgColors, darkBgColors))
            ])));
  }

  Widget topWelcome(List<Color> lightBgColors, List<Color> darkBgColors) {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height / 3,
          child: Stack(
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
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 25.0, right: 15.0),
                  child: IconButton(
                      onPressed: () => Navigator.pushNamed(context, GetStarted),
                      icon: Icon(
                        Icons.info_outline,
                        size: 28,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      )),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 25, left: 70),
                  child: Image.asset("assets/images/gameuse.png"),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 25, right: 70),
                  child: Image.asset("assets/images/gamer.png"),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 35.0,
        ),
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width / 1.25,
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Bienvenue",
                  style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 36),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Text(
                  "Rejoins-nous et vient découvrir l'univers de Gemu et de ses joueurs",
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget bodyWelcome(List<Color> lightBgColors, List<Color> darkBgColors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
          child: Column(
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
              const SizedBox(
                height: 10.0,
              ),
              Container(
                width: MediaQuery.of(context).size.width - 70,
                height: MediaQuery.of(context).size.height / 14,
                child: ElevatedButton(
                    onPressed: () => Helpers.inscriptionBottomSheet(context),
                    style: ElevatedButton.styleFrom(
                        elevation: 6,
                        shadowColor: Theme.of(context).shadowColor,
                        primary:
                            isDayMood ? Color(0xFF947B8F) : Color(0xFF4075DA),
                        onPrimary: Theme.of(context).canvasColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        )),
                    child: Text(
                      'Inscription',
                      style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    )),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
          child: Column(
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
              const SizedBox(
                height: 10.0,
              ),
              Container(
                width: MediaQuery.of(context).size.width - 70,
                height: MediaQuery.of(context).size.height / 14,
                child: ElevatedButton(
                    onPressed: () => Helpers.connexionBottomSheet(context),
                    style: ElevatedButton.styleFrom(
                        elevation: 6,
                        shadowColor: Theme.of(context).shadowColor,
                        primary:
                            isDayMood ? Color(0xFFE38048) : Color(0xFF947B8F),
                        onPrimary: Theme.of(context).canvasColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        )),
                    child: Text(
                      'Connexion',
                      style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    )),
              ),
            ],
          ),
        ),
        Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: RichText(
                text: TextSpan(
                    text:
                        "En te connectant ou en t'inscrivant, tu dois être en accord avec les ",
                    style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        fontSize: 12),
                    children: [
                      TextSpan(
                          text: "Terms and Conditions",
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => print("terms and conditions"),
                          style: TextStyle(
                              color: !isDayMood
                                  ? Color(0xFF947B8F)
                                  : Color(0xFF4075DA),
                              fontSize: 12)),
                      TextSpan(
                          text: " et les ",
                          style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 12)),
                      TextSpan(
                          text: "Privacy Policy",
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => print("privacy policy"),
                          style: TextStyle(
                              color: !isDayMood
                                  ? Color(0xFF947B8F)
                                  : Color(0xFF4075DA),
                              fontSize: 12))
                    ]),
                textAlign: TextAlign.center)),
      ],
    );
  }
}
