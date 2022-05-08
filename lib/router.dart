import 'package:flutter/material.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/views/Activities/activities_screen.dart';
import 'package:gemu/views/GetStarted/get_started_screen.dart';
import 'package:gemu/views/Highlights/highlights_screen.dart';
import 'package:gemu/views/Home/home_screen.dart';
import 'package:gemu/views/Profil/profil_screen.dart';
import 'package:gemu/views/Share/Post/Picture/picture_editor_screen.dart';
import 'package:gemu/views/Share/Post/Video/video_editor_screen.dart';
import 'package:gemu/views/Welcome/welcome_screen.dart';
import 'package:gemu/views/Login/login_screen.dart';
import 'package:gemu/views/Register/register_screen.dart';
import 'package:gemu/controllers/bottom_navigation_controller.dart';

Route<dynamic> generateRouteNonAuth(
    RouteSettings settings, BuildContext context) {
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
  final List<dynamic>? args = settings.arguments as List<dynamic>?;
  switch (settings.name) {
    case Navigation:
      return MaterialPageRoute(builder: (_) => BottomNavigationController());
    case Home:
      return MaterialPageRoute(
          builder: (_) => HomeScreen(
              followings: args![0],
              games: args[1],
              gamePageController: args[2],
              indexGamesHome: args[3]));
    case Highlights:
      return MaterialPageRoute(
          builder: (_) => HighlightsScreen(gamesUser: args![0]));
    case Activities:
      return MaterialPageRoute(
          builder: (_) => ActivitiesMenuDrawer(uid: args![0]));
    case Profile:
      return MaterialPageRoute(builder: (_) => MyProfilScreen());
    case PictureEditor:
      return MaterialPageRoute(
          builder: (_) => PictureEditorScreen(file: args![0]));
    case VideoEditor:
      return MaterialPageRoute(
          builder: (_) => VideoEditorScreen(file: args![0]));
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
  }
}
