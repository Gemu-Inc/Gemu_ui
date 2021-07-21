import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gemu/models/user.dart';
import 'package:gemu/services/database_service.dart';

import 'package:gemu/ui/widgets/bottom_share.dart';
import 'package:gemu/ui/constants/constants.dart';

import '../screens/Home/home_screen.dart';
import '../screens/Games/games_screen.dart';
import '../screens/Direct/direct_screen.dart';
import '../screens/Highlights/highlights_screen.dart';
import '../screens/Profil/profil_screen.dart';
import '../screens/Activities/activities_screen.dart';

class NavController extends StatefulWidget {
  final String uid;

  NavController({Key? key, required this.uid}) : super(key: key);

  @override
  _NavControllerState createState() => _NavControllerState();
}

class _NavControllerState extends State<NavController> {
  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  late StreamSubscription streamListener;

  final PageController navController = PageController();

  int selectedPage = 0;

  final items = [
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
        activeIcon: Icon(Icons.play_arrow),
        icon: Icon(Icons.play_arrow_outlined),
        label: 'Direct')
  ];

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
    streamListener = DatabaseService.usersCollectionReference
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
  }

  @override
  void dispose() {
    navController.dispose();
    streamListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (me == null || me!.uid != widget.uid)
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
            drawerEdgeDragWidth: MediaQuery.of(context).size.width / 2,
            drawerEnableOpenDragGesture: true,
            endDrawerEnableOpenDragGesture: true,
            drawer: ProfilMenuDrawer(user: me!),
            endDrawer: ActivitiesMenuDrawer(
              uid: me!.uid,
            ),
            body: PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: navController,
              onPageChanged: onPageChanged,
              children: [
                HomeScreen(uid: me!.uid),
                HighlightsScreen(
                  uid: me!.uid,
                ),
                GamesScreen(
                  uid: me!.uid,
                ),
                DirectScreen(
                  uid: me!.uid,
                )
              ],
            ),
            bottomNavigationBar: Container(
                width: MediaQuery.of(context).size.width,
                height: 60,
                decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor,
                        blurRadius: 1,
                        spreadRadius: 3,
                      )
                    ]),
                child: BottomNavigationBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    type: BottomNavigationBarType.fixed,
                    currentIndex: selectedPage,
                    onTap: onTap,
                    fixedColor: Theme.of(context).primaryColor,
                    selectedIconTheme: IconThemeData(size: 26),
                    unselectedIconTheme: IconThemeData(size: 24),
                    selectedLabelStyle: TextStyle(fontSize: 14.0),
                    unselectedLabelStyle: TextStyle(fontSize: 12.0),
                    items: items)),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: BottomShare(),
          );
  }
}
