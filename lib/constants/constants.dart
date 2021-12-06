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
const String Welcome = "WelcomeScreen";
const String GetStarted = "GetStartedScreen";
const String Register = "RegisterScreen";
const String Login = "LoginScreen";
const String Navigation = "NavScreen";
const String Home = "HomeScreen";
const String Highlights = "HighlightsScreen";
const String Games = "GamesScreen";
const String MyProfil = "ProfilScreen";
const String AddPost = "AddPostScreen";
