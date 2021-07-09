import 'package:flutter/material.dart';
import 'package:gemu/ui/widgets/app_bar_custom.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'package:gemu/ui/constants/app_constants.dart';
import 'package:gemu/ui/screens/Reglages/Design/theme_notifier.dart';
import 'package:gemu/ui/screens/Reglages/Design/theme_values.dart';

class DesignScreen extends StatefulWidget {
  @override
  _DesignScreenState createState() => _DesignScreenState();
}

class _DesignScreenState extends State<DesignScreen> {
  int selectedPosition = 0;
  List themes = Constants.themes;
  late SharedPreferences prefs;
  late ThemeNotifier themeNotifier;
  bool isSwitched = false;
  bool createTheme = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _getSavedTheme();
    });
  }

  _getSavedTheme() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedPosition = themes
          .indexOf(prefs.getString(Constants.appTheme) ?? 'darkThemeOrange');
    });
  }

  @override
  Widget build(BuildContext context) {
    themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBarCustom(context: context, title: 'Design', actions: []),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: lightThemes(),
            ),
            Expanded(
              child: darkThemes(),
            )
          ],
        ));
  }

  Widget lightThemes() {
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
              "Select your default theme color",
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
                        onPressed: () => _updateState(0),
                        child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 400),
                            transitionBuilder: (Widget child,
                                    Animation<double> animation) =>
                                ScaleTransition(child: child, scale: animation),
                            child: _getIcon(themeNotifier, lightThemeOrange)),
                        shape: CircleBorder(),
                        elevation: 2.0,
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
                        onPressed: () => _updateState(1),
                        child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 400),
                            transitionBuilder: (Widget child,
                                    Animation<double> animation) =>
                                ScaleTransition(child: child, scale: animation),
                            child: _getIcon(themeNotifier, lightThemePurple)),
                        shape: CircleBorder(),
                        elevation: 2.0,
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

  Widget darkThemes() {
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
            "Select your default theme color",
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
                      onPressed: () => _updateState(2),
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 400),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) =>
                                ScaleTransition(child: child, scale: animation),
                        child: _getIcon(themeNotifier, darkThemeOrange),
                      ),
                      shape: CircleBorder(),
                      elevation: 2.0,
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
                      onPressed: () => _updateState(3),
                      child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 400),
                          transitionBuilder: (Widget child,
                                  Animation<double> animation) =>
                              ScaleTransition(child: child, scale: animation),
                          child: _getIcon(themeNotifier, darkThemePurple)),
                      shape: CircleBorder(),
                      elevation: 2.0,
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

  Widget _getIcon(ThemeNotifier themeNotifier, ThemeData themeData) {
    bool selected = (themeNotifier.getTheme() == themeData);

    return Container(
      height: 50,
      width: 50,
      key: Key((selected) ? "ON" : "OFF"),
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                themeData.primaryColor,
                themeData.accentColor,
              ]),
          borderRadius: BorderRadius.circular(40)),
      child: Icon(
        (selected) ? Icons.done : Icons.close,
        size: 20.0,
      ),
    );
  }

  _updateState(int position) {
    setState(() {
      selectedPosition = position;
    });
    onThemeChanged(themes[position]);
  }

  void onThemeChanged(String value) async {
    var prefs = await SharedPreferences.getInstance();
    if (value == 'LightOrange') {
      themeNotifier.setTheme(lightThemeOrange);
    } else if (value == 'LightPurple') {
      themeNotifier.setTheme(lightThemePurple);
    } else if (value == 'DarkOrange') {
      themeNotifier.setTheme(darkThemeOrange);
    } else if (value == 'DarkPurple') {
      themeNotifier.setTheme(darkThemePurple);
    } else if (value == 'ThemeCustomLight') {
      themeNotifier.setTheme(themeCustomLight);
    } else if (value == 'ThemeCustomDark') {
      themeNotifier.setTheme(themeCustomDark);
    }
    prefs.setString(Constants.appTheme, value);
  }

  void colorChangedPrimary(int value) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setInt('color_primary', value);
  }

  void colorChangedAccent(int value) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setInt('color_accent', value);
  }
}
