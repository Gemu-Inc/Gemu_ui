import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:Gemu/size_config.dart';
import 'package:Gemu/constants/variables.dart';
import 'package:Gemu/constants/route_names.dart';

class RegisterScreen extends StatefulWidget {
  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  Duration _duration = Duration(seconds: 1);
  bool isDayMood = false;
  bool dataIsThere = false;

  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _usernameController;

  late PageController _pageController;
  int currentPageIndex = 0;

  List allGames = [];
  List gamesFollow = [];

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

  getGames() async {
    var doc = await FirebaseFirestore.instance
        .collection('games')
        .orderBy('name')
        .get();
    for (var item in doc.docs) {
      allGames.add(item);
    }

    setState(() {
      dataIsThere = true;
    });
  }

  registerUser() async {
    if (gamesFollow.length == 0 || gamesFollow.length == 1) {
      SnackBar snackBar = SnackBar(
          backgroundColor: Theme.of(context).canvasColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.black)),
          content: Container(
            height: 30,
            width: SizeConfig.screenWidth,
            alignment: Alignment.center,
            child: Text(
              'Selects at least two games',
              style: mystyle(12),
            ),
          ));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      try {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text)
            .then((userCredential) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'id': userCredential.user!.uid,
            'email': _emailController.text,
            'pseudo': _usernameController.text,
            'photoURL': null,
          });
          for (var i = 0; i < gamesFollow.length; i++) {
            FirebaseFirestore.instance
                .collection('users')
                .doc(userCredential.user!.uid)
                .collection('games')
                .doc(gamesFollow[i].data()['name'])
                .set({});
          }
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
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    timeMood();
    getGames();
    _pageController = PageController(initialPage: currentPageIndex);
    _emailController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _pageController.dispose();
    super.dispose();
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
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                Theme.of(context).scaffoldBackgroundColor
              ])),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 75,
                child: Padding(
                  padding: EdgeInsets.only(top: 25.0, left: 15.0),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          size: 25,
                        ),
                        Text(
                          'Back',
                          style: mystyle(16, Colors.black38),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: PageView(
                physics: NeverScrollableScrollPhysics(),
                controller: _pageController,
                children: [firstPage(), secondPage()],
              )),
              Container(
                height: 50,
                alignment: Alignment.center,
                child: bottomBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget firstPage() {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: 80,
          child: Column(
            children: [
              Text(
                'User information',
                style: mystyle(30),
              ),
              VerticalSpacing(
                of: 20,
              ),
              Text('Enter your personnal information'),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: [
              Container(
                width: SizeConfig.screenWidth,
                margin: EdgeInsets.only(left: 20.0, right: 20.0),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                      fillColor: Theme.of(context).canvasColor,
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
                      fillColor: Theme.of(context).canvasColor,
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
                      fillColor: Theme.of(context).canvasColor,
                      filled: true,
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      labelStyle: mystyle(15),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget secondPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          child: gamesFollow.length != 0
              ? Column(
                  children: [
                    Text(
                      'Selected games',
                      style: mystyle(30),
                    ),
                    VerticalSpacing(
                      of: 10,
                    ),
                    Text('Selects at least two games'),
                    VerticalSpacing(
                      of: 20,
                    ),
                    Container(
                        height: MediaQuery.of(context).size.height / 8,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: gamesFollow.map((game) {
                            return Stack(
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        gamesFollow.remove(game);
                                        allGames.add(game);
                                      });
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: Container(
                                        height: 60,
                                        width: 60,
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Theme.of(context)
                                                      .primaryColor,
                                                  Theme.of(context).accentColor
                                                ]),
                                            border:
                                                Border.all(color: Colors.black),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            image: DecorationImage(
                                                image:
                                                    CachedNetworkImageProvider(
                                                        game.data()![
                                                            'imageUrl']),
                                                fit: BoxFit.cover)),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                    bottom: 10,
                                    right: 5,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          gamesFollow.remove(game);
                                          allGames.add(game);
                                        });
                                      },
                                      child: Container(
                                          height: 25,
                                          width: 25,
                                          decoration: BoxDecoration(
                                              color: Colors.red[400],
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.black)),
                                          child: Icon(
                                            Icons.remove,
                                            size: 20,
                                          )),
                                    )),
                              ],
                            );
                          }).toList(),
                        )),
                    Text(
                      'Selection games',
                      style: mystyle(30),
                    ),
                    VerticalSpacing(
                      of: 10,
                    ),
                    Text('Choose the games you want to follow'),
                  ],
                )
              : Column(
                  children: [
                    Text(
                      'Selection games',
                      style: mystyle(30),
                    ),
                    VerticalSpacing(
                      of: 10,
                    ),
                    Text('Choose the games you want to follow'),
                  ],
                ),
        ),
        Expanded(
          child: dataIsThere
              ? GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6),
                  itemCount: allGames.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot<Map<String, dynamic>> game =
                        allGames[index];
                    return Column(
                      children: [
                        Container(
                          height: 70,
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.topCenter,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      allGames.remove(game);
                                      gamesFollow.add(game);
                                    });
                                  },
                                  child: Container(
                                    height: 60,
                                    width: 60,
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Theme.of(context).primaryColor,
                                              Theme.of(context).accentColor
                                            ]),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.black),
                                        image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: CachedNetworkImageProvider(
                                                game.data()!['imageUrl']))),
                                  ),
                                ),
                              ),
                              Positioned(
                                  top: 38,
                                  right: 25,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        allGames.remove(game);
                                        gamesFollow.add(game);
                                      });
                                    },
                                    child: Container(
                                        height: 25,
                                        width: 25,
                                        decoration: BoxDecoration(
                                            color: Colors.green[400],
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.black)),
                                        child: Icon(
                                          Icons.add,
                                          size: 20,
                                        )),
                                  )),
                            ],
                          ),
                        ),
                        Text(
                          game.data()!['name'],
                          softWrap: true,
                        )
                      ],
                    );
                  })
              : Center(
                  child: CircularProgressIndicator(),
                ),
        )
      ],
    );
  }

  Widget bottomBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: currentPageIndex == 1
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      currentPageIndex = 0;
                    });
                    _pageController.previousPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.bounceIn);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 30,
                    width: 60,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(15.0),
                        color: Theme.of(context).accentColor.withOpacity(0.5)),
                    child: Text(
                      'Prev',
                      style: mystyle(16, Colors.black38),
                    ),
                  ),
                )
              : SizedBox(),
        ),
        Padding(
          padding: EdgeInsets.only(right: 10.0),
          child: currentPageIndex == 0
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      currentPageIndex = 1;
                    });
                    _pageController.nextPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.bounceIn);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 30,
                    width: 60,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(15.0),
                        color: Theme.of(context).accentColor.withOpacity(0.5)),
                    child: Text(
                      'Next',
                      style: mystyle(16, Colors.black38),
                    ),
                  ),
                )
              : GestureDetector(
                  onTap: () => registerUser(),
                  child: Container(
                    alignment: Alignment.center,
                    height: 30,
                    width: 60,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(15.0),
                        color: Theme.of(context).accentColor.withOpacity(0.5)),
                    child: Icon(Icons.check),
                  ),
                ),
        ),
      ],
    );
  }
}
