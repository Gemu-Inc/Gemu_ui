import 'dart:io';
import 'package:Gemu/constants/route_names.dart';
import 'package:Gemu/screensmodels/Navigation/nav_screen_model.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/ui/screens/screens.dart';
import 'package:Gemu/ui/widgets/widgets.dart';
import 'package:Gemu/models/data.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:Gemu/locator.dart';
import 'package:Gemu/services/navigation_service.dart';
import 'package:stacked/stacked.dart';

class NavScreen extends StatefulWidget {
  NavScreen({Key key}) : super(key: key);

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

  final List<IconData> _icons = [
    Icons.home,
    Icons.search,
    Icons.people,
    Icons.videogame_asset
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: _icons.length, vsync: this);
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
    return ViewModelBuilder<NavScreenModel>.reactive(
        viewModelBuilder: () => NavScreenModel(),
        builder: (context, model, child) => Scaffold(
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
                  onPress: () => model.navigateToProfil()),
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
                    }),
              ],
            ),
            body: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [
                  HomeScreen(),
                  DiscoverScreen(),
                  ClansScreen(),
                  GamesScreen()
                ]),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: BottomShare(),
            bottomNavigationBar:
                CustomTabBar(icons: _icons, controller: _tabController)));
  }
}
