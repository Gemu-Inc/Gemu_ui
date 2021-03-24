import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:Gemu/screensmodels/Navigation/nav_screen_model.dart';
import 'package:Gemu/services/firestore_service.dart';
import 'package:Gemu/ui/screens/screens.dart';
import 'package:Gemu/ui/screens/Direct/direct_screen.dart';
import 'package:Gemu/ui/screens/Highlights/highlights_screen.dart';
import 'package:Gemu/locator.dart';
import 'package:Gemu/ui/widgets/bottom_share.dart';

class NavScreen extends StatefulWidget {
  NavScreen({Key key}) : super(key: key);

  @override
  _NavScreenState createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKeyNav = GlobalKey<ScaffoldState>();

  int page;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = locator<FirestoreService>();

  @override
  void initState() {
    super.initState();
    page = 0;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screenNav = [
      FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(_firebaseAuth.currentUser.uid)
            .get(),
        builder: (context, snapshotUser) {
          if (!snapshotUser.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return StreamProvider(
              create: (BuildContext context) => _firestoreService
                  .getGamesFollow(snapshotUser.data['idGames']),
              child: HomeScreen());
        },
      ),
      HighlightsScreen(),
      GamesScreen(),
      DirectScreen()
    ];

    return ViewModelBuilder<NavScreenModel>.reactive(
        viewModelBuilder: () => NavScreenModel(),
        builder: (context, model, child) => Scaffold(
              key: _scaffoldKeyNav,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              drawer: ProfilMenuDrawer(),
              endDrawer: ActivitiesMenuDrawer(),
              body: Stack(
                children: [
                  screenNav[page],
                  Positioned(
                      left: 0,
                      bottom: 0,
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 60,
                          decoration: page == 0
                              ? BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border(
                                      top: BorderSide(color: Colors.white60)))
                              : BoxDecoration(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
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
                              currentIndex: page,
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
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              floatingActionButton: BottomShare(),
            ));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
