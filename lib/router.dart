import 'package:flutter/material.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/views/Activities/activities_screen.dart';
import 'package:gemu/views/Games/profile_game_screen.dart';
import 'package:gemu/views/GetStarted/get_started_screen.dart';
import 'package:gemu/views/Highlights/highlights_screen.dart';
import 'package:gemu/views/Home/add_screen.dart';
import 'package:gemu/views/Home/home_screen.dart';
import 'package:gemu/views/Post/posts_feed_screen.dart';
import 'package:gemu/views/Profil/profil_screen.dart';
import 'package:gemu/views/Reglages/reglages_screen.dart';
import 'package:gemu/views/Share/Post/Picture/picture_editor_screen.dart';
import 'package:gemu/views/Share/Post/Video/video_editor_screen.dart';
import 'package:gemu/views/Welcome/welcome_screen.dart';
import 'package:gemu/views/Login/login_screen.dart';
import 'package:gemu/views/Register/register_screen.dart';
import 'package:gemu/controllers/bottom_navigation_controller.dart';

//router non auth part
Route<dynamic> generateRouteNonAuth(
    RouteSettings settings, BuildContext context) {
  final List<dynamic>? args = settings.arguments as List<dynamic>?;
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
      return MaterialPageRoute(
          builder: (_) => RegisterScreen(
                isSocial: args![0],
                user: args[1],
              ));
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
  }
}

//router main auth part
Route<dynamic> generateRouteMainAuth(
    RouteSettings settings, BuildContext context) {
  final List<dynamic>? args = settings.arguments as List<dynamic>?;
  switch (settings.name) {
    case BottomTabNav:
      return MaterialPageRoute(builder: (_) => BottomNavigationController());
    case Add:
      return MaterialPageRoute(builder: (_) => AddScreen());
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

//router auth home part
Route<dynamic> generateRouteHomeAuth(
    RouteSettings settings, BuildContext context) {
  final List<dynamic>? args = settings.arguments as List<dynamic>?;
  switch (settings.name) {
    case Home:
      return MaterialPageRoute(builder: (_) => HomeScreen());
    case GameProfile:
      return MaterialPageRoute(
          builder: (_) => ProfileGameScreen(
                game: args![0],
                navKey: args[1],
              ));
    case PostsFeed:
      return MaterialPageRoute(
          builder: (_) => PostsFeedScreen(
              title: args![0],
              navKey: args[1],
              index: args[2],
              posts: args[3]));
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
  }
}

//router auth selection part
Route<dynamic> generateRouteSelectionAuth(
    RouteSettings settings, BuildContext context) {
  final List<dynamic>? args = settings.arguments as List<dynamic>?;
  switch (settings.name) {
    case Highlights:
      return MaterialPageRoute(builder: (_) => HighlightsScreen());
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
  }
}

//router auth activities part
Route<dynamic> generateRouteActivitiesAuth(
    RouteSettings settings, BuildContext context) {
  final List<dynamic>? args = settings.arguments as List<dynamic>?;
  switch (settings.name) {
    case Activities:
      return MaterialPageRoute(builder: (_) => ActivitiesMenuDrawer());
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
  }
}

//router auth profile part
Route<dynamic> generateRouteProfileAuth(
    RouteSettings settings, BuildContext context) {
  final List<dynamic>? args = settings.arguments as List<dynamic>?;
  switch (settings.name) {
    case Profile:
      return MaterialPageRoute(builder: (_) => MyProfilScreen());
    case Reglages:
      return MaterialPageRoute(builder: (_) => ReglagesScreen(user: args![0]));
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
  }
}
