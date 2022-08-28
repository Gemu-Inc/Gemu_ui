import 'package:flutter/material.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/views/Activities/activities_screen.dart';
import 'package:gemu/views/Explore/search_screen.dart';
import 'package:gemu/views/Games/profile_game_screen.dart';
import 'package:gemu/views/GetStarted/get_started_screen.dart';
import 'package:gemu/views/Explore/explore_screen.dart';
import 'package:gemu/views/Hashtags/hashtags_screen.dart';
import 'package:gemu/views/Home/add_screen.dart';
import 'package:gemu/views/Home/home_screen.dart';
import 'package:gemu/views/Posts/posts_feed_screen.dart';
import 'package:gemu/views/Profile/myself_profile_screen.dart';
import 'package:gemu/views/Profile/profile_user_screen.dart';
import 'package:gemu/views/Reglages/reglages_screen.dart';
import 'package:gemu/views/Create/Picture/picture_editor_screen.dart';
import 'package:gemu/views/Create/Picture/picture_screen.dart';
import 'package:gemu/views/Create/Video/video_editor_screen.dart';
import 'package:gemu/views/Create/Video/video_screen.dart';
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
    case PostNewPicture:
      return MaterialPageRoute(
          builder: (_) => PictureScreen(
              file: args![0],
              public: args[1],
              caption: args[2],
              hashtags: args[3],
              followsGames: args[4],
              selectedGame: args[5]));
    case VideoEditor:
      return MaterialPageRoute(
          builder: (_) => VideoEditorScreen(file: args![0]));
    case PostNewVideo:
      return MaterialPageRoute(
          builder: (_) => VideoScreen(
              file: args![0],
              public: args[1],
              caption: args[2],
              hashtags: args[3],
              followsGames: args[4],
              selectedGame: args[5]));
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
Route<dynamic> generateRouteExploreAuth(
    RouteSettings settings, BuildContext context) {
  final List<dynamic>? args = settings.arguments as List<dynamic>?;
  switch (settings.name) {
    case Explore:
      return MaterialPageRoute(builder: (_) => ExploreScreen());
    case PostsFeed:
      return MaterialPageRoute(
          builder: (_) => PostsFeedScreen(
              title: args![0],
              navKey: args[1],
              index: args[2],
              posts: args[3]));
    case Search:
      return MaterialPageRoute(builder: (_) => SearchScreen());
    case HashtagProfile:
      return MaterialPageRoute(
          builder: (_) => HashtagsScreen(hashtag: args![0], navKey: args[1]));
    case GameProfile:
      return MaterialPageRoute(
          builder: (_) => ProfileGameScreen(
                game: args![0],
                navKey: args[1],
              ));
    case UserProfile:
      return MaterialPageRoute(
          builder: (_) => ProfileUser(userPostID: args![0]));
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
      return MaterialPageRoute(builder: (_) => MyselfProfileScreen());
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
