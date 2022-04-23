import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gemu/models/user.dart';

//User global
UserModel? me;

//Navigator global keys
final GlobalKey<NavigatorState> mainKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> navNonAuthKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> navAuthKey = GlobalKey<NavigatorState>();

//route names for generated routes non auth
const String GetStartedBefore = "GetStartedBefore";
const String GetStarted = "GetStarted";
const String Welcome = "Welcome";
const String Register = "Register";
const String Login = "Login";

//route names for generated routes auth
const String Navigation = "Nav";
const String Home = "Home";
const String Highlights = "Highlights";
const String Games = "Games";
const String MyProfil = "Profil";
const String AddPost = "AddPost";

//Themes
const appTheme = "Theme";
const themeSystem = "ThemeSystem";
const themeDarkPink = "ThemeDarkPink";
const themeDarkPurple = "ThemeDarkPurple";
const themeLightPink = "ThemeLightPink";
const themeLightPurple = "ThemeLightPurple";

//Theme text
textStyleCustomBold(Color color, double fontSize,
    [FontWeight? fontWeight, FontStyle? fontStyle]) {
  return GoogleFonts.fredokaOne(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight ?? FontWeight.bold,
      fontStyle: fontStyle ?? FontStyle.normal);
}

textStyleCustomRegular(Color color, double fontSize,
    [FontWeight? fontWeight, FontStyle? fontStyle]) {
  return GoogleFonts.nunito(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight ?? FontWeight.w500,
      fontStyle: fontStyle ?? FontStyle.normal);
}

// --- Colors palette ---
const cPrimaryPurple = Color(0xFF6957E7);
const cSecondaryPurple = Color(0xFF593C98);
const cPrimaryPink = Color(0xFFAD4B81);
const cSecondaryPink = Color(0xFFAF4259);
const cBGDarkTheme = Color(0xFF22213C);
const cBGLightTheme = Color(0xFFE0EFFF);
const cShadowDarkTheme = Color(0xFF1C1E2B);
const cShadowLightTheme = Color(0xFFD0E7FF);
const cContainerDarkTheme = Color(0xFF1E1F31);
const cContainerLightTheme = Color(0xFFD0E7FF);
const cIconDarkTheme = Colors.white;
const cIconLightTheme = Colors.black;
const cTextDarkTheme = Colors.white;
const cTextLightTheme = Colors.black;

//Lists colors dayMood
List<Color> lightBgColors = [
  cSecondaryPink,
  cPrimaryPink,
  cPrimaryPurple,
  cSecondaryPurple,
];
List<Color> darkBgColors = [
  cSecondaryPurple,
  cPrimaryPurple,
  cPrimaryPink,
  cSecondaryPink,
];

/// --- Dark theme system pink ---
final darkThemeSystemPink = ThemeData(
    colorScheme: ColorScheme.dark(
      primary: cPrimaryPink,
      secondary: cPrimaryPurple,
    ),
    brightness: Brightness.dark,
    scaffoldBackgroundColor: cBGDarkTheme,
    canvasColor: cContainerDarkTheme,
    shadowColor: cShadowDarkTheme,
    iconTheme: IconThemeData(
      color: cIconDarkTheme,
    ),
    textTheme: TextTheme(
        titleLarge: textStyleCustomBold(cTextDarkTheme, 20),
        titleSmall: textStyleCustomBold(cTextDarkTheme, 15),
        bodyLarge: textStyleCustomRegular(cTextDarkTheme, 15),
        bodySmall: textStyleCustomRegular(cTextDarkTheme, 12)),
    appBarTheme: AppBarTheme(
      color: Colors.transparent,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: IconThemeData(size: 26),
        selectedLabelStyle: TextStyle(fontSize: 14.0),
        selectedItemColor: cPrimaryPink,
        unselectedIconTheme: IconThemeData(size: 23),
        unselectedLabelStyle: TextStyle(fontSize: 12.0),
        unselectedItemColor: Colors.white60));

/// --- Dark theme system purple
final darkThemeSystemPurple = ThemeData(
    colorScheme: ColorScheme.dark(
      primary: cPrimaryPurple,
      secondary: cPrimaryPink,
    ),
    brightness: Brightness.dark,
    scaffoldBackgroundColor: cBGDarkTheme,
    canvasColor: cContainerDarkTheme,
    shadowColor: cShadowDarkTheme,
    iconTheme: IconThemeData(
      color: cIconDarkTheme,
    ),
    textTheme: TextTheme(
        titleLarge: textStyleCustomBold(cTextDarkTheme, 20),
        titleSmall: textStyleCustomBold(cTextDarkTheme, 15),
        bodyLarge: textStyleCustomRegular(cTextDarkTheme, 15),
        bodySmall: textStyleCustomRegular(cTextDarkTheme, 12)),
    appBarTheme: AppBarTheme(
      color: Colors.transparent,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: IconThemeData(size: 26),
        selectedLabelStyle: TextStyle(fontSize: 14.0),
        selectedItemColor: cPrimaryPurple,
        unselectedIconTheme: IconThemeData(size: 23),
        unselectedLabelStyle: TextStyle(fontSize: 12.0),
        unselectedItemColor: Colors.white60));

/// --- Dark Pink Theme ---
final darkThemePink = ThemeData(
    colorScheme: ColorScheme.dark(
      primary: cPrimaryPink,
      secondary: cPrimaryPurple,
    ),
    brightness: Brightness.dark,
    scaffoldBackgroundColor: cBGDarkTheme,
    canvasColor: cContainerDarkTheme,
    shadowColor: cShadowDarkTheme,
    iconTheme: IconThemeData(
      color: cIconDarkTheme,
    ),
    textTheme: TextTheme(
        titleLarge: textStyleCustomBold(cTextDarkTheme, 20),
        titleSmall: textStyleCustomBold(cTextDarkTheme, 15),
        bodyLarge: textStyleCustomRegular(cTextDarkTheme, 15),
        bodySmall: textStyleCustomRegular(cTextDarkTheme, 12)),
    appBarTheme: AppBarTheme(
      color: Colors.transparent,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: IconThemeData(size: 26),
        selectedLabelStyle: TextStyle(fontSize: 14.0),
        selectedItemColor: cPrimaryPink,
        unselectedIconTheme: IconThemeData(size: 23),
        unselectedLabelStyle: TextStyle(fontSize: 12.0),
        unselectedItemColor: Colors.white60));

/// --- Dark Purple Theme ---
final darkThemePurple = ThemeData(
    colorScheme: ColorScheme.dark(
      primary: cPrimaryPurple,
      secondary: cPrimaryPink,
    ),
    brightness: Brightness.dark,
    scaffoldBackgroundColor: cBGDarkTheme,
    canvasColor: cContainerDarkTheme,
    shadowColor: cShadowDarkTheme,
    iconTheme: IconThemeData(
      color: cIconDarkTheme,
    ),
    textTheme: TextTheme(
        titleLarge: textStyleCustomBold(cTextDarkTheme, 20),
        titleSmall: textStyleCustomBold(cTextDarkTheme, 15),
        bodyLarge: textStyleCustomRegular(cTextDarkTheme, 15),
        bodySmall: textStyleCustomRegular(cTextDarkTheme, 12)),
    appBarTheme: AppBarTheme(
      color: Colors.transparent,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: IconThemeData(size: 26),
        selectedLabelStyle: TextStyle(fontSize: 14.0),
        selectedItemColor: cPrimaryPurple,
        unselectedIconTheme: IconThemeData(size: 23),
        unselectedLabelStyle: TextStyle(fontSize: 12.0),
        unselectedItemColor: Colors.white60));

/// --- Light theme system pink ---
final lightThemeSystemPink = ThemeData(
    colorScheme: ColorScheme.light(
      primary: cPrimaryPink,
      secondary: cPrimaryPurple,
    ),
    brightness: Brightness.light,
    scaffoldBackgroundColor: cBGLightTheme,
    canvasColor: cContainerLightTheme,
    shadowColor: cShadowLightTheme,
    iconTheme: IconThemeData(
      color: cIconLightTheme,
    ),
    textTheme: TextTheme(
        titleLarge: textStyleCustomBold(cTextLightTheme, 20),
        titleSmall: textStyleCustomBold(cTextLightTheme, 15),
        bodyLarge: textStyleCustomRegular(cTextLightTheme, 15),
        bodySmall: textStyleCustomRegular(cTextLightTheme, 12)),
    appBarTheme: AppBarTheme(
      color: Colors.transparent,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: IconThemeData(size: 26),
        selectedLabelStyle: TextStyle(fontSize: 14.0),
        selectedItemColor: cPrimaryPink,
        unselectedIconTheme: IconThemeData(size: 23),
        unselectedLabelStyle: TextStyle(fontSize: 12.0),
        unselectedItemColor: Colors.black45));

/// --- Light theme system purple ---
final lightThemeSystemPurple = ThemeData(
    colorScheme: ColorScheme.light(
      primary: cPrimaryPurple,
      secondary: cPrimaryPink,
    ),
    brightness: Brightness.light,
    scaffoldBackgroundColor: cBGLightTheme,
    canvasColor: cContainerLightTheme,
    shadowColor: cShadowLightTheme,
    iconTheme: IconThemeData(
      color: cIconLightTheme,
    ),
    textTheme: TextTheme(
        titleLarge: textStyleCustomBold(cTextLightTheme, 20),
        titleSmall: textStyleCustomBold(cTextLightTheme, 15),
        bodyLarge: textStyleCustomRegular(cTextLightTheme, 15),
        bodySmall: textStyleCustomRegular(cTextLightTheme, 12)),
    appBarTheme: AppBarTheme(
      color: Colors.transparent,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: IconThemeData(size: 26),
        selectedLabelStyle: TextStyle(fontSize: 14.0),
        selectedItemColor: cPrimaryPurple,
        unselectedIconTheme: IconThemeData(size: 23),
        unselectedLabelStyle: TextStyle(fontSize: 12.0),
        unselectedItemColor: Colors.black45));

/// --- Light Pink Theme ---
final lightThemePink = ThemeData(
    colorScheme: ColorScheme.light(
      primary: cPrimaryPink,
      secondary: cPrimaryPurple,
    ),
    brightness: Brightness.light,
    scaffoldBackgroundColor: cBGLightTheme,
    canvasColor: cContainerLightTheme,
    shadowColor: cShadowLightTheme,
    iconTheme: IconThemeData(
      color: cIconLightTheme,
    ),
    textTheme: TextTheme(
        titleLarge: textStyleCustomBold(cTextLightTheme, 20),
        titleSmall: textStyleCustomBold(cTextLightTheme, 15),
        bodyLarge: textStyleCustomRegular(cTextLightTheme, 15),
        bodySmall: textStyleCustomRegular(cTextLightTheme, 12)),
    appBarTheme: AppBarTheme(
      color: Colors.transparent,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: IconThemeData(size: 26),
        selectedLabelStyle: TextStyle(fontSize: 14.0),
        selectedItemColor: cPrimaryPink,
        unselectedIconTheme: IconThemeData(size: 23),
        unselectedLabelStyle: TextStyle(fontSize: 12.0),
        unselectedItemColor: Colors.black45));

/// --- Light Purple Theme ---
final lightThemePurple = ThemeData(
    colorScheme: ColorScheme.light(
      primary: cPrimaryPurple,
      secondary: cPrimaryPink,
    ),
    brightness: Brightness.light,
    scaffoldBackgroundColor: cBGLightTheme,
    canvasColor: cContainerLightTheme,
    shadowColor: cShadowLightTheme,
    iconTheme: IconThemeData(
      color: cIconLightTheme,
    ),
    textTheme: TextTheme(
        titleLarge: textStyleCustomBold(cTextLightTheme, 20),
        titleSmall: textStyleCustomBold(cTextLightTheme, 15),
        bodyLarge: textStyleCustomRegular(cTextLightTheme, 15),
        bodySmall: textStyleCustomRegular(cTextLightTheme, 12)),
    appBarTheme: AppBarTheme(
      color: Colors.transparent,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: IconThemeData(size: 26),
        selectedLabelStyle: TextStyle(fontSize: 14.0),
        selectedItemColor: cPrimaryPurple,
        unselectedIconTheme: IconThemeData(size: 23),
        unselectedLabelStyle: TextStyle(fontSize: 12.0),
        unselectedItemColor: Colors.black45));
