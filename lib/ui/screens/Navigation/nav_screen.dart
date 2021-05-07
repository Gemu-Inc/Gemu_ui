import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:Gemu/services/database_service.dart';
import 'package:Gemu/ui/screens/screens.dart';
import 'package:Gemu/ui/screens/Direct/direct_screen.dart';
import 'package:Gemu/ui/screens/Highlights/highlights_screen.dart';
import 'package:Gemu/ui/widgets/bottom_share.dart';
import 'package:Gemu/models/game.dart';

class NavScreen extends StatefulWidget {
  NavScreen({Key? key}) : super(key: key);

  @override
  _NavScreenState createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKeyNav = GlobalKey<ScaffoldState>();

  int? page;
  String? uid;

  List<dynamic> test = [
    '2gR5FFB6k8CpSD8SWjZw',
    'IOkVvznk9wFTsDUOwOYb',
    'hPcqLphFAhhna9qMUWp7'
  ];

  @override
  void initState() {
    super.initState();
    page = 0;
    uid = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screenNav = [
      StreamProvider<List<Game>>.value(
          initialData: [],
          value: DatabaseService.getGamesFollow(test),
          child: HomeScreen()),
      HighlightsScreen(),
      GamesScreen(),
      DirectScreen()
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKeyNav,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: ProfilMenuDrawer(),
      endDrawer: ActivitiesMenuDrawer(),
      body: Stack(
        children: [
          screenNav[page!],
          Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  decoration: page == 0
                      ? BoxDecoration(
                          color: Colors.transparent,
                          border:
                              Border(top: BorderSide(color: Colors.white60)))
                      : BoxDecoration(
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
                      onTap: (index) {
                        setState(() {
                          page = index;
                          print('Page: $page');
                        });
                      },
                      currentIndex: page!,
                      fixedColor: Theme.of(context).primaryColor,
                      selectedIconTheme: IconThemeData(size: 26),
                      unselectedIconTheme: IconThemeData(size: 24),
                      selectedLabelStyle: TextStyle(fontSize: 14.0),
                      unselectedLabelStyle: TextStyle(fontSize: 12.0),
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
                            activeIcon: Icon(Icons.play_arrow),
                            icon: Icon(Icons.play_arrow_outlined),
                            label: 'Direct')
                      ])))
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: BottomShare(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
