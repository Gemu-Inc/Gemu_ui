import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gemu/models/user.dart';

//User global
UserModel? me;

//Style texte
mystyle(double size, [Color? color, FontWeight fw = FontWeight.w700]) {
  return GoogleFonts.montserrat(fontSize: size, color: color, fontWeight: fw);
}

//Theme au niveau du shared pref
final String appTheme = "Theme";
final List<String> appThemesColors = [
  "LightOrange",
  "LightPurple",
  "DarkOrange",
  "DarkPurple",
  "ThemeCustomSystem",
];

//routes names for generated routes
const String ConnectionScreenRoute = "ConnectionScreen";
const String GetStartedRoute = "GetStartedScreen";
const String WelcomeScreenRoute = "WelcomeScreen";
const String NavScreenRoute = "NavScreen";
const String RegisterScreenRoute = "RegisterScreen";
const String RegisterFirstScreenRoute = "RegisterFirstScreen";
const String RegisterSecondScreenRoute = "RegisterSecondScreen";
const String LoginScreenRoute = "LoginScreen";
const String ProfilMenuDrawerRoute = "ProfilMenuDrawer";
const String ProfilMenuRoute = "ProfilMenu";
const String EditProfileScreenRoute = "EditProfileScreen";
const String DesignScreenRoute = "DesignScreen";
const String SearchScreenRoute = "SearchScreen";
const String ReglagesScreenRoute = "ReglagesScreen";
const String EditUserNameScreenRoute = "EditUserNameScreen";
const String EditEmailScreenRoute = "EditEmailScreen";
const String EditPasswordRoute = "EditPasswordScreen";
const String CreatePostRoute = "CreatePostScreen";
