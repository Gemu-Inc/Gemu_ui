import 'package:flutter/material.dart';
import 'package:Gemu/screens/screens.dart';
import 'package:Gemu/widgets/widgets.dart';
import 'package:Gemu/data/data.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

class NavScreen extends StatefulWidget {
  NavScreen({Key key}) : super(key: key);

  @override
  _NavScreenState createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  final List<Widget> _screens = [
    HomeScreen(),
    SearchScreen(),
    ClansScreen(),
    GamesScreen(),
  ];
  final List<IconData> _icons = [
    Icons.home,
    Icons.search,
    Icons.people,
    Icons.videogame_asset,
  ];
  int _selectedIndex = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;

  bool isDrawerOpen = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      transform: Matrix4.translationValues(xOffset, yOffset, 0)
        ..scale(scaleFactor)
        ..rotateY(isDrawerOpen ? 0 : 0),
      duration: Duration(milliseconds: 500),
      child: DefaultTabController(
        length: _icons.length,
        child: Scaffold(
          key: _scaffoldKey,
          endDrawer: MessagerieMenu(),
          body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverGradientAppBar(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).accentColor
                    ],
                  ),
                  pinned: true,
                  leading: ProfilButton(
                      currentUser: currentUser,
                      width: 40,
                      height: 40,
                      colorFond: Colors.transparent,
                      colorBorder: Colors.black,
                      onPress: () => Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return ProfilMenu();
                          }))),
                  /*isDrawerOpen
                      ? IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              xOffset = 0;
                              yOffset = 0;
                              scaleFactor = 1;
                              isDrawerOpen = false;
                            });
                          })
                      : ProfilButton(
                          currentUser: currentUser,
                          width: 40,
                          height: 40,
                          colorFond: Colors.transparent,
                          colorBorder: Colors.black,
                          onPress: () {
                            setState(() {
                              xOffset = 0;
                              yOffset = 555;
                              scaleFactor = 1;
                              isDrawerOpen = true;
                            });
                          }),*/
                  actions: [
                    Container(
                      margin: EdgeInsets.only(right: 5.0),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        /*boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).cardColor,
                            offset: Offset(10.0, 5.0),
                            blurRadius: 2.0,
                          ),
                        ],*/
                      ),
                      child: IconButton(
                        icon:
                            Icon(Icons.message, size: 40, color: Colors.black),
                        onPressed: () =>
                            _scaffoldKey.currentState.openEndDrawer(),
                      ),
                    )
                  ],
                  expandedHeight: 110,
                  flexibleSpace: FlexibleSpaceBar(
                      background: Align(
                    alignment: Alignment.center,
                    child: MessageUser(currentUser: currentUser),
                  )),
                ),
                SliverToBoxAdapter(child: AppBarAnimate())
              ];
            },
            body: TabBarView(
                physics: NeverScrollableScrollPhysics(), children: _screens),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: BottomShare(),
          bottomNavigationBar: CustomTabBar(
            icons: _icons,
            selectedIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
          ),
        ),
      ),
    );
  }
}
