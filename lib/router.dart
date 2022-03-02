import 'package:flutter/material.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/views/Games/games_screen.dart';
import 'package:gemu/views/Highlights/highlights_screen.dart';
import 'package:gemu/views/Home/home_screen.dart';
import 'package:gemu/views/Profil/profil_screen.dart';
import 'package:gemu/views/Share/Post/create_post_screen.dart';
import 'package:gemu/views/Welcome/welcome_screen.dart';
import 'package:gemu/views/Login/login_screen.dart';
import 'package:gemu/views/Register/register_screen.dart';
import 'package:gemu/views/GetStarted/get_started_screen.dart';
import 'package:gemu/views/Navigation/navigation_screen.dart';

///Voir comment bien mettre en place les args des classes

Route<dynamic> generateRoute(RouteSettings settings, BuildContext context) {
  switch (settings.name) {
    case Welcome:
      return _getPageRoute(
          routeName: settings.name, viewToShow: WelcomeScreen());
    // case GetStarted:
    //   return _getPageRoute(
    //       routeName: settings.name, viewToShow: GetStartedScreen());
    case Register:
      return _getPageRoute(
          routeName: settings.name, viewToShow: RegisterScreen());
    case Login:
      return _getPageRoute(routeName: settings.name, viewToShow: LoginScreen());
    case Navigation:
      return _getPageRoute(
          routeName: settings.name,
          viewToShow: NavigationScreen(
            uid: '',
          ));
    case Home:
      return _getPageRoute(
          routeName: settings.name,
          viewToShow: HomeScreen(
              followings: [],
              games: [],
              gamePageController: [],
              indexGamesHome: 0));
    case Highlights:
      return _getPageRoute(
          routeName: settings.name,
          viewToShow: HighlightsScreen(gamesUser: []));
    case Games:
      return _getPageRoute(
          routeName: settings.name,
          viewToShow: GamesScreen(games: [], indexGamesHome: 0));
    case MyProfil:
      return _getPageRoute(
          routeName: settings.name, viewToShow: MyProfilScreen());
    case AddPost:
      return _getPageRoute(
          routeName: settings.name, viewToShow: AddPostScreen());
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
