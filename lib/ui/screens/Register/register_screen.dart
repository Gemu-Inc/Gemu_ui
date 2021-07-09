import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gemu/services/auth_service.dart';

import 'package:gemu/ui/constants/size_config.dart';
import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/ui/screens/Welcome/welcome_screen.dart';
import 'package:gemu/ui/widgets/snack_bar_custom.dart';
import 'package:gemu/ui/widgets/text_field_custom.dart';

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

  Future<bool> _willPopCallback() async {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => WelcomeScreen()),
        (route) => false);
    return true;
  }

  _hideKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  _registerAccount(
      String email, String password, String username, List gamesFollow) async {
    if (gamesFollow.length == 0 || gamesFollow.length == 1) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBarCustom(error: 'Selects at least two games'));
    } else {
      AuthService.instance
          .registerUser(context, gamesFollow, username, email, password);
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

    return WillPopScope(
        child: Scaffold(
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
                        onTap: () => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    WelcomeScreen()),
                            (route) => false),
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_back_ios,
                              size: 25,
                            ),
                            Text(
                              'Back',
                              style: mystyle(16, Colors.white60),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                      child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      if (index == 0) {
                        setState(() {
                          currentPageIndex = 0;
                        });
                      } else {
                        _hideKeyboard();
                        setState(() {
                          currentPageIndex = 1;
                        });
                      }
                    },
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
        ),
        onWillPop: () => _willPopCallback());
  }

  Widget firstPage() {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: 100,
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
              VerticalSpacing(
                of: 20.0,
              )
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
                child: TextFieldCustom(
                    context: context,
                    controller: _emailController,
                    label: 'Email',
                    obscure: false,
                    icon: Icons.mail),
              ),
              VerticalSpacing(
                of: 20,
              ),
              Container(
                width: SizeConfig.screenWidth,
                margin: EdgeInsets.only(left: 20.0, right: 20.0),
                child: TextFieldCustom(
                    context: context,
                    controller: _usernameController,
                    label: 'Username',
                    obscure: false,
                    icon: Icons.person),
              ),
              VerticalSpacing(
                of: 20,
              ),
              Container(
                  width: SizeConfig.screenWidth,
                  margin: EdgeInsets.only(left: 20.0, right: 20.0),
                  child: TextFieldCustom(
                      context: context,
                      controller: _passwordController,
                      label: 'Password',
                      obscure: true,
                      icon: Icons.lock)),
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
                    height: 30,
                    width: 60,
                    child: Center(
                      child: Text('Prev', style: mystyle(16, Colors.black38)),
                    ),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).accentColor
                            ])),
                  ),
                )
              : SizedBox(
                  height: 30,
                  width: 60,
                ),
        ),
        Row(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.0),
              child: Container(
                height: currentPageIndex == 0 ? 20 : 15,
                width: currentPageIndex == 0 ? 20 : 15,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: currentPageIndex == 0
                            ? [
                                Theme.of(context).primaryColor,
                                Theme.of(context).accentColor
                              ]
                            : [Colors.white60, Colors.white60]),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black)),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.0),
              child: Container(
                height: currentPageIndex == 1 ? 20 : 15,
                width: currentPageIndex == 1 ? 20 : 15,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: currentPageIndex == 1
                            ? [
                                Theme.of(context).primaryColor,
                                Theme.of(context).accentColor
                              ]
                            : [Colors.white60, Colors.white60]),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black)),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(right: 10.0),
          child: currentPageIndex == 0
              ? GestureDetector(
                  onTap: () {
                    _hideKeyboard();
                    setState(() {
                      currentPageIndex = 1;
                    });
                    _pageController.nextPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.bounceIn);
                  },
                  child: Container(
                    height: 30,
                    width: 60,
                    child: Center(
                      child: Text('Next', style: mystyle(16, Colors.black38)),
                    ),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).accentColor
                            ])),
                  ),
                )
              : GestureDetector(
                  onTap: () => _registerAccount(
                      _emailController.text,
                      _passwordController.text,
                      _usernameController.text,
                      gamesFollow),
                  child: Container(
                    height: 30,
                    width: 60,
                    child: Center(
                        child: Icon(
                      Icons.check,
                      color: Colors.black38,
                    )),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).accentColor
                            ])),
                  ),
                ),
        ),
      ],
    );
  }
}
