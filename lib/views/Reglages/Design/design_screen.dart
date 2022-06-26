import 'package:flutter/material.dart';
import 'package:gemu/components/app_bar_custom.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/providers/Theme/theme_provider.dart';

class DesignScreen extends StatefulWidget {
  @override
  _Designviewstate createState() => _Designviewstate();
}

class _Designviewstate extends State<DesignScreen> {
  late SharedPreferences prefs;

  bool isSwitched = false;

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
                          colorChangedPrimary(cPrimaryPink.value, ref);
                          colorChangedAccent(cPrimaryPurple.value, ref);
                          onThemeChanged('ThemeSystem', ref);
                        },
                        child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 400),
                            transitionBuilder: (Widget child,
                                    Animation<double> animation) =>
                                ScaleTransition(child: child, scale: animation),
                            child: _getIconSystem(cPrimaryPink, cPrimaryPurple,
                                theme, primaryColor, accentColor)),
                        shape: CircleBorder(),
                        elevation: 6.0,
                        fillColor: MediaQuery.of(context).platformBrightness ==
                                Brightness.dark
                            ? cBGDarkTheme
                            : cBGLightTheme,
                        padding: EdgeInsets.all(5.0),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text('Pink/Purple'),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    children: [
                      RawMaterialButton(
                        onPressed: () {
                          colorChangedPrimary(cPrimaryPurple.value, ref);
                          colorChangedAccent(cPrimaryPink.value, ref);
                          onThemeChanged('ThemeSystem', ref);
                        },
                        child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 400),
                            transitionBuilder: (Widget child,
                                    Animation<double> animation) =>
                                ScaleTransition(child: child, scale: animation),
                            child: _getIconSystem(cPrimaryPurple, cPrimaryPink,
                                theme, primaryColor, accentColor)),
                        shape: CircleBorder(),
                        elevation: 6.0,
                        fillColor: MediaQuery.of(context).platformBrightness ==
                                Brightness.dark
                            ? cBGDarkTheme
                            : cBGLightTheme,
                        padding: EdgeInsets.all(5.0),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text('Purple/Pink'),
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
                        onPressed: () => onThemeChanged(themeLightPink, ref),
                        child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 400),
                            transitionBuilder: (Widget child,
                                    Animation<double> animation) =>
                                ScaleTransition(child: child, scale: animation),
                            child: _getIcon(theme, lightThemePink)),
                        shape: CircleBorder(),
                        elevation: 6.0,
                        fillColor: lightThemePink.scaffoldBackgroundColor,
                        padding: EdgeInsets.all(5.0),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text('Pink/Purple'),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    children: [
                      RawMaterialButton(
                        onPressed: () => onThemeChanged(themeLightPurple, ref),
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
                      Text('Purple/Pink'),
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
                      onPressed: () => onThemeChanged(themeDarkPink, ref),
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 400),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) =>
                                ScaleTransition(child: child, scale: animation),
                        child: _getIcon(theme, darkThemePink),
                      ),
                      shape: CircleBorder(),
                      elevation: 6.0,
                      fillColor: darkThemePink.scaffoldBackgroundColor,
                      padding: EdgeInsets.all(5.0),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text('Pink/Purple'),
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: [
                    RawMaterialButton(
                      onPressed: () => onThemeChanged(themeDarkPurple, ref),
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
                    Text('Purple/Pink'),
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
    if (value == themeLightPink) {
      ref.read(themeProviderNotifier.notifier).updateTheme(lightThemePink);
    } else if (value == themeLightPurple) {
      ref.read(themeProviderNotifier.notifier).updateTheme(lightThemePurple);
    } else if (value == themeDarkPink) {
      ref.read(themeProviderNotifier.notifier).updateTheme(darkThemePink);
    } else if (value == themeDarkPurple) {
      ref.read(themeProviderNotifier.notifier).updateTheme(darkThemePurple);
    } else {
      ref.read(themeProviderNotifier.notifier).updateTheme(ThemeData());
    }
    prefs.setString(appTheme, value);
  }

  void colorChangedPrimary(int value, WidgetRef ref) async {
    var prefs = await SharedPreferences.getInstance();
    if (value == cPrimaryPink.value) {
      ref
          .read(primaryProviderNotifier.notifier)
          .updatePrimaryColor(cPrimaryPink);
    } else if (value == cPrimaryPurple.value) {
      ref
          .read(primaryProviderNotifier.notifier)
          .updatePrimaryColor(cPrimaryPurple);
    }
    prefs.setInt('color_primary', value);
  }

  void colorChangedAccent(int value, WidgetRef ref) async {
    var prefs = await SharedPreferences.getInstance();
    if (value == cPrimaryPink.value) {
      ref.read(accentProviderNotifier.notifier).updateAccentColor(cPrimaryPink);
    } else if (value == cPrimaryPurple.value) {
      ref
          .read(accentProviderNotifier.notifier)
          .updateAccentColor(cPrimaryPurple);
    }
    prefs.setInt('color_accent', value);
  }
}
