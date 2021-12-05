import 'package:flutter/material.dart';

import 'package:gemu/views/Welcome/welcome_screen.dart';
import 'package:gemu/views/Login/login_screen.dart';
import 'package:gemu/views/Register/register_screen.dart';
import 'package:gemu/views/Share/Post/create_post_screen.dart';
import 'package:gemu/views/GetStarted/get_started_screen.dart';
import 'package:gemu/constants/constants.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case LoginScreenRoute:
      return _getPageRoute(routeName: settings.name, viewToShow: LoginScreen());
    case WelcomeScreenRoute:
      return _getPageRoute(
          routeName: settings.name, viewToShow: WelcomeScreen());
    case RegisterScreenRoute:
      return _getPageRoute(
          routeName: settings.name, viewToShow: RegisterScreen());
    case GetStartedRoute:
      return _getPageRoute(
          routeName: settings.name, viewToShow: GetStartedScreen());
    case CreatePostRoute:
      return _getPageRoute(
          routeName: settings.name, viewToShow: AddPostScreen());
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
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
