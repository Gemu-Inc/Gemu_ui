import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gemu/riverpod/Connectivity/auth_provider.dart';
import 'package:gemu/riverpod/Users/myself_provider.dart';
import 'package:gemu/services/auth_service.dart';
import 'package:gemu/views/Activities/activities_screen.dart';
import 'package:gemu/views/Home/home_screen.dart';
import 'package:gemu/widgets/alert_dialog_custom.dart';
import 'package:loader/loader.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import 'package:gemu/models/game.dart';
import 'package:gemu/services/database_service.dart';
import 'package:gemu/widgets/bottom_share.dart';
import 'package:gemu/constants/constants.dart';
import 'package:gemu/riverpod/Home/index_games_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../views/Home/home_screen.dart';
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
  int selectedIndex = 0;
  late PersistentTabController _navController;

  bool isLoading = false;

  List<Game> gamesList = [];
  List<PageController> gamePageController = [];
  List followings = [];

  List<Widget> _buildScreens(int indexGames) {
    return [
      HomeScreen(
          followings: followings,
          games: gamesList,
          gamePageController: gamePageController,
          indexGamesHome: indexGames),
      HighlightsScreen(
        gamesUser: gamesList,
      ),
      HighlightsScreen(
        gamesUser: gamesList,
      ),
      ActivitiesMenuDrawer(uid: me!.uid),
      MyProfilScreen()
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.home),
        inactiveIcon: Icon(Icons.home_outlined),
        title: ("Accueil"),
        textStyle: textStyleCustomBold(Colors.transparent, 12),
        activeColorPrimary: Theme.of(context).colorScheme.primary,
        inactiveColorPrimary: Colors.grey.shade400,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.highlight),
        inactiveIcon: Icon(Icons.highlight_outlined),
        title: ("Sélection"),
        textStyle: textStyleCustomBold(Colors.transparent, 12),
        activeColorPrimary: Theme.of(context).colorScheme.primary,
        inactiveColorPrimary: Colors.grey.shade400,
      ),
      PersistentBottomNavBarItem(
          icon: Icon(
            Icons.add,
            size: 40,
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          activeColorPrimary: Theme.of(context).colorScheme.primary),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.notifications_active),
        inactiveIcon: Icon(Icons.notifications_active_outlined),
        title: ("Activités"),
        textStyle: textStyleCustomBold(Colors.transparent, 12),
        activeColorPrimary: Theme.of(context).colorScheme.primary,
        inactiveColorPrimary: Colors.grey.shade400,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.person),
        inactiveIcon: Icon(Icons.person_outlined),
        title: ("Profil"),
        textStyle: textStyleCustomBold(Colors.transparent, 12),
        activeColorPrimary: Theme.of(context).colorScheme.primary,
        inactiveColorPrimary: Colors.grey.shade400,
      ),
    ];
  }

  Future<bool> loadingData(String uid) async {
    await DatabaseService.getCurrentUser(uid, ref);

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

    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    User? user = await AuthService.getUser();
    if (!user!.emailVerified) {
      verifyAccount(context);
    } else {
      if (!me!.verifiedAccount!) {
        DatabaseService.updateVerifyAccount(me!.uid);
      }
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    _navController = PersistentTabController(initialIndex: selectedIndex);
    _navController.addListener(() {
      setState(() {});
    });
  }

  @override
  void deactivate() {
    _navController.removeListener(() {
      setState(() {});
    });
    super.deactivate();
  }

  @override
  void dispose() {
    _navController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    me = ref.watch(myselfNotifierProvider);
    final activeUser = ref.watch(authNotifierProvider);
    final indexGames = ref.watch(indexGamesNotifierProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
              statusBarColor: _navController.index == 0
                  ? Colors.black.withOpacity(0.5)
                  : Colors.transparent,
              statusBarIconBrightness: _navController.index == 0
                  ? Brightness.light
                  : Theme.of(context).brightness == Brightness.dark
                      ? Brightness.light
                      : Brightness.dark,
              systemNavigationBarColor: _navController.index == 0
                  ? Colors.black
                  : Theme.of(context).scaffoldBackgroundColor,
              systemNavigationBarIconBrightness: _navController.index == 0
                  ? Brightness.light
                  : Theme.of(context).brightness == Brightness.dark
                      ? Brightness.light
                      : Brightness.dark),
          child: Loader<void>(
            load: () => loadingData(activeUser!.uid),
            loadingWidget: Center(
                child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: 0.5,
            )),
            builder: (_, value) {
              return PersistentTabView(
                context,
                controller: _navController,
                screens: _buildScreens(indexGames),
                items: _navBarsItems(),
                confineInSafeArea: true,
                backgroundColor: _navController.index == 0
                    ? Colors.black
                    : Theme.of(context).scaffoldBackgroundColor,
                handleAndroidBackButtonPress: true,
                resizeToAvoidBottomInset: true,
                stateManagement: true,
                hideNavigationBarWhenKeyboardShows: true,
                decoration: NavBarDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0)),
                    boxShadow: [
                      BoxShadow(
                          color: _navController.index == 0
                              ? Colors.grey.shade400
                              : Theme.of(context).shadowColor,
                          blurRadius: 1,
                          spreadRadius: 1,
                          blurStyle: BlurStyle.solid)
                    ]),
                popAllScreensOnTapOfSelectedTab: true,
                popActionScreens: PopActionScreensType.all,
                itemAnimationProperties: ItemAnimationProperties(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.ease,
                ),
                screenTransitionAnimation: ScreenTransitionAnimation(
                  animateTabTransition: true,
                  curve: Curves.ease,
                  duration: Duration(milliseconds: 200),
                ),
                navBarStyle: NavBarStyle.style15,
              );
            },
          )),
    );
  }
}



// Stack(
//           children: [
//             Loader<void>(
//               load: () => loadingData(activeUser!.uid),
//               loadingWidget: Container(),
//               builder: (_, value) {
//                 return PageView(
//                   controller: _navPageController,
//                   physics: NeverScrollableScrollPhysics(),
//                   children: [
//                     HomeScreen(
//                         followings: followings,
//                         games: gamesList,
//                         gamePageController: gamePageController,
//                         indexGamesHome: indexGames),
//                     HighlightsScreen(
//                       gamesUser: gamesList,
//                     ),
//                     ActivitiesMenuDrawer(uid: me!.uid),
//                     MyProfilScreen()
//                   ],
//                 );
//               },
//             ),
//             Positioned(
//                 bottom: 0,
//                 left: 0,
//                 child: Container(
//                   width: MediaQuery.of(context).size.width,
//                   height: 60,
//                   decoration: (selectedPage != 0 || !isLoading)
//                       ? BoxDecoration(
//                           color: Theme.of(context).scaffoldBackgroundColor,
//                           boxShadow: [
//                               BoxShadow(
//                                 color: Theme.of(context).shadowColor,
//                                 blurRadius: 1,
//                                 spreadRadius: 3,
//                               )
//                             ])
//                       : BoxDecoration(
//                           color: Colors.black.withOpacity(0.2),
//                           border: Border(
//                               top: BorderSide(
//                                   color: Colors.white60, width: 0.5)),
//                         ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       Container(
//                         height: 60,
//                         width: 60,
//                         alignment: Alignment.center,
//                         child: InkWell(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(
//                                   selectedPage == 0
//                                       ? Icons.home
//                                       : Icons.home_outlined,
//                                   color: selectedPage == 0
//                                       ? Theme.of(context).colorScheme.primary
//                                       : Colors.grey.shade400,
//                                 ),
//                                 Text(
//                                   "Accueil",
//                                   style: textStyleCustomBold(
//                                       selectedPage == 0
//                                           ? Theme.of(context)
//                                               .colorScheme
//                                               .primary
//                                           : Colors.grey.shade400,
//                                       12),
//                                 )
//                               ],
//                             ),
//                             onTap: () {
//                               onTap(0);
//                             }),
//                       ),
//                       Container(
//                         height: 60,
//                         width: 60,
//                         child: InkWell(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(
//                                   selectedPage == 1
//                                       ? Icons.highlight
//                                       : Icons.highlight_outlined,
//                                   color: selectedPage == 1
//                                       ? Theme.of(context).colorScheme.primary
//                                       : Colors.grey.shade400,
//                                 ),
//                                 Text(
//                                   "Sélection",
//                                   style: textStyleCustomBold(
//                                       selectedPage == 1
//                                           ? Theme.of(context)
//                                               .colorScheme
//                                               .primary
//                                           : Colors.grey.shade400,
//                                       12),
//                                 )
//                               ],
//                             ),
//                             onTap: () {
//                               onTap(1);
//                             }),
//                       ),
//                       Container(
//                         width: MediaQuery.of(context).size.width * 0.08,
//                       ),
//                       Container(
//                         height: 60,
//                         width: 60,
//                         child: InkWell(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(
//                                   selectedPage == 2
//                                       ? Icons.notifications_active
//                                       : Icons.notifications_active_outlined,
//                                   color: selectedPage == 2
//                                       ? Theme.of(context).colorScheme.primary
//                                       : Colors.grey.shade400,
//                                 ),
//                                 Text(
//                                   "Activités",
//                                   style: textStyleCustomBold(
//                                       selectedPage == 2
//                                           ? Theme.of(context)
//                                               .colorScheme
//                                               .primary
//                                           : Colors.grey.shade400,
//                                       12),
//                                 )
//                               ],
//                             ),
//                             onTap: () {
//                               onTap(2);
//                             }),
//                       ),
//                       Container(
//                         height: 60,
//                         width: 60,
//                         child: InkWell(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(
//                                   selectedPage == 3
//                                       ? Icons.person
//                                       : Icons.person_outlined,
//                                   color: selectedPage == 3
//                                       ? Theme.of(context).colorScheme.primary
//                                       : Colors.grey.shade400,
//                                 ),
//                                 Text(
//                                   "Profil",
//                                   style: textStyleCustomBold(
//                                       selectedPage == 3
//                                           ? Theme.of(context)
//                                               .colorScheme
//                                               .primary
//                                           : Colors.grey.shade400,
//                                       12),
//                                 )
//                               ],
//                             ),
//                             onTap: () {
//                               onTap(3);
//                             }),
//                       ),
//                     ],
//                   ),
//                 )),
//             BottomShare(),
//           ],
//         ),
