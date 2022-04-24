import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gemu/riverpod/Connectivity/auth_provider.dart';
import 'package:gemu/services/auth_service.dart';
import 'package:gemu/views/Activities/activities_screen.dart';
import 'package:gemu/views/Home/home_screen.dart';
import 'package:gemu/widgets/alert_dialog_custom.dart';
import 'package:loader/loader.dart';

import 'package:gemu/models/user.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/services/database_service.dart';
import 'package:gemu/widgets/bottom_share.dart';
import 'package:gemu/constants/constants.dart';
import 'package:gemu/riverpod/Home/index_games_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../views/Home/home_screen.dart';
import '../views/Games/games_screen.dart';
import '../views/Highlights/highlights_screen.dart';
import '../views/Profil/profil_screen.dart';

class BottomNavigationController extends ConsumerStatefulWidget {
  BottomNavigationController({Key? key}) : super(key: key);

  @override
  _BottomNavigationControllerState createState() =>
      _BottomNavigationControllerState();
}

class _BottomNavigationControllerState
    extends ConsumerState<BottomNavigationController> {
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

    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _navPageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _navPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeUser = ref.watch(authNotifierProvider);
    final indexGames = ref.watch(indexGamesNotifierProvider);

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
                    ActivitiesMenuDrawer(uid: me!.uid),
                    // GamesScreen(games: gamesList, indexGamesHome: indexGames),
                    MyProfilScreen()
                  ],
                );
              },
            ),
            Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  decoration: (selectedPage != 0 || !isLoading)
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
                          color: Colors.black.withOpacity(0.2),
                          border: Border(
                              top: BorderSide(
                                  color: Colors.white60, width: 0.5)),
                        ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        alignment: Alignment.center,
                        child: InkWell(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  selectedPage == 0
                                      ? Icons.home
                                      : Icons.home_outlined,
                                  color: selectedPage == 0
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey.shade400,
                                ),
                                Text(
                                  "Accueil",
                                  style: textStyleCustomBold(
                                      selectedPage == 0
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Colors.grey.shade400,
                                      12),
                                )
                              ],
                            ),
                            onTap: () {
                              onTap(0);
                            }),
                      ),
                      Container(
                        height: 60,
                        width: 60,
                        child: InkWell(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  selectedPage == 1
                                      ? Icons.highlight
                                      : Icons.highlight_outlined,
                                  color: selectedPage == 1
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey.shade400,
                                ),
                                Text(
                                  "Sélection",
                                  style: textStyleCustomBold(
                                      selectedPage == 1
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Colors.grey.shade400,
                                      12),
                                )
                              ],
                            ),
                            onTap: () {
                              onTap(1);
                            }),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.08,
                      ),
                      Container(
                        height: 60,
                        width: 60,
                        child: InkWell(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  selectedPage == 2
                                      ? Icons.notifications_active
                                      : Icons.notifications_active_outlined,
                                  color: selectedPage == 2
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey.shade400,
                                ),
                                Text(
                                  "Activités",
                                  style: textStyleCustomBold(
                                      selectedPage == 2
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Colors.grey.shade400,
                                      12),
                                )
                              ],
                            ),
                            onTap: () {
                              onTap(2);
                            }),
                      ),
                      Container(
                        height: 60,
                        width: 60,
                        child: InkWell(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  selectedPage == 3
                                      ? Icons.person
                                      : Icons.person_outlined,
                                  color: selectedPage == 3
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey.shade400,
                                ),
                                Text(
                                  "Profil",
                                  style: textStyleCustomBold(
                                      selectedPage == 3
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Colors.grey.shade400,
                                      12),
                                )
                              ],
                            ),
                            onTap: () {
                              onTap(3);
                            }),
                      ),
                    ],
                  ),
                )),
            BottomShare(),
          ],
        ),
      ),
    );
  }
}
