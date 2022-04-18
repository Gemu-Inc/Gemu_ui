import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gemu/riverpod/Connectivity/auth_provider.dart';
import 'package:gemu/services/auth_service.dart';
import 'package:gemu/widgets/snack_bar_custom.dart';
import 'package:loader/loader.dart';

import 'package:gemu/models/user.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/services/database_service.dart';
import 'package:gemu/widgets/bottom_share.dart';
import 'package:gemu/constants/constants.dart';
import 'package:gemu/riverpod/Navigation/index_games_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Home/home_screen.dart';
import '../Games/games_screen.dart';
import '../Highlights/highlights_screen.dart';
import '../Profil/profil_screen.dart';

class BottomNavigationScreen extends ConsumerStatefulWidget {
  BottomNavigationScreen({Key? key}) : super(key: key);

  @override
  _BottomNavigationScreenState createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState
    extends ConsumerState<BottomNavigationScreen> {
  //late StreamSubscription _userListener, _gamesListener, _followingsListener;

  List<Game> gamesList = [];
  List<PageController> gamePageController = [];

  List followings = [];

  int selectedPage = 0;

  late PageController _navPageController;

  bool isLoading = false;

  void onTap(int index) {
    setState(() {
      selectedPage = index;
    });
    print('selectedPage: $selectedPage');
    _navPageController.jumpToPage(selectedPage);
  }

  Future<bool> loadingData(String uid) async {
    print('dans le loader de la nav');
    User? user;

    await DatabaseService.usersCollectionReference
        .doc(uid)
        .get()
        .then((value) async {
      me = UserModel.fromMap(value, value.data() as Map<String, dynamic>);
      user = await AuthService.getUser();
      print('current user: ${me!.uid}');
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
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
        .doc(uid)
        .collection('following')
        .get()
        .then((value) {
      print('charging followings');
      for (var item in value.docs) {
        followings.add(item.id);
      }
    });

    if (!user!.emailVerified) {
      verifyAccount(context);
    } else {
      if (!me!.verifiedAccount!) {
        DatabaseService.updateVerifyAccount(me!.uid);
      }
    }

    //listeningData();
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    return true;
  }

  // Future<void> listeningData() async {
  //   _userListener = await DatabaseService.usersCollectionReference
  //       .doc(widget.uid)
  //       .snapshots()
  //       .listen((event) {
  //     print('listening current user');
  //     me = UserModel.fromMap(event, event.data() as Map<String, dynamic>);
  //   });

  //   _gamesListener = await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(widget.uid)
  //       .collection('games')
  //       .snapshots()
  //       .listen((event) {
  //     print('listening games');
  //     if (gamesList.length != 0) {
  //       gamesList.clear();
  //       gamePageController.clear();
  //     }
  //     for (var item in event.docs) {
  //       gamesList.add(Game.fromMap(item, item.data()));
  //       gamePageController.add(PageController());
  //     }
  //   });

  //   _followingsListener = await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(widget.uid)
  //       .collection('following')
  //       .snapshots()
  //       .listen((event) {
  //     print('listening followings');
  //     if (followings.length != 0) {
  //       followings.clear();
  //     }
  //     for (var item in event.docs) {
  //       followings.add(item.id);
  //     }
  //   });
  // }

  @override
  void initState() {
    super.initState();
    _navPageController = PageController(initialPage: 0);
    //listeningData();
  }

  @override
  void dispose() {
    _navPageController.dispose();
    // _userListener.cancel();
    // _gamesListener.cancel();
    // _followingsListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeUser = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
            statusBarColor: (selectedPage == 0 && isLoading)
                ? Colors.black.withOpacity(0.5)
                : Colors.transparent,
            statusBarIconBrightness: (selectedPage == 0 && isLoading)
                ? Brightness.light
                : Theme.of(context).brightness == Brightness.dark
                    ? Brightness.light
                    : Brightness.dark,
            systemNavigationBarColor: (selectedPage == 0 && isLoading)
                ? Colors.black
                : Theme.of(context).scaffoldBackgroundColor,
            systemNavigationBarIconBrightness: (selectedPage == 0 && isLoading)
                ? Brightness.light
                : Theme.of(context).brightness == Brightness.dark
                    ? Brightness.light
                    : Brightness.dark),
        child: Stack(
          children: [
            Loader<void>(
              load: () => loadingData(activeUser!.uid),
              loadingWidget: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  strokeWidth: 1.5,
                ),
              ),
              builder: (_, value) {
                return Consumer(builder: (_, ref, child) {
                  final indexGames = ref.watch(indexGamesNotifierProvider);
                  return PageView(
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
                  );
                });
              },
            ),
            Positioned(
                bottom: 0,
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 11,
                    decoration: (selectedPage != 0 || !isLoading)
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
                        backgroundColor: (selectedPage != 0 || !isLoading)
                            ? Theme.of(context).scaffoldBackgroundColor
                            : Colors.black.withOpacity(0.2),
                        currentIndex: selectedPage,
                        onTap: (index) async {
                          onTap(index);
                        },
                        unselectedItemColor: (selectedPage == 0 && isLoading)
                            ? Colors.white60
                            : Theme.of(context).brightness == Brightness.dark
                                ? Colors.white60
                                : Colors.black45,
                        selectedItemColor:
                            Theme.of(context).colorScheme.primary,
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
      ),
    );
  }
}
