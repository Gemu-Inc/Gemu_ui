import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gemu/models/user.dart';

//User global
UserModel? me;

//Style texte
mystyle(double size, [Color? color, FontWeight fw = FontWeight.w700]) {
  return GoogleFonts.montserrat(fontSize: size, color: color, fontWeight: fw);
}

//colors app
const cOrange = Color(0xFFB27D75);
const cMauve = Color(0xFF6E78B1); 

//Themes
final String appTheme = "Theme";

/// --- Dark theme system orange ---
final darkThemeSystemOrange = ThemeData(
    colorScheme: ColorScheme.dark(
      primary: cOrange,
      secondary: cMauve,
    ),
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF1A1C25),
    primaryColor: cOrange,
    canvasColor: Color(0xFF222831),
    shadowColor: Color(0xFF121212),
    iconTheme: IconThemeData(
      color: Colors.white60,
    ),
    appBarTheme: AppBarTheme(
      color: Colors.transparent,
      titleTextStyle: TextStyle(
          color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: IconThemeData(size: 26),
        selectedLabelStyle: TextStyle(fontSize: 14.0),
        selectedItemColor: cOrange,
        unselectedIconTheme: IconThemeData(size: 23),
        unselectedLabelStyle: TextStyle(fontSize: 12.0),
        unselectedItemColor: Colors.white60));

/// --- Dark theme system purple
final darkThemeSystemPurple = ThemeData(
    colorScheme: ColorScheme.dark(
      primary: cMauve,
      secondary: cOrange,
    ),
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF1A1C25),
    primaryColor: cMauve,
    canvasColor: Color(0xFF222831),
    shadowColor: Color(0xFF121212),
    iconTheme: IconThemeData(
      color: Colors.white60,
    ),
    appBarTheme: AppBarTheme(
      color: Colors.transparent,
      titleTextStyle: TextStyle(
          color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: IconThemeData(size: 26),
        selectedLabelStyle: TextStyle(fontSize: 14.0),
        selectedItemColor: cOrange,
        unselectedIconTheme: IconThemeData(size: 23),
        unselectedLabelStyle: TextStyle(fontSize: 12.0),
        unselectedItemColor: Colors.white60));

/// --- Dark Orange Theme ---
final darkThemeOrange = ThemeData(
    colorScheme: ColorScheme.dark(
      primary: cOrange,
      secondary: cMauve,
    ),
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF1A1C25),
    primaryColor: cOrange,
    canvasColor: Color(0xFF222831),
    shadowColor: Color(0xFF121212),
    iconTheme: IconThemeData(
      color: Colors.white60,
    ),
    appBarTheme: AppBarTheme(
      color: Colors.transparent,
      titleTextStyle: TextStyle(
          color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: IconThemeData(size: 26),
        selectedLabelStyle: TextStyle(fontSize: 14.0),
        selectedItemColor: Color(0xFFB27D75),
        unselectedIconTheme: IconThemeData(size: 23),
        unselectedLabelStyle: TextStyle(fontSize: 12.0),
        unselectedItemColor: Colors.white60));

/// --- Dark Purple Theme ---
final darkThemePurple = ThemeData(
    colorScheme: ColorScheme.dark(
      primary: cMauve,
      secondary: cOrange,
    ),
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF1A1C25),
    primaryColor: cMauve,
    canvasColor: Color(0xFF222831),
    shadowColor: Color(0xFF121212),
    iconTheme: IconThemeData(
      color: Colors.white60,
    ),
    appBarTheme: AppBarTheme(
      color: Colors.transparent,
      titleTextStyle: TextStyle(
          color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: IconThemeData(size: 26),
        selectedLabelStyle: TextStyle(fontSize: 14.0),
        selectedItemColor: Color(0xFF6E78B1),
        unselectedIconTheme: IconThemeData(size: 23),
        unselectedLabelStyle: TextStyle(fontSize: 12.0),
        unselectedItemColor: Colors.white60));

/// --- Light theme system orange ---
final lightThemeSystemOrange = ThemeData(
    colorScheme: ColorScheme.light(
      primary: cOrange,
      secondary: cMauve,
    ),
    brightness: Brightness.light,
    scaffoldBackgroundColor: Color(0xFFDEE4E7),
    primaryColor: cOrange,
    canvasColor: Color(0xFFD3D3D3),
    shadowColor: Color(0xFFBDBDBD),
    iconTheme: IconThemeData(
      color: Colors.black45,
    ),
    appBarTheme: AppBarTheme(
      color: Colors.transparent,
      titleTextStyle: TextStyle(
          color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: IconThemeData(size: 26),
        selectedLabelStyle: TextStyle(fontSize: 14.0),
        selectedItemColor: cOrange,
        unselectedIconTheme: IconThemeData(size: 23),
        unselectedLabelStyle: TextStyle(fontSize: 12.0),
        unselectedItemColor: Colors.black45));

/// --- Light theme system purple ---
final lightThemeSystemPurple = ThemeData(
    colorScheme: ColorScheme.light(
      primary: cOrange,
      secondary: cMauve,
    ),
    brightness: Brightness.light,
    scaffoldBackgroundColor: Color(0xFFDEE4E7),
    primaryColor: cMauve,
    canvasColor: Color(0xFFD3D3D3),
    shadowColor: Color(0xFFBDBDBD),
    iconTheme: IconThemeData(
      color: Colors.black45,
    ),
    appBarTheme: AppBarTheme(
      color: Colors.transparent,
      titleTextStyle: TextStyle(
          color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: IconThemeData(size: 26),
        selectedLabelStyle: TextStyle(fontSize: 14.0),
        selectedItemColor: cOrange,
        unselectedIconTheme: IconThemeData(size: 23),
        unselectedLabelStyle: TextStyle(fontSize: 12.0),
        unselectedItemColor: Colors.black45));

/// --- Light Orange Theme ---
final lightThemeOrange = ThemeData(
    colorScheme: ColorScheme.light(
      primary: cOrange,
      secondary: cMauve,
    ),
    brightness: Brightness.light,
    scaffoldBackgroundColor: Color(0xFFDEE4E7),
    primaryColor: cOrange,
    canvasColor: Color(0xFFD3D3D3),
    shadowColor: Color(0xFFEEEEEE),
    iconTheme: IconThemeData(
      color: Colors.black45,
    ),
    appBarTheme: AppBarTheme(
      color: Colors.transparent,
      titleTextStyle: TextStyle(
          color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(
        color: Colors.black45,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: IconThemeData(size: 26),
        selectedLabelStyle: TextStyle(fontSize: 14.0),
        selectedItemColor: Color(0xFFB27D75),
        unselectedIconTheme: IconThemeData(size: 23),
        unselectedLabelStyle: TextStyle(fontSize: 12.0),
        unselectedItemColor: Colors.black45));

/// --- Light Purple Theme ---
final lightThemePurple = ThemeData(
    colorScheme: ColorScheme.light(
      primary: cMauve,
      secondary: cOrange,
    ),
    brightness: Brightness.light,
    scaffoldBackgroundColor: Color(0xFFDEE4E7),
    primaryColor: cMauve,
    canvasColor: Color(0xFFD3D3D3),
    shadowColor: Color(0xFFBDBDBD),
    iconTheme: IconThemeData(
      color: Colors.black45,
    ),
    appBarTheme: AppBarTheme(
      color: Colors.transparent,
      titleTextStyle: TextStyle(
          color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: IconThemeData(size: 26),
        selectedLabelStyle: TextStyle(fontSize: 14.0),
        selectedItemColor: Color(0xFF6E78B1),
        unselectedIconTheme: IconThemeData(size: 23),
        unselectedLabelStyle: TextStyle(fontSize: 12.0),
        unselectedItemColor: Colors.black45));

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
