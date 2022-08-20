import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemu/providers/Users/myself_provider.dart';

import 'package:gemu/components/bottom_share.dart';
import 'package:gemu/components/customNavBar.dart';
import 'package:gemu/constants/constants.dart';
import 'package:gemu/router.dart';

class BottomNavigationController extends ConsumerStatefulWidget {
  BottomNavigationController({Key? key}) : super(key: key);

  @override
  _BottomNavigationControllerState createState() =>
      _BottomNavigationControllerState();
}

class _BottomNavigationControllerState
    extends ConsumerState<BottomNavigationController>
    with TickerProviderStateMixin {
  late TabController _navController;
  User? activeUser;

  List<Widget> _buildScreens() {
    return [
      WillPopScope(
          child: Navigator(
            key: navHomeAuthKey,
            initialRoute: Home,
            onGenerateRoute: (settings) =>
                generateRouteHomeAuth(settings, context),
          ),
          onWillPop: () async {
            return !(await navHomeAuthKey!.currentState!.maybePop());
          }),
      WillPopScope(
          child: Navigator(
            key: navCommunityAuthKey,
            initialRoute: Community,
            onGenerateRoute: (settings) =>
                generateRouteCommunityAuth(settings, context),
          ),
          onWillPop: () async {
            return !(await navCommunityAuthKey!.currentState!.maybePop());
          }),
      WillPopScope(
          child: Navigator(
            key: navActivitiesAuthKey,
            initialRoute: Activities,
            onGenerateRoute: (settings) =>
                generateRouteActivitiesAuth(settings, context),
          ),
          onWillPop: () async {
            return !(await navActivitiesAuthKey!.currentState!.maybePop());
          }),
      WillPopScope(
          child: Navigator(
            key: navProfileAuthKey,
            initialRoute: Profile,
            onGenerateRoute: (settings) =>
                generateRouteProfileAuth(settings, context),
          ),
          onWillPop: () async {
            return !(await navProfileAuthKey!.currentState!.maybePop());
          })
    ];
  }

  List<BottomNavigationBarItem> _navBarsItems() {
    return [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: ("Accueil"),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.highlight_outlined),
        activeIcon: Icon(Icons.highlight),
        label: ("Communauté"),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.notifications_active_outlined),
        activeIcon: Icon(Icons.notifications_active),
        label: ("Activités"),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outlined),
        activeIcon: Icon(Icons.person),
        label: ("Profil"),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    navHomeAuthKey = GlobalKey<NavigatorState>();
    navCommunityAuthKey = GlobalKey<NavigatorState>();
    navActivitiesAuthKey = GlobalKey<NavigatorState>();
    navProfileAuthKey = GlobalKey<NavigatorState>();

    _navController = TabController(
        initialIndex: 0,
        length: 4,
        animationDuration: Duration.zero,
        vsync: this);
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

    return Scaffold(
      backgroundColor: _navController.index == 0
          ? cBGDarkTheme
          : Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        top: false,
        left: false,
        right: false,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: _navController,
                      children: _buildScreens()),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: CustomNavBar(
                    items: _navBarsItems(),
                    selectedIndex: _navController.index,
                    onItemSelected: (index) {
                      if (_navController.index == 0 && index == 0) {
                        navHomeAuthKey!.currentState!
                            .popUntil((route) => route.isFirst);
                      } else if (_navController.index == 1 && index == 1) {
                        navCommunityAuthKey!.currentState!
                            .popUntil((route) => route.isFirst);
                      } else if (_navController.index == 2 && index == 2) {
                        navActivitiesAuthKey!.currentState!
                            .popUntil((route) => route.isFirst);
                      } else if (_navController.index == 3 && index == 3) {
                        navProfileAuthKey!.currentState!
                            .popUntil((route) => route.isFirst);
                      } else {
                        setState(() {
                          _navController.index = index;
                        });
                      }
                    },
                  ),
                )
              ],
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
        ),
      ),
    );
  }
}
