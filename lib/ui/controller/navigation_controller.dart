import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:gemu/models/user.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/services/database_service.dart';
import 'package:gemu/ui/views/Autres/bottom_share.dart';
import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/ui/providers/index_tab_games_home.dart';

import '../views/Home/home_screen.dart';
import '../views/Games/games_screen.dart';
import '../views/Highlights/highlights_screen.dart';
import '../views/Profil/profil_screen.dart';

class NavController extends StatefulWidget {
  final String uid;

  NavController({Key? key, required this.uid}) : super(key: key);

  @override
  _NavControllerState createState() => _NavControllerState();
}

class _NavControllerState extends State<NavController> {
  bool dataIsThere = false;
  late StreamSubscription userListener, gamesListener, followingsListener;

  List<Game> gamesList = [];
  List<PageController> gamePageController = [];

  List followings = [];

  late IndexGamesHome indexGames;

  int selectedPage = 0;

  late PageController _navPageController;

  void onTap(int index) {
    setState(() {
      selectedPage = index;
    });
    print('selectedPage: $selectedPage');
    _navPageController.jumpToPage(selectedPage);
  }

  loadingData() async {
    userListener = await DatabaseService.usersCollectionReference
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

    gamesListener = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('games')
        .snapshots()
        .listen((data) {
      print('listen games');
      if (gamesList.length != 0) {
        gamesList.clear();
        gamePageController.clear();
      }
      for (var item in data.docs) {
        setState(() {
          gamesList.add(Game.fromMap(item, item.data()));
          gamePageController.add(PageController());
        });
      }
    });

    followingsListener = await FirebaseFirestore.instance
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

    await Future.delayed(Duration(seconds: 1));
    if (!dataIsThere && mounted) {
      setState(() {
        dataIsThere = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _navPageController = PageController(initialPage: 0);
    loadingData();
  }

  @override
  void dispose() {
    userListener.cancel();
    gamesListener.cancel();
    followingsListener.cancel();
    _navPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    indexGames = Provider.of<IndexGamesHome>(context);
    return Stack(
      children: [
        !dataIsThere
            ? AnnotatedRegion<SystemUiOverlayStyle>(
                child: Scaffold(
                  backgroundColor: Colors.black,
                  body: Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                      strokeWidth: 1.5,
                    ),
                  ),
                ),
                value: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: Colors.black,
                  statusBarIconBrightness:
                      Theme.of(context).brightness == Brightness.dark
                          ? Brightness.light
                          : Brightness.dark,
                ))
            : PageView(
                controller: _navPageController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  HomeScreen(
                      userActual: me!,
                      followings: followings,
                      games: gamesList,
                      gamePageController: gamePageController,
                      indexGamesHome: indexGames),
                  HighlightsScreen(
                    uid: me!.uid,
                    gamesUser: gamesList,
                  ),
                  GamesScreen(
                      uid: me!.uid,
                      games: gamesList,
                      indexGamesHome: indexGames),
                  MyProfilScreen(user: me!)
                ],
              ),
        Positioned(
            bottom: 0,
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 11,
                decoration: selectedPage != 0
                    ? BoxDecoration(boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor,
                          blurRadius: 1,
                          spreadRadius: 3,
                        )
                      ])
                    : BoxDecoration(
                        border: Border(
                            top: BorderSide(color: Colors.white60, width: 0.5)),
                      ),
                child: BottomNavigationBar(
                    backgroundColor: selectedPage != 0
                        ? Theme.of(context).scaffoldBackgroundColor
                        : Colors.black.withOpacity(0.2),
                    currentIndex: selectedPage,
                    onTap: (index) async {
                      onTap(index);
                    },
                    unselectedItemColor: selectedPage == 0
                        ? Colors.white60
                        : Theme.of(context).brightness == Brightness.dark
                            ? Colors.white60
                            : Colors.black45,
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
                          activeIcon: Icon(Icons.person),
                          icon: Icon(Icons.person_outline),
                          label: 'Profil')
                    ]))),
        BottomShare(),
      ],
    );
  }
}
