import 'package:flutter/material.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/views/GetStarted/get_started_screen.dart';
import 'package:gemu/views/Welcome/welcome_screen.dart';
import 'package:gemu/views/Login/login_screen.dart';
import 'package:gemu/views/Register/register_screen.dart';
import 'package:gemu/views/Navigation/bottom_navigation_screen.dart';

Route<dynamic> generateRouteNonAuth(
    RouteSettings settings, BuildContext context) {
  final args = settings.arguments;
  switch (settings.name) {
    case GetStartedBefore:
      return MaterialPageRoute(builder: (_) => GetStartedBeforeScreen());
    case GetStarted:
      return MaterialPageRoute(builder: (_) => GetStartedScreen());
    case Welcome:
      return MaterialPageRoute(builder: (_) => WelcomeScreen());
    case Login:
      return MaterialPageRoute(builder: (_) => LoginScreen());
    case Register:
      return MaterialPageRoute(builder: (_) => RegisterScreen());
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
  }
}

Route<dynamic> generateRouteAuth(RouteSettings settings, BuildContext context) {
  final args = settings.arguments;
  switch (settings.name) {
    case Navigation:
      return MaterialPageRoute(builder: (_) => BottomNavigationScreen());
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
  }
}

PageRoute _getPageRoute({String? routeName, Widget? viewToShow}) {
  return MaterialPageRoute(
      settings: RouteSettings(
        name: routeName,
      ),
      builder: (_) => viewToShow!);
}
