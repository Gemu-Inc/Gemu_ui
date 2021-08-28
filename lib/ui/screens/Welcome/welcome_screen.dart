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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              icon: Icon(
                Icons.info_outline,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pushNamed(context, GetStartedRoute))
        ],
      ),
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
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
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
                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.1),
                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8)
              ]),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VerticalSpacing(
                of: 50.0,
              ),
              Container(
                alignment: Alignment.topLeft,
                height: MediaQuery.of(context).size.height / 6,
                width: 250,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(right: 45.0, bottom: 5.0),
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black),
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image:
                                      AssetImage("assets/icons/icon_round.png"),
                                  fit: BoxFit.cover)),
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
              VerticalSpacing(
                of: 10.0,
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
                    BouncingButton(
                      content: Center(
                        child: Text(
                          'Sign up',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                      height: MediaQuery.of(context).size.height / 14,
                      width: MediaQuery.of(context).size.width / 1.5,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    RegisterScreen()));
                      },
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
                    BouncingButton(
                      content: Center(
                        child: Text(
                          'Sign in',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                      height: MediaQuery.of(context).size.height / 14,
                      width: MediaQuery.of(context).size.width / 1.5,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    LoginScreen()));
                      },
                    )
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
