import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:gemu/constants/constants.dart';

import 'package:gemu/views/Login/login_screen.dart';
import 'package:gemu/views/Register/register_screen.dart';
import 'package:gemu/widgets/custom_clipper.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  WelcomeviewState createState() => WelcomeviewState();
}

class WelcomeviewState extends State<WelcomeScreen> {
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
    return Scaffold(
        body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness:
                    Theme.of(context).brightness == Brightness.dark
                        ? Brightness.light
                        : Brightness.dark),
            child: Column(children: [
              Expanded(
                  child: topWelcome()),
              Expanded(
                  child: bodyWelcome()),
            ])));
  }

  Widget topWelcome() {
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

    return Stack(
      children: [
        ClipPath(
          clipper: MyClipper(),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDayMood ? lightBgColors : darkBgColors)
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 1.5,
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                  child: Text("Bienvenue sur Gemu", style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 36), textAlign: TextAlign.center, maxLines: 2,),
                ),
              ],
            )),
            Container(
              height: MediaQuery.of(context).size.height / 3.5,
              child: Stack(
              children: [
                Align(alignment: Alignment.centerRight, child: Padding(
                  padding: const EdgeInsets.only(bottom: 5, right: 20),
                  child: Image.asset("assets/images/gameuse.png"),
                ),),
                Align(alignment: Alignment.centerRight, child: Padding(
                  padding: const EdgeInsets.only(right: 75),
                  child: Image.asset("assets/images/gamer.png"),
                ),),
              ],
            )
            )
            
          ],
        )
      ],
    );
  }

  Widget bodyWelcome() {
    return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 25.0),
                        child: Row(
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
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width - 50,
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
                              'Inscription',
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
                        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 25.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 2,
                              width: MediaQuery.of(context).size.width / 4,
                              color: Theme.of(context).canvasColor,
                            ),
                            Text(
                              'Déjà un compte?',
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
                        width: MediaQuery.of(context).size.width - 50,
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
                              'Connexion',
                              style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700),
                            )),
                      ),
                      Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 4,
                            width: MediaQuery.of(context).size.width - 25,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary
                            ])),
                          ),
                          TextButton(onPressed: () {
                            print("terms and conditions");
                          }, child: Text(
                        'Termes et conditions',
                        style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
                      ),)
                        ],
                      ),
                    )),
                    ],
                  );
  }
}
