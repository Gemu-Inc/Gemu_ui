import 'package:Gemu/ui/screens/Login/login_screen.dart';
import 'package:Gemu/ui/screens/Navigation/nav_screen.dart';
import 'package:Gemu/ui/screens/Reglages/edit_profile_screen.dart';
import 'package:Gemu/ui/screens/Profil/profil_screen.dart';
import 'package:Gemu/ui/screens/Reglages/reglages_screen.dart';
import 'package:Gemu/ui/screens/Register/register_screen.dart';
import 'package:Gemu/ui/screens/Search/search_screen.dart';
import 'package:Gemu/ui/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/constants/route_names.dart';
import 'package:Gemu/ui/screens/Welcome/welcome_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case WelcomeScreenRoute:
      return _getPageRoute(
          routeName: settings.name, viewToShow: WelcomeScreen());
    case LoginScreenRoute:
      return _getPageRoute(routeName: settings.name, viewToShow: LoginScreen());
    case RegisterScreenRoute:
      return _getPageRoute(
          routeName: settings.name, viewToShow: RegisterScreen());
    case NavScreenRoute:
      return _getPageRoute(routeName: settings.name, viewToShow: NavScreen());
    case ProfilMenuRoute:
      return _getPageRoute(routeName: settings.name, viewToShow: ProfilMenu());
    case EditProfileScreenRoute:
      return _getPageRoute(
          routeName: settings.name, viewToShow: EditProfileScreen());
    case DesignScreenRoute:
      return _getPageRoute(
          routeName: settings.name, viewToShow: DesignScreen());
    case SearchScreenRoute:
      return _getPageRoute(
          routeName: settings.name, viewToShow: SearchScreen());
    case ReglagesScreenRoute:
      return _getPageRoute(
          routeName: settings.name, viewToShow: ReglagesScreen());
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
  }
}

PageRoute _getPageRoute({String routeName, Widget viewToShow}) {
  return MaterialPageRoute(
      settings: RouteSettings(
        name: routeName,
      ),
      builder: (_) => viewToShow);
}
