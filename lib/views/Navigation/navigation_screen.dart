import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gemu/widgets/loader_data_custom.dart';
import 'package:loader/loader.dart';
import 'package:provider/provider.dart';

import 'package:gemu/models/user.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/services/database_service.dart';
import 'package:gemu/views/Autres/bottom_share.dart';
import 'package:gemu/constants/constants.dart';
import 'package:gemu/providers/index_tab_games_home.dart';
//import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Home/home_screen.dart';
import '../Games/games_screen.dart';
import '../Highlights/highlights_screen.dart';
import '../Profil/profil_screen.dart';

class NavigationScreen extends StatefulWidget {
  final String uid;

  NavigationScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  late StreamSubscription _userListener, _gamesListener, _followingsListener;

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

  Future<bool> loadingData() async {
    print('dans le loader de la nav');

    await DatabaseService.usersCollectionReference
        .doc(widget.uid)
        .get()
        .then((value) {
      me = UserModel.fromMap(value, value.data() as Map<String, dynamic>);
      print('current user: ${me!.uid}');
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('games')
        .get()
        .then((value) {
      print('charging games');
      for (var item in value.docs) {
        gamesList.add(Game.fromMap(item, item.data()));
        gamePageController.add(PageController());
      }
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('following')
        .get()
        .then((value) {
      print('listening followings');
      for (var item in value.docs) {
        followings.add(item.id);
      }
    });

    listeningData();
    return true;
  }

  Future<void> listeningData() async {
    _userListener = await DatabaseService.usersCollectionReference
        .doc(widget.uid)
        .snapshots()
        .listen((event) {
      print('listening current user');
      me = UserModel.fromMap(event, event.data() as Map<String, dynamic>);
    });

    _gamesListener = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('games')
        .snapshots()
        .listen((event) {
      print('listening games');
      if (gamesList.length != 0) {
        gamesList.clear();
        gamePageController.clear();
      }
      for (var item in event.docs) {
        gamesList.add(Game.fromMap(item, item.data()));
        gamePageController.add(PageController());
      }
    });

    _followingsListener = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('following')
        .snapshots()
        .listen((event) {
      print('listening followings');
      if (followings.length != 0) {
        followings.clear();
      }
      for (var item in event.docs) {
        followings.add(item.id);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _navPageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _navPageController.dispose();
    _userListener.cancel();
    _gamesListener.cancel();
    _followingsListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    indexGames = Provider.of<IndexGamesHome>(context);
    return Loader<void>(
      load: loadingData,
      loadingWidget: AnnotatedRegion<SystemUiOverlayStyle>(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
        ),
      ),
      builder: (_, value) {
        return Scaffold(
          body: Stack(
            children: [
              PageView(
                controller: _navPageController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  HomeScreen(
                      followings: followings,
                      games: gamesList,
                      gamePageController: gamePageController,
                      indexGamesHome: indexGames),
                  HighlightsScreen(
                    gamesUser: gamesList,
                  ),
                  GamesScreen(games: gamesList, indexGamesHome: indexGames),
                  MyProfilScreen()
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
                                  top: BorderSide(
                                      color: Colors.white60, width: 0.5)),
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
          ),
        );
      },
    );
  }
}
