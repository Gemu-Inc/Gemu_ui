import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

Color? myColor;

void getColor() async {
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  prefs.then((value) {
    myColor = Color(value.getInt('color_primary') ?? Colors.green.value);
  });
}

/// --- Dark Orange Theme ---
final darkThemeOrange = ThemeData(
    colorScheme: ColorScheme.dark(
      primary: Color(0xFFB27D75),
      secondary: Color(0xFF6E78B1),
    ),
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF1A1C25),
    primaryColor: Color(0xFFB27D75),
    //accentColor: Color(0xFF6E78B1),
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
      primary: Color(0xFF6E78B1),
      secondary: Color(0xFFB27D75),
    ),
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF1A1C25),
    primaryColor: Color(0xFF6E78B1),
    //accentColor: Color(0xFFB27D75),
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

/// --- Light Orange Theme ---
final lightThemeOrange = ThemeData(
    colorScheme: ColorScheme.light(
      primary: Color(0xFFB27D75),
      secondary: Color(0xFF6E78B1),
    ),
    brightness: Brightness.light,
    scaffoldBackgroundColor: Color(0xFFDEE4E7),
    primaryColor: Color(0xFFB27D75),
    //accentColor: Color(0xFF6E78B1),
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
      primary: Color(0xFF6E78B1),
      secondary: Color(0xFFB27D75),
    ),
    brightness: Brightness.light,
    scaffoldBackgroundColor: Color(0xFFDEE4E7),
    primaryColor: Color(0xFF6E78B1),
    //accentColor: Color(0xFFB27D75),
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
