import 'package:flutter/material.dart';
import 'package:gemu/widgets/app_bar_custom.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/providers/theme_provider.dart';

class DesignScreen extends StatefulWidget {
  @override
  _Designviewstate createState() => _Designviewstate();
}

class _Designviewstate extends State<DesignScreen> {
  late SharedPreferences prefs;

  bool isSwitched = false;

  Color darkApp = Color(0xFF1A1C25);
  Color lightApp = Color(0xFFDEE4E7);
  Color orangeApp = Color(0xFFB27D75);
  Color purpleApp = Color(0xFF6E78B1);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBarCustom(context: context, title: 'Design', actions: []),
        body: Consumer(builder: (_, ref, child) {
          final themeNotifier = ref.watch(themeProviderNotifier);
          final primaryColorNotifier = ref.watch(primaryProviderNotifier);
          final accentColorNotifier = ref.watch(accentProviderNotifier);
          return Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: systemTheme(themeNotifier, ref, primaryColorNotifier,
                      accentColorNotifier),
                ),
                Expanded(
                  child: lightThemes(themeNotifier, ref),
                ),
                Expanded(
                  child: darkThemes(themeNotifier, ref),
                )
              ],
            ),
          );
        }));
  }

  Widget systemTheme(
      ThemeData theme, WidgetRef ref, Color primaryColor, Color accentColor) {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Default system colors",
              style: Theme.of(context).textTheme.headline5,
            ),
            Text(
              "Select colors for the default system",
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(
              height: 25.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  child: Column(
                    children: [
                      RawMaterialButton(
                        onPressed: () {
                          colorChangedPrimary(orangeApp.value, ref);
                          colorChangedAccent(purpleApp.value, ref);
                          onThemeChanged('ThemeSystem', ref);
                        },
                        child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 400),
                            transitionBuilder: (Widget child,
                                    Animation<double> animation) =>
                                ScaleTransition(child: child, scale: animation),
                            child: _getIconSystem(orangeApp, purpleApp, theme,
                                primaryColor, accentColor)),
                        shape: CircleBorder(),
                        elevation: 6.0,
                        padding: EdgeInsets.all(5.0),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text('Orange/Purple'),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    children: [
                      RawMaterialButton(
                        onPressed: () {
                          colorChangedPrimary(purpleApp.value, ref);
                          colorChangedAccent(orangeApp.value, ref);
                          onThemeChanged('ThemeSystem', ref);
                        },
                        child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 400),
                            transitionBuilder: (Widget child,
                                    Animation<double> animation) =>
                                ScaleTransition(child: child, scale: animation),
                            child: _getIconSystem(purpleApp, orangeApp, theme,
                                primaryColor, accentColor)),
                        shape: CircleBorder(),
                        elevation: 6.0,
                        padding: EdgeInsets.all(5.0),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text('Purple/Orange'),
                    ],
                  ),
                ),
              ],
            )
          ],
        ));
  }

  Widget lightThemes(ThemeData theme, WidgetRef ref) {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Light Theme Colors",
              style: Theme.of(context).textTheme.headline5,
            ),
            Text(
              "Select colors for the light theme",
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(
              height: 25.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  child: Column(
                    children: [
                      RawMaterialButton(
                        onPressed: () => onThemeChanged('LightOrange', ref),
                        child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 400),
                            transitionBuilder: (Widget child,
                                    Animation<double> animation) =>
                                ScaleTransition(child: child, scale: animation),
                            child: _getIcon(theme, lightThemeOrange)),
                        shape: CircleBorder(),
                        elevation: 6.0,
                        fillColor: lightThemeOrange.scaffoldBackgroundColor,
                        padding: EdgeInsets.all(5.0),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text('Orange/Purple'),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    children: [
                      RawMaterialButton(
                        onPressed: () => onThemeChanged('LightPurple', ref),
                        child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 400),
                            transitionBuilder: (Widget child,
                                    Animation<double> animation) =>
                                ScaleTransition(child: child, scale: animation),
                            child: _getIcon(theme, lightThemePurple)),
                        shape: CircleBorder(),
                        elevation: 6.0,
                        fillColor: lightThemePurple.scaffoldBackgroundColor,
                        padding: EdgeInsets.all(5.0),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text('Purple/Orange'),
                    ],
                  ),
                ),
              ],
            )
          ],
        ));
  }

  Widget darkThemes(ThemeData theme, WidgetRef ref) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Dark Theme Colors",
            style: Theme.of(context).textTheme.headline5,
          ),
          Text(
            "Select colors for the dark theme",
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(
            height: 25.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                child: Column(
                  children: [
                    RawMaterialButton(
                      onPressed: () => onThemeChanged('DarkOrange', ref),
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 400),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) =>
                                ScaleTransition(child: child, scale: animation),
                        child: _getIcon(theme, darkThemeOrange),
                      ),
                      shape: CircleBorder(),
                      elevation: 6.0,
                      fillColor: darkThemeOrange.scaffoldBackgroundColor,
                      padding: EdgeInsets.all(5.0),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text('Orange/Purple'),
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: [
                    RawMaterialButton(
                      onPressed: () => onThemeChanged('DarkPurple', ref),
                      child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 400),
                          transitionBuilder: (Widget child,
                                  Animation<double> animation) =>
                              ScaleTransition(child: child, scale: animation),
                          child: _getIcon(theme, darkThemePurple)),
                      shape: CircleBorder(),
                      elevation: 6.0,
                      fillColor: darkThemePurple.scaffoldBackgroundColor,
                      padding: EdgeInsets.all(5.0),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text('Purple/Orange'),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _getIconSystem(
      Color primaryColor,
      Color accentColor,
      ThemeData themeNotifier,
      Color primaryColorNotifier,
      Color accentColorNotifier) {
    bool selected = (primaryColorNotifier == primaryColor &&
        accentColorNotifier == accentColor &&
        themeNotifier == ThemeData());

    return Container(
      height: 50,
      width: 50,
      key: Key((selected) ? "ON" : "OFF"),
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor,
                accentColor,
              ]),
          borderRadius: BorderRadius.circular(40)),
      child: Icon(
        (selected) ? Icons.done : Icons.close,
        size: 20.0,
      ),
    );
  }

  Widget _getIcon(ThemeData themeNotifier, ThemeData themeData) {
    bool selected = (themeNotifier == themeData);

    return Container(
      height: 50,
      width: 50,
      key: Key((selected) ? "ON" : "OFF"),
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary
              ]),
          borderRadius: BorderRadius.circular(40)),
      child: Icon(
        (selected) ? Icons.done : Icons.close,
        size: 20.0,
      ),
    );
  }

  void onThemeChanged(String value, WidgetRef ref) async {
    var prefs = await SharedPreferences.getInstance();
    if (value == 'LightOrange') {
      ref.read(themeProviderNotifier.notifier).updateTheme(lightThemeOrange);
      //Mise en place de l'overlay des notifications Android
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Color(0xFFDEE4E7)));
    } else if (value == 'LightPurple') {
      ref.read(themeProviderNotifier.notifier).updateTheme(lightThemePurple);
      //Mise en place de l'overlay des notifications Android
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Color(0xFFDEE4E7)));
    } else if (value == 'DarkOrange') {
      ref.read(themeProviderNotifier.notifier).updateTheme(darkThemeOrange);
      //Mise en place de l'overlay des notifications Android
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Color(0xFF1A1C25)));
    } else if (value == 'DarkPurple') {
      ref.read(themeProviderNotifier.notifier).updateTheme(darkThemePurple);
      //Mise en place de l'overlay des notifications Android
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Color(0xFF1A1C25)));
    } else {
      ref.read(themeProviderNotifier.notifier).updateTheme(ThemeData());
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent));
    }
    prefs.setString(appTheme, value);
  }

  void colorChangedPrimary(int value, WidgetRef ref) async {
    var prefs = await SharedPreferences.getInstance();
    if (value == orangeApp.value) {
      ref.read(primaryProviderNotifier.notifier).updatePrimaryColor(orangeApp);
    } else if (value == purpleApp.value) {
      ref.read(primaryProviderNotifier.notifier).updatePrimaryColor(purpleApp);
    }
    prefs.setInt('color_primary', value);
  }

  void colorChangedAccent(int value, WidgetRef ref) async {
    var prefs = await SharedPreferences.getInstance();
    if (value == orangeApp.value) {
      ref.read(accentProviderNotifier.notifier).updateAccentColor(orangeApp);
    } else if (value == purpleApp.value) {
      ref.read(accentProviderNotifier.notifier).updateAccentColor(purpleApp);
    }
    prefs.setInt('color_accent', value);
  }
}
