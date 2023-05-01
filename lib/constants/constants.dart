import 'package:flutter/material.dart';

import 'package:gemu/models/user.dart';

//User global
UserModel? me;

//Navigator global keys
final GlobalKey<NavigatorState> navNonAuthKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> navMainAuthKey = GlobalKey<NavigatorState>();
GlobalKey<NavigatorState>? navHomeAuthKey;
GlobalKey<NavigatorState>? navExploreAuthKey;
GlobalKey<NavigatorState>? navActivitiesAuthKey;
GlobalKey<NavigatorState>? navProfileAuthKey;

//route names for generated routes non auth
const String GetStartedBefore = "GetStartedBefore";
const String GetStarted = "GetStarted";
const String Welcome = "Welcome";
const String Register = "Register";
const String Login = "Login";

//route names for generated routes auth
const String BottomTabNav = "BottomTabNav";
const String Home = "Home";
const String Add = "Add";
const String Explore = "Explore";
const String Activities = "Activities";
const String Profile = "Profile";
const String Games = "Games";
const String GameProfile = "GameProfile";
const String MyProfil = "Profil";
const String PictureEditor = "PictureEditor";
const String PostNewPicture = "PostNewPicture";
const String VideoEditor = "VideoEditor";
const String PostNewVideo = "PostNewVideo";
const String Reglages = "Reglages";
const String PostsFeed = "PostsFeed";
const String Search = "Search";
const String HashtagProfile = "HashtagProfile";
const String UserProfile = "UserProfile";

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
  return TextStyle(
      fontFamily: 'FredokaBold',
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight ?? FontWeight.bold,
      fontStyle: fontStyle ?? FontStyle.normal);
}

textStyleCustomRegular(Color color, double fontSize,
    [FontWeight? fontWeight, FontStyle? fontStyle]) {
  return TextStyle(
      fontFamily: 'FredokaRegular',
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
const cInactiveIconPurpleLightTheme = Color(0xFFC3BCF5);
const cInactiveIconPinkLightTheme = Color(0xFFD6A5C0);
final cInactiveIconPurpleDarkTheme = Color(0xFFC3BCF5).withOpacity(0.7);
final cInactiveIconPinkDarkTheme = Color(0xFFD6A5C0).withOpacity(0.7);
final cRedCancel = Color(0xFF8A1111);
final cGreenConfirm = Color(0xFF78A86B);

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
        titleSmall: textStyleCustomBold(cTextDarkTheme, 14),
        bodyLarge: textStyleCustomRegular(cTextDarkTheme, 14),
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
        titleSmall: textStyleCustomBold(cTextDarkTheme, 14),
        bodyLarge: textStyleCustomRegular(cTextDarkTheme, 14),
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
        titleSmall: textStyleCustomBold(cTextDarkTheme, 14),
        bodyLarge: textStyleCustomRegular(cTextDarkTheme, 14),
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
        titleSmall: textStyleCustomBold(cTextDarkTheme, 14),
        bodyLarge: textStyleCustomRegular(cTextDarkTheme, 14),
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
        titleSmall: textStyleCustomBold(cTextLightTheme, 14),
        bodyLarge: textStyleCustomRegular(cTextLightTheme, 14),
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
        titleSmall: textStyleCustomBold(cTextLightTheme, 14),
        bodyLarge: textStyleCustomRegular(cTextLightTheme, 14),
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
        titleSmall: textStyleCustomBold(cTextLightTheme, 14),
        bodyLarge: textStyleCustomRegular(cTextLightTheme, 14),
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
        titleSmall: textStyleCustomBold(cTextLightTheme, 14),
        bodyLarge: textStyleCustomRegular(cTextLightTheme, 14),
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
