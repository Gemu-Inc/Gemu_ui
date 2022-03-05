import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/providers/dayMood_provider.dart';
import 'package:gemu/views/GetStarted/get_started_screen.dart';
import 'package:gemu/widgets/clip_shadow_path.dart';
import 'package:gemu/widgets/custom_clipper.dart';
import 'package:gemu/helpers/helpers.dart';

class WelcomeScreen extends StatefulWidget {
  final bool isFirstCo;

  const WelcomeScreen({Key? key, required this.isFirstCo}) : super(key: key);
  @override
  WelcomeviewState createState() => WelcomeviewState();
}

class WelcomeviewState extends State<WelcomeScreen> {
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
            child: Consumer(builder: (_, ref, child) {
              if (!widget.isFirstCo) {
                ref.read(dayMoodNotifierProvider.notifier).timeMood();
              }
              bool isDayMood = ref.watch(dayMoodNotifierProvider);
              return bodyWelcome(lightBgColors, darkBgColors, isDayMood);
            })));
  }

  Widget bodyWelcome(
      List<Color> lightBgColors, List<Color> darkBgColors, bool isDayMood) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Stack(
        children: [
          ClipShadowPath(
            shadow: BoxShadow(
                color: Theme.of(context).shadowColor,
                offset: Offset(4, 4),
                blurRadius: 4,
                spreadRadius: 1),
            clipper: BigClipper(),
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDayMood ? lightBgColors : darkBgColors)),
            ),
          ),
          ClipShadowPath(
            shadow: BoxShadow(
                color: Theme.of(context).shadowColor,
                offset: Offset(4, 4),
                blurRadius: 4,
                spreadRadius: 1),
            clipper: SmallClipper(),
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: IconButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => GetStartedBeforeScreen())),
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
            alignment: Alignment.topCenter,
            child: Padding(
                padding: const EdgeInsets.only(left: 50),
                child: Container(
                  height: 175,
                  width: 175,
                  child: Image.asset("assets/images/gameuse.png"),
                )),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 5, right: 50),
              child: Container(
                height: 175,
                width: 175,
                child: Image.asset("assets/images/gamer.png"),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                height: MediaQuery.of(context).size.height / 1.75,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 1.25,
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Bienvenue",
                            style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
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
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
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
                                onPressed: () => Helpers.inscriptionBottomSheet(
                                    context, isDayMood),
                                style: ElevatedButton.styleFrom(
                                    elevation: 6,
                                    shadowColor: Theme.of(context).shadowColor,
                                    primary: isDayMood ? cPinkBtn : cPurpleBtn,
                                    // cLightPurple,
                                    onPrimary: Theme.of(context).canvasColor,
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
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
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
                                onPressed: () => Helpers.connexionBottomSheet(
                                    context, isDayMood),
                                style: ElevatedButton.styleFrom(
                                    elevation: 6,
                                    shadowColor: Theme.of(context).shadowColor,
                                    primary: isDayMood ? cPurpleBtn : cPinkBtn,
                                    onPrimary: Theme.of(context).canvasColor,
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
                    ),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        child: RichText(
                            text: TextSpan(
                                text:
                                    "En te connectant ou en t'inscrivant, tu dois être en accord avec les ",
                                style: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 12),
                                children: [
                                  TextSpan(
                                      text: "Terms and Conditions",
                                      recognizer: TapGestureRecognizer()
                                        ..onTap =
                                            () => print("terms and conditions"),
                                      style: TextStyle(
                                          color:
                                              isDayMood ? cPinkBtn : cPurpleBtn,
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
                                          color:
                                              isDayMood ? cPinkBtn : cPurpleBtn,
                                          fontSize: 12))
                                ]),
                            textAlign: TextAlign.center)),
                  ],
                )),
          )
        ],
      ),
    );
  }
}
