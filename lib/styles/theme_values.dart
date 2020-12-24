import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

Color myColor;

void getColor() async {
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  prefs.then((value) {
    myColor = Color(value.getInt('color_primary') ?? Colors.green.value);
  });
}

/// --- Dark Orange Theme ---
final darkThemeOrange = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Color(0xFFDC804F),
  accentColor: Color(0xFF7C79A5),
  secondaryHeaderColor: Colors.black,
  scaffoldBackgroundColor: Colors.grey[1000],
  splashColor: Colors.grey[1000],
  iconTheme: IconThemeData(
    color: Colors.black,
  ),
  primaryTextTheme: TextTheme(
    headline6: TextStyle(color: Colors.black),
    bodyText1: TextStyle(color: Colors.black),
    bodyText2: TextStyle(color: Colors.black),
  ),
  appBarTheme: AppBarTheme(
    color: Colors.black45,
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
  ),
  cardTheme: CardTheme(color: Colors.black),
  cardColor: Colors.black45,
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFDC804F),
  ),
  bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.black),
  bottomAppBarTheme: BottomAppBarTheme(
    color: Colors.black45,
  ),
  tabBarTheme: TabBarTheme(
    unselectedLabelColor: Colors.grey[400],
    labelColor: Color(0xFFDC804F),
  ),
  indicatorColor: Color(0xFFDC804F),
  //canvasColor: Colors.black12.withOpacity(0.4)
);

/// --- Dark Purple Theme ---
final darkThemePurple = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Color(0xFF5959A3),
  accentColor: Color(0xFFDC804F),
  secondaryHeaderColor: Colors.black,
  scaffoldBackgroundColor: Colors.grey[1000],
  splashColor: Colors.grey[1000],
  iconTheme: IconThemeData(
    color: Colors.black,
  ),
  primaryTextTheme: TextTheme(
    headline6: TextStyle(color: Colors.black),
    bodyText1: TextStyle(color: Colors.black),
    bodyText2: TextStyle(color: Colors.black),
  ),
  appBarTheme: AppBarTheme(
    color: Colors.black45,
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
  ),
  cardTheme: CardTheme(color: Colors.black),
  cardColor: Colors.black45,
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF5959A3),
  ),
  bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.black),
  bottomAppBarTheme: BottomAppBarTheme(
    color: Colors.black45,
  ),
  tabBarTheme: TabBarTheme(
    unselectedLabelColor: Colors.grey[400],
    labelColor: Color(0xFF5959A3),
  ),
  indicatorColor: Color(0xFF5959A3),
  //canvasColor: Colors.black12.withOpacity(0.4)
);

/// --- Light Orange Theme ---
final lightThemeOrange = ThemeData(
  brightness: Brightness.light,
  primaryColor: Color(0xFFDC804F),
  accentColor: Color(0xFF5959A3),
  secondaryHeaderColor: Colors.white,
  scaffoldBackgroundColor: Colors.grey[200],
  splashColor: Colors.grey[200],
  iconTheme: IconThemeData(
    color: Colors.black,
  ),
  primaryTextTheme: TextTheme(
    headline6: TextStyle(color: Colors.black),
    bodyText1: TextStyle(color: Colors.black),
    bodyText2: TextStyle(color: Colors.black),
  ),
  appBarTheme: AppBarTheme(
    color: Colors.white,
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
  ),
  cardTheme: CardTheme(color: Colors.white),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFDC804F),
  ),
  bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.white),
  bottomAppBarTheme: BottomAppBarTheme(
    color: Colors.white,
  ),
  tabBarTheme: TabBarTheme(
    unselectedLabelColor: Colors.black,
    labelColor: Color(0xFFDC804F),
  ),
  indicatorColor: Color(0xFFDC804F),
  //canvasColor: Colors.white12.withOpacity(0.4)
);

/// --- Light Purple Theme ---
final lightThemePurple = ThemeData(
  brightness: Brightness.light,
  primaryColor: Color(0xFF5959A3),
  accentColor: Color(0xFFDC804F),
  secondaryHeaderColor: Colors.white,
  scaffoldBackgroundColor: Colors.grey[200],
  splashColor: Colors.grey[200],
  iconTheme: IconThemeData(
    color: Colors.black,
  ),
  primaryTextTheme: TextTheme(
    headline6: TextStyle(color: Colors.black),
    bodyText1: TextStyle(color: Colors.black),
    bodyText2: TextStyle(color: Colors.black),
  ),
  appBarTheme: AppBarTheme(
    color: Colors.white,
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
  ),
  cardTheme: CardTheme(color: Colors.white),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF5959A3),
  ),
  bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.white),
  bottomAppBarTheme: BottomAppBarTheme(
    color: Colors.white,
  ),
  tabBarTheme: TabBarTheme(
    unselectedLabelColor: Colors.black,
    labelColor: Color(0xFF5959A3),
  ),
  indicatorColor: Color(0xFF5959A3),
  //canvasColor: Colors.white12.withOpacity(0.4)
);

ThemeData themeCustomDark = ThemeData(
  brightness: Brightness.dark, //canvasColor: Colors.black12.withOpacity(0.4)
);

ThemeData themeCustomLight = ThemeData(
  brightness: Brightness.light, //canvasColor: Colors.white12.withOpacity(0.4)
);
