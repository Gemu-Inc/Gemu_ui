import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            return !(await navHomeAuthKey.currentState!.maybePop());
          }),
      WillPopScope(
          child: Navigator(
            key: navSelectionAuthKey,
            initialRoute: Highlights,
            onGenerateRoute: (settings) =>
                generateRouteSelectionAuth(settings, context),
          ),
          onWillPop: () async {
            return !(await navSelectionAuthKey.currentState!.maybePop());
          }),
      WillPopScope(
          child: Navigator(
            key: navActivitiesAuthKey,
            initialRoute: Activities,
            onGenerateRoute: (settings) =>
                generateRouteActivitiesAuth(settings, context),
          ),
          onWillPop: () async {
            return !(await navProfileAuthKey.currentState!.maybePop());
          }),
      WillPopScope(
          child: Navigator(
            key: navProfileAuthKey,
            initialRoute: Profile,
            onGenerateRoute: (settings) =>
                generateRouteProfileAuth(settings, context),
          ),
          onWillPop: () async {
            return !(await navProfileAuthKey.currentState!.maybePop());
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
        label: ("Sélection"),
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
      body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
              statusBarColor: _navController.index == 0
                  ? Color(0xFF22213C).withOpacity(0.5)
                  : Colors.transparent,
              statusBarIconBrightness: _navController.index == 0
                  ? Brightness.light
                  : Theme.of(context).brightness == Brightness.dark
                      ? Brightness.light
                      : Brightness.dark,
              systemNavigationBarColor: _navController.index == 0
                  ? Color(0xFF22213C)
                  : Theme.of(context).scaffoldBackgroundColor,
              systemNavigationBarIconBrightness: _navController.index == 0
                  ? Brightness.light
                  : Theme.of(context).brightness == Brightness.dark
                      ? Brightness.light
                      : Brightness.dark),
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
                          while (navHomeAuthKey.currentState!.canPop()) {
                            navHomeAuthKey.currentState!.pop();
                          }
                        } else if (_navController.index == 1 && index == 1) {
                          while (navSelectionAuthKey.currentState!.canPop()) {
                            navSelectionAuthKey.currentState!.pop();
                          }
                        } else if (_navController.index == 2 && index == 2) {
                          while (navActivitiesAuthKey.currentState!.canPop()) {
                            navActivitiesAuthKey.currentState!.pop();
                          }
                        } else if (_navController.index == 3 && index == 3) {
                          while (navProfileAuthKey.currentState!.canPop()) {
                            navProfileAuthKey.currentState!.pop();
                          }
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
                  padding: EdgeInsets.only(bottom: 5),
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    child: BottomShare(),
                  ),
                ),
              )
            ],
          )),
    );
  }
}
