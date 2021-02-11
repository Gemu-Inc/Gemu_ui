import 'dart:async';
import 'package:Gemu/screensmodels/Register/register_screen_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:Gemu/size_config.dart';
import 'package:Gemu/constants/variables.dart';
import 'package:Gemu/constants/route_names.dart';
import 'package:Gemu/models/game.dart';
import 'package:stacked/stacked.dart';
import 'components/body.dart';

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Color(0xFF1A1C25),
      body: Body(),
    );
  }
}

class RegisterFirstScreen extends StatefulWidget {
  @override
  RegisterFirstScreenState createState() => RegisterFirstScreenState();
}

class RegisterFirstScreenState extends State<RegisterFirstScreen> {
  Duration _duration = Duration(seconds: 1);
  bool isDayMood = false;
  TextEditingController _emailController;
  TextEditingController _passwordController;
  TextEditingController _usernameController;

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
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _usernameController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
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
        backgroundColor: Color(0xFF1A1C25),
        body: AnimatedContainer(
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
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'User information',
                      style: mystyle(30),
                    ),
                    VerticalSpacing(
                      of: 10,
                    ),
                    Text('Enter your personnal information'),
                    VerticalSpacing(
                      of: 40,
                    ),
                    Container(
                      width: SizeConfig.screenWidth,
                      margin: EdgeInsets.only(left: 20.0, right: 20.0),
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                            fillColor: Color(0xFF222831),
                            filled: true,
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            labelStyle: mystyle(15),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10))),
                      ),
                    ),
                    VerticalSpacing(
                      of: 20,
                    ),
                    Container(
                      width: SizeConfig.screenWidth,
                      margin: EdgeInsets.only(left: 20.0, right: 20.0),
                      child: TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                            fillColor: Color(0xFF222831),
                            filled: true,
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person),
                            labelStyle: mystyle(15),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10))),
                      ),
                    ),
                    VerticalSpacing(
                      of: 20,
                    ),
                    Container(
                      width: SizeConfig.screenWidth,
                      margin: EdgeInsets.only(left: 20.0, right: 20.0),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                            fillColor: Color(0xFF222831),
                            filled: true,
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                            labelStyle: mystyle(15),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10))),
                      ),
                    ),
                    VerticalSpacing(
                      of: 20.0,
                    ),
                    InkWell(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return RegisterSecondScreen(
                          previousFields: [
                            _emailController.text,
                            _passwordController.text,
                            _usernameController.text
                          ],
                        );
                      })),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Text(
                            "Next",
                            style: mystyle(15, Colors.white, FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}

class RegisterSecondScreen extends StatefulWidget {
  const RegisterSecondScreen({Key key, this.previousFields}) : super(key: key);

  final List<String> previousFields;

  @override
  RegisterSecondScreenState createState() => RegisterSecondScreenState();
}

class RegisterSecondScreenState extends State<RegisterSecondScreen> {
  Duration _duration = Duration(seconds: 1);
  bool isDayMood = false;
  Future games;

  List<String> test = List<String>();
  List<Game> testGame = List<Game>();

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

  registerUser() async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: widget.previousFields[0],
              password: widget.previousFields[1])
          .then((userCredential) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user.uid)
            .set({
          'id': userCredential.user.uid,
          'email': widget.previousFields[0],
          'pseudo': widget.previousFields[2],
          'photoURL': null,
          'idGames': test
        });
      });
      Navigator.pushNamedAndRemoveUntil(
          context, NavScreenRoute, (route) => false);
    } catch (e) {
      SnackBar snackBar = SnackBar(
          backgroundColor: Color(0xFF222831),
          content: Container(
            height: 30,
            width: SizeConfig.screenWidth,
            alignment: Alignment.center,
            child: Text(
              'Try again',
              style: mystyle(12, Colors.white),
            ),
          ));
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  @override
  void initState() {
    super.initState();
    timeMood();

    print(widget.previousFields);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
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
    return ViewModelBuilder<RegisterScreenModel>.reactive(
        viewModelBuilder: () => RegisterScreenModel(),
        onModelReady: (model) => model.listenToGames(),
        builder: (context, model, child) => Scaffold(
              backgroundColor: Color(0xFF1A1C25),
              body: AnimatedContainer(
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
                  child: Stack(
                    children: [
                      Container(
                          alignment: Alignment.center,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                VerticalSpacing(
                                  of: 40,
                                ),
                                testGame.length == 0
                                    ? SizedBox()
                                    : Column(
                                        children: [
                                          Text(
                                            'Selected games',
                                            style: mystyle(30),
                                          ),
                                          VerticalSpacing(
                                            of: 10,
                                          ),
                                          Text(
                                              'Selects at least two games to continue'),
                                          VerticalSpacing(
                                            of: 20,
                                          ),
                                          Container(
                                              height:
                                                  SizeConfig.screenHeight / 8,
                                              width: SizeConfig.screenWidth,
                                              child: ListView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                children: testGame.map((game) {
                                                  return Stack(
                                                    children: [
                                                      Align(
                                                          alignment: Alignment
                                                              .topCenter,
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              game.selected =
                                                                  false;
                                                              setState(() {
                                                                model.gameList
                                                                    .add(game);
                                                                test.remove(game
                                                                    .documentId);
                                                                testGame.remove(
                                                                    game);
                                                              });
                                                            },
                                                            child: Container(
                                                              margin: EdgeInsets
                                                                  .all(6.0),
                                                              height: 60,
                                                              width: 60,
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  image: DecorationImage(
                                                                      image: CachedNetworkImageProvider(game
                                                                          .imageUrl),
                                                                      fit: BoxFit
                                                                          .cover)),
                                                            ),
                                                          )),
                                                      Positioned(
                                                          bottom: 15,
                                                          right: 1,
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              game.selected =
                                                                  false;
                                                              setState(() {
                                                                model.gameList
                                                                    .add(game);
                                                                test.remove(game
                                                                    .documentId);
                                                                testGame.remove(
                                                                    game);
                                                              });
                                                            },
                                                            child: Container(
                                                                height: 25,
                                                                width: 25,
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                            .red[
                                                                        400],
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    border: Border.all(
                                                                        color: Color(
                                                                            0xFF222831))),
                                                                child: Icon(
                                                                  Icons.remove,
                                                                  size: 20,
                                                                )),
                                                          )),
                                                    ],
                                                  );
                                                }).toList(),
                                              )),
                                          testGame.length < 2
                                              ? SizedBox()
                                              : InkWell(
                                                  onTap: () => registerUser(),
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            2,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                        color: Colors.red,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Center(
                                                      child: Text(
                                                        "Sign up",
                                                        style: mystyle(
                                                            15,
                                                            Colors.white,
                                                            FontWeight.w700),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                        ],
                                      ),
                                VerticalSpacing(
                                  of: 20,
                                ),
                                Text(
                                  'Selection games',
                                  style: mystyle(30),
                                ),
                                VerticalSpacing(
                                  of: 10,
                                ),
                                Text('Choose the games you want to follow'),
                                VerticalSpacing(
                                  of: 10,
                                ),
                                model.gameList == null
                                    ? CircularProgressIndicator()
                                    : Wrap(
                                        direction: Axis.horizontal,
                                        spacing: 5.0,
                                        children: model.gameList.map((game) {
                                          print(model.gameList.length);
                                          return Container(
                                              margin: EdgeInsets.only(
                                                  bottom: 10.0, top: 10.0),
                                              width: 90,
                                              height: 90,
                                              child: Stack(
                                                children: [
                                                  Align(
                                                    alignment:
                                                        Alignment.topCenter,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        game.selected = true;
                                                        setState(() {
                                                          model.gameList
                                                              .remove(game);
                                                          test.add(
                                                              game.documentId);
                                                          testGame.add(game);
                                                        });
                                                      },
                                                      child: Container(
                                                        height: 60,
                                                        width: 60,
                                                        decoration: BoxDecoration(
                                                            gradient: LinearGradient(
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight,
                                                                colors: [
                                                                  Theme.of(
                                                                          context)
                                                                      .primaryColor,
                                                                  Theme.of(
                                                                          context)
                                                                      .accentColor
                                                                ]),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            image: DecorationImage(
                                                                fit: BoxFit
                                                                    .cover,
                                                                image: CachedNetworkImageProvider(
                                                                    game.imageUrl))),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                      bottom: 25,
                                                      right: 10,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          game.selected = true;
                                                          setState(() {
                                                            model.gameList
                                                                .remove(game);
                                                            test.add(game
                                                                .documentId);
                                                            testGame.add(game);
                                                          });
                                                        },
                                                        child: Container(
                                                            height: 25,
                                                            width: 25,
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .green[400],
                                                                shape: BoxShape
                                                                    .circle,
                                                                border: Border.all(
                                                                    color: Color(
                                                                        0xFF222831))),
                                                            child: Icon(
                                                              Icons.add,
                                                              size: 20,
                                                            )),
                                                      )),
                                                  Align(
                                                    alignment:
                                                        Alignment.bottomCenter,
                                                    child: Text(
                                                      '${game.name}',
                                                      softWrap: true,
                                                    ),
                                                  )
                                                ],
                                              ));
                                        }).toList(),
                                      ),
                                VerticalSpacing(
                                  of: 20,
                                ),
                              ],
                            ),
                          )),
                    ],
                  )),
            ));
  }

  @override
  void dispose() {
    test.clear();
    testGame.clear();
    super.dispose();
  }
}
