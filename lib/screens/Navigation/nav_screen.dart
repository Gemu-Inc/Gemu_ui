import 'dart:io';
import 'package:flutter/material.dart';
import 'package:Gemu/screens/screens.dart';
import 'package:Gemu/components/components.dart';
import 'package:Gemu/core/data/data.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class NavScreen extends StatefulWidget {
  static final String routeName = 'nav';

  final auth.User firebaseUser;

  NavScreen({this.firebaseUser});

  @override
  _NavScreenState createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKeyNav = GlobalKey<ScaffoldState>();

  List<String> appBarTitles = ['Home', 'Parcourir', 'Clans', 'Games'];

  TabController _tabController;
  int currentTabIndex = 0;
  String initialAppBarTitle = 'Home';

  final List<Tab> _tabs = <Tab>[
    Tab(icon: Icon(Icons.home)),
    Tab(
      icon: Icon(Icons.search),
    ),
    Tab(
      icon: Icon(Icons.people),
    ),
    Tab(icon: Icon(Icons.videogame_asset))
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    currentTabIndex = 0;
  }

  void _onTabChanged() {
    /// Only manually set the index if it is changing from a swipe, not a tab selection (indexIsChanging is only true when selecting a tab, and tab index is automatically changed) to avoid setting the index twice when a tab is selected
    if (!_tabController.indexIsChanging)
      setState(() {
        print('Changing to Tab: ${_tabController.index}');
        currentTabIndex = _tabController.index;
        initialAppBarTitle = appBarTitles[_tabController.index];
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyNav,
      appBar: GradientAppBar(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).accentColor
          ],
        ),
        leading: ProfilButton(
            currentUser: currentUser,
            width: 33,
            height: 33,
            colorFond: Colors.transparent,
            colorBorder: Colors.black,
            onPress: () {
              Navigator.pushNamed(context, ProfilMenu.routeName);
            }),
        title: Text(initialAppBarTitle),
        centerTitle: true,
        actions: [
          IconButton(
              icon: Icon(
                Icons.notifications,
                size: 33,
              ),
              onPressed: () {
                print('Notifications');
              })
        ],
      ),
      body: TabBarView(controller: _tabController, children: [
        HomeScreen(),
        SearchScreen(),
        ClansScreen(),
        GamesScreen()
      ]),
      bottomNavigationBar: TabBar(
        tabs: _tabs,
        controller: _tabController,
      ),
    );
  }
}
