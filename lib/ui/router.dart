import 'package:Gemu/ui/screens/Connection/connection_screen.dart';
import 'package:Gemu/ui/screens/Reglages/edit_email_screen.dart';
import 'package:Gemu/ui/screens/Reglages/edit_password_screen.dart';
import 'package:Gemu/ui/screens/Reglages/edit_user_name_screen.dart';
import 'package:Gemu/ui/screens/Login/login_screen.dart';
import 'package:Gemu/ui/screens/Navigation/nav_screen.dart';
import 'package:Gemu/ui/screens/Reglages/edit_profile_screen.dart';
import 'package:Gemu/ui/screens/Profil/profil_screen.dart';
import 'package:Gemu/ui/screens/Reglages/reglages_screen.dart';
import 'package:Gemu/ui/screens/Register/register_screen.dart';
import 'package:Gemu/ui/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/constants/route_names.dart';
import 'package:Gemu/ui/screens/Welcome/welcome_screen.dart';
import 'package:Gemu/ui/screens/Share/Post/create_post_screen.dart';
import 'package:Gemu/ui/screens/GetStarted/get_started_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case ConnectionScreenRoute:
      return _getPageRoute(
          routeName: settings.name, viewToShow: ConnectionScreen());
    case WelcomeScreenRoute:
      return _getPageRoute(
          routeName: settings.name, viewToShow: WelcomeScreen());
    case LoginScreenRoute:
      return _getPageRoute(routeName: settings.name, viewToShow: LoginScreen());
    case RegisterScreenRoute:
      return _getPageRoute(
          routeName: settings.name, viewToShow: RegisterScreen());
    case RegisterFirstScreenRoute:
      return _getPageRoute(
          routeName: settings.name, viewToShow: RegisterFirstScreen());
    case RegisterSecondScreenRoute:
      return _getPageRoute(
          routeName: settings.name, viewToShow: RegisterSecondScreen());
    case NavScreenRoute:
      return _getPageRoute(routeName: settings.name, viewToShow: NavScreen());
    case ProfilMenuDrawerRoute:
      return _getPageRoute(
          routeName: settings.name, viewToShow: ProfilMenuDrawer());
    case ProfilMenuRoute:
      return _getPageRoute(
          routeName: settings.name, viewToShow: ProfilMenuDrawer());
    case EditProfileScreenRoute:
      return _getPageRoute(
          routeName: settings.name, viewToShow: EditProfileScreen());
    case DesignScreenRoute:
      return _getPageRoute(
          routeName: settings.name, viewToShow: DesignScreen());
    case ReglagesScreenRoute:
      return _getPageRoute(
          routeName: settings.name, viewToShow: ReglagesScreen());
    case EditUserNameScreenRoute:
      return _getPageRoute(
          routeName: settings.name, viewToShow: EditUserNameScreen());
    case EditEmailScreenRoute:
      return _getPageRoute(
          routeName: settings.name, viewToShow: EditEmailScreen());
    case EditPasswordRoute:
      return _getPageRoute(
          routeName: settings.name, viewToShow: EditPasswordScreen());
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

PageRoute _getPageRoute({String routeName, Widget viewToShow}) {
  return MaterialPageRoute(
      settings: RouteSettings(
        name: routeName,
      ),
      builder: (_) => viewToShow);
}
