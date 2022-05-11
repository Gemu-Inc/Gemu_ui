import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import 'package:gemu/riverpod/Connectivity/auth_provider.dart';
import 'package:gemu/riverpod/Users/myself_provider.dart';
import 'package:gemu/views/Activities/activities_screen.dart';
import 'package:gemu/views/Home/home_screen.dart';
import 'package:gemu/widgets/bottom_share.dart';
import 'package:gemu/widgets/customNavBar.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/constants/constants.dart';
import 'package:gemu/riverpod/Home/index_games_provider.dart';

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
  late PersistentTabController _navController;
  User? activeUser;

  List<Widget> _buildScreens(User? activeUser, int indexGames, List followings,
      List<Game> gamesList, List<PageController> gamePageController) {
    return [
      HomeScreen(
          followings: followings,
          games: gamesList,
          gamePageController: gamePageController,
          indexGamesHome: indexGames),
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
        inactiveColorPrimary: Color(0xFFC3BCF5).withOpacity(0.7),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.highlight),
        inactiveIcon: Icon(Icons.highlight_outlined),
        title: ("Sélection"),
        textStyle: textStyleCustomBold(Colors.transparent, 12),
        activeColorPrimary: Theme.of(context).colorScheme.primary,
        inactiveColorPrimary: Color(0xFFC3BCF5).withOpacity(0.7),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.notifications_active),
        inactiveIcon: Icon(Icons.notifications_active_outlined),
        title: ("Activités"),
        textStyle: textStyleCustomBold(Colors.transparent, 12),
        activeColorPrimary: Theme.of(context).colorScheme.primary,
        inactiveColorPrimary: Color(0xFFC3BCF5).withOpacity(0.7),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.person),
        inactiveIcon: Icon(Icons.person_outlined),
        title: ("Profil"),
        textStyle: textStyleCustomBold(Colors.transparent, 12),
        activeColorPrimary: Theme.of(context).colorScheme.primary,
        inactiveColorPrimary: Color(0xFFC3BCF5).withOpacity(0.7),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _navController = PersistentTabController(initialIndex: 0);
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
    activeUser = ref.watch(authNotifierProvider);
    final gamesList = ref.read(myGamesNotifierProvider);
    final gamesControllerList = ref.read(myGamesControllerNotifierProvider);
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
            child: Stack(
              children: [
                PersistentTabView.custom(
                  context,
                  controller: _navController,
                  itemCount: 4,
                  screens: _buildScreens(activeUser, indexGames, [], gamesList,
                      gamesControllerList),
                  confineInSafeArea: true,
                  handleAndroidBackButtonPress: true,
                  stateManagement: true,
                  hideNavigationBarWhenKeyboardShows: true,
                  backgroundColor: _navController.index == 0
                      ? Colors.transparent
                      : Theme.of(context).scaffoldBackgroundColor,
                  customWidget: CustomNavBar(
                    items: _navBarsItems(),
                    selectedIndex: _navController.index,
                    onItemSelected: (index) {
                      setState(() {
                        _navController.index = index;
                      });
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      child: BottomShare(),
                    ),
                  ),
                )
              ],
            )));
  }
}
