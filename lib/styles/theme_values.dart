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
  scaffoldBackgroundColor: Color(0xFF1A1C25),
  primaryColor: Color(0xFFB27D75),
  accentColor: Color(0xFF6E78B1),
  canvasColor: Color(0xFF222831),
  shadowColor: Color(0xFF121212),
  iconTheme: IconThemeData(
    color: Colors.white60,
  ),
  appBarTheme: AppBarTheme(
    color: Colors.transparent,
    textTheme: TextTheme(
        headline6: TextStyle(
            color: Colors.white60, fontSize: 18, fontWeight: FontWeight.bold)),
    iconTheme: IconThemeData(
      color: Colors.white60,
    ),
  ),
);

/// --- Dark Purple Theme ---
final darkThemePurple = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Color(0xFF1A1C25),
  primaryColor: Color(0xFF6E78B1),
  accentColor: Color(0xFFB27D75),
  canvasColor: Color(0xFF222831),
  shadowColor: Color(0xFF121212),
  iconTheme: IconThemeData(
    color: Colors.white60,
  ),
  appBarTheme: AppBarTheme(
    color: Colors.transparent,
    textTheme: TextTheme(
        headline6: TextStyle(
            color: Colors.white60, fontSize: 18, fontWeight: FontWeight.bold)),
    iconTheme: IconThemeData(
      color: Colors.white60,
    ),
  ),
);

/// --- Light Orange Theme ---
final lightThemeOrange = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Color(0xFFDEE4E7),
  primaryColor: Color(0xFFB27D75),
  accentColor: Color(0xFF6E78B1),
  canvasColor: Color(0xFFD3D3D3),
  shadowColor: Color(0xFFEEEEEE),
  iconTheme: IconThemeData(
    color: Colors.black45,
  ),
  appBarTheme: AppBarTheme(
    color: Colors.transparent,
    textTheme: TextTheme(
        headline6: TextStyle(
            color: Colors.black45, fontSize: 18, fontWeight: FontWeight.bold)),
    iconTheme: IconThemeData(
      color: Colors.black45,
    ),
  ),
);

/// --- Light Purple Theme ---
final lightThemePurple = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Color(0xFFDEE4E7),
  primaryColor: Color(0xFF6E78B1),
  accentColor: Color(0xFFB27D75),
  canvasColor: Color(0xFFD3D3D3),
  shadowColor: Color(0xFFBDBDBD),
  iconTheme: IconThemeData(
    color: Colors.black45,
  ),
  appBarTheme: AppBarTheme(
    color: Colors.transparent,
    textTheme: TextTheme(
        headline6: TextStyle(
            color: Colors.black45, fontSize: 18, fontWeight: FontWeight.bold)),
    iconTheme: IconThemeData(
      color: Colors.black45,
    ),
  ),
);

ThemeData themeCustomDark = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Color(0xFF1A1C25),
  canvasColor: Color(0xFF222831),
  shadowColor: Color(0xFF121212),
  iconTheme: IconThemeData(
    color: Colors.white60,
  ),
  appBarTheme: AppBarTheme(
    color: Colors.transparent,
    textTheme: TextTheme(
        headline6: TextStyle(
            color: Colors.white60, fontSize: 18, fontWeight: FontWeight.bold)),
    iconTheme: IconThemeData(
      color: Colors.white60,
    ),
  ),
);

ThemeData themeCustomLight = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Color(0xFFDEE4E7),
    canvasColor: Color(0xFFD3D3D3),
    shadowColor: Color(0xFFBDBDBD),
    iconTheme: IconThemeData(
      color: Colors.black45,
    ),
    appBarTheme: AppBarTheme(
      color: Colors.transparent,
      textTheme: TextTheme(
          headline6: TextStyle(
              color: Colors.black45,
              fontSize: 18,
              fontWeight: FontWeight.bold)),
      iconTheme: IconThemeData(
        color: Colors.black45,
      ),
    ));
