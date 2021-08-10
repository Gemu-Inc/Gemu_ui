import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:gemu/models/user.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/services/database_service.dart';
import 'package:gemu/ui/screens/Reglages/Design/theme_values.dart';
import 'package:gemu/ui/widgets/bottom_share.dart';
import 'package:gemu/ui/constants/constants.dart';

import '../screens/Home/home_screen.dart';
import '../screens/Games/games_screen.dart';
import '../screens/Highlights/highlights_screen.dart';
import '../screens/Profil/profil_screen.dart';

class NavController extends StatefulWidget {
  final String uid;

  NavController({Key? key, required this.uid}) : super(key: key);

  @override
  _NavControllerState createState() => _NavControllerState();
}

class _NavControllerState extends State<NavController> {
  bool dataIsHere = false;

  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  late StreamSubscription userListener, gamesListener, followingsListener;

  int selectedPage = 0;
  late final PageController navController;

  List<Game> gamesList = [];

  List followings = [];

  void onTap(int index) {
    navController.jumpToPage(index);
  }

  void onPageChanged(int index) {
    setState(() {
      selectedPage = index;
    });
  }

  @override
  void initState() {
    super.initState();
    navController = PageController(initialPage: selectedPage);

    userListener = DatabaseService.usersCollectionReference
        .doc(widget.uid)
        .snapshots()
        .listen((document) {
      print('user changes au niv du nav');
      setState(() {
        me = UserModel.fromMap(
            document, document.data() as Map<String, dynamic>);
      });
      print('me: ${me!.uid}');
    });

    gamesListener = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('games')
        .snapshots()
        .listen((data) {
      print('listen games');
      if (gamesList.length != 0) {
        gamesList.clear();
      }
      for (var item in data.docs) {
        setState(() {
          gamesList.add(Game.fromMap(item, item.data()));
        });
      }
      if (!dataIsHere) {
        setState(() {
          print('data here');
          dataIsHere = true;
        });
      }
    });

    followingsListener = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('following')
        .snapshots()
        .listen((data) {
      if (followings.length != 0) {
        followings.clear();
      }
      for (var item in data.docs) {
        setState(() {
          followings.add(item.id);
        });
      }
    });
  }

  @override
  void dispose() {
    userListener.cancel();
    gamesListener.cancel();
    followingsListener.cancel();
    navController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (me == null || me!.uid != widget.uid || !dataIsHere)
        ? Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
          )
        : Scaffold(
            key: _globalKey,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            resizeToAvoidBottomInset: false,
            body: PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: navController,
              onPageChanged: onPageChanged,
              children: [
                HomeScreen(
                  userActual: me!,
                  followings: followings,
                  games: gamesList,
                ),
                HighlightsScreen(
                  uid: me!.uid,
                ),
                GamesScreen(
                  uid: me!.uid,
                  games: gamesList,
                ),
                MyProfilScreen(user: me!)
              ],
            ),
            bottomNavigationBar: Container(
                width: MediaQuery.of(context).size.width,
                height: 60,
                decoration: selectedPage != 0
                    ? BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).shadowColor,
                              blurRadius: 1,
                              spreadRadius: 3,
                            )
                          ])
                    : BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        border: Border(
                            top: BorderSide(
                                color: (themeApp(context) == darkThemeOrange ||
                                        themeApp(context) == darkThemePurple)
                                    ? Colors.white60
                                    : Colors.black45,
                                width: 0.1)),
                      ),
                child: BottomNavigationBar(
                    currentIndex: selectedPage,
                    onTap: onTap,
                    items: [
                      BottomNavigationBarItem(
                          activeIcon: Icon(Icons.home),
                          icon: Icon(Icons.home_outlined),
                          label: 'Home'),
                      BottomNavigationBarItem(
                          activeIcon: Icon(Icons.highlight),
                          icon: Icon(Icons.highlight_outlined),
                          label: 'Highlights'),
                      BottomNavigationBarItem(
                          activeIcon: Icon(Icons.videogame_asset),
                          icon: Icon(Icons.videogame_asset_outlined),
                          label: 'Games'),
                      BottomNavigationBarItem(
                          activeIcon: me!.imageUrl == null
                              ? Icon(Icons.person)
                              : Padding(
                                  padding:
                                      EdgeInsets.only(top: 0.5, bottom: 0.5),
                                  child: Container(
                                    height: 26,
                                    width: 26,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: 1.0),
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: CachedNetworkImageProvider(
                                                me!.imageUrl!))),
                                  ),
                                ),
                          icon: me!.imageUrl == null
                              ? Icon(Icons.person_outline)
                              : Padding(
                                  padding:
                                      EdgeInsets.only(top: 0.5, bottom: 0.5),
                                  child: Container(
                                    height: 23,
                                    width: 23,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: (themeApp(context) ==
                                                        darkThemeOrange ||
                                                    themeApp(context) ==
                                                        darkThemePurple)
                                                ? Colors.white60
                                                : Colors.black45),
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: CachedNetworkImageProvider(
                                                me!.imageUrl!))),
                                  ),
                                ),
                          label: 'Profil')
                    ])),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: BottomShare(),
          );
  }
}
