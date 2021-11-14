import 'package:flutter/material.dart';
import 'package:gemu/ui/widgets/app_bar_custom.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'package:gemu/ui/constants/app_constants.dart';
import 'package:gemu/ui/screens/Reglages/Design/theme_notifier.dart';
import 'package:gemu/ui/screens/Reglages/Design/theme_values.dart';

class DesignScreen extends StatefulWidget {
  @override
  _DesignScreenState createState() => _DesignScreenState();
}

class _DesignScreenState extends State<DesignScreen> {
  List themes = Constants.themes;
  late SharedPreferences prefs;
  late ThemeNotifier themeNotifier;
  late PrimaryColorNotifier _primaryColorNotifier;
  late AccentColorNotifier _accentColorNotifier;

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
    themeNotifier = Provider.of<ThemeNotifier>(context);
    _primaryColorNotifier = Provider.of<PrimaryColorNotifier>(context);
    _accentColorNotifier = Provider.of<AccentColorNotifier>(context);
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBarCustom(context: context, title: 'Design', actions: []),
        body: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: systemTheme(),
              ),
              Expanded(
                child: lightThemes(),
              ),
              Expanded(
                child: darkThemes(),
              )
            ],
          ),
        ));
  }

  Widget systemTheme() {
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
                          colorChangedPrimary(orangeApp.value);
                          colorChangedAccent(purpleApp.value);
                          onThemeChanged('ThemeCustomSystem');
                        },
                        child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 400),
                            transitionBuilder: (Widget child,
                                    Animation<double> animation) =>
                                ScaleTransition(child: child, scale: animation),
                            child: _getIconSystem(orangeApp, purpleApp)),
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
                          colorChangedPrimary(purpleApp.value);
                          colorChangedAccent(orangeApp.value);
                          onThemeChanged('ThemeCustomSystem');
                        },
                        child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 400),
                            transitionBuilder: (Widget child,
                                    Animation<double> animation) =>
                                ScaleTransition(child: child, scale: animation),
                            child: _getIconSystem(purpleApp, orangeApp)),
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
                        onPressed: () => onThemeChanged('LightOrange'),
                        child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 400),
                            transitionBuilder: (Widget child,
                                    Animation<double> animation) =>
                                ScaleTransition(child: child, scale: animation),
                            child: _getIcon(themeNotifier, lightThemeOrange)),
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
                        onPressed: () => onThemeChanged('LightPurple'),
                        child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 400),
                            transitionBuilder: (Widget child,
                                    Animation<double> animation) =>
                                ScaleTransition(child: child, scale: animation),
                            child: _getIcon(themeNotifier, lightThemePurple)),
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
                      onPressed: () => onThemeChanged('DarkOrange'),
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 400),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) =>
                                ScaleTransition(child: child, scale: animation),
                        child: _getIcon(themeNotifier, darkThemeOrange),
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
                      onPressed: () => onThemeChanged('DarkPurple'),
                      child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 400),
                          transitionBuilder: (Widget child,
                                  Animation<double> animation) =>
                              ScaleTransition(child: child, scale: animation),
                          child: _getIcon(themeNotifier, darkThemePurple)),
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

  Widget _getIconSystem(Color primaryColor, Color accentColor) {
    bool selected = (_primaryColorNotifier.getColor() == primaryColor &&
        _accentColorNotifier.getColor() == accentColor &&
        themeNotifier.getTheme() == null);

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

  void onThemeChanged(String value) async {
    var prefs = await SharedPreferences.getInstance();
    if (value == 'LightOrange') {
      themeNotifier.setTheme(lightThemeOrange);
      //Mise en place de l'overlay des notifications Android
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Color(0xFFDEE4E7)));
    } else if (value == 'LightPurple') {
      themeNotifier.setTheme(lightThemePurple);
      //Mise en place de l'overlay des notifications Android
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Color(0xFFDEE4E7)));
    } else if (value == 'DarkOrange') {
      themeNotifier.setTheme(darkThemeOrange);
      //Mise en place de l'overlay des notifications Android
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Color(0xFF1A1C25)));
    } else if (value == 'DarkPurple') {
      themeNotifier.setTheme(darkThemePurple);
      //Mise en place de l'overlay des notifications Android
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Color(0xFF1A1C25)));
    } else if (value == 'ThemeCustomSystem') {
      themeNotifier.setTheme(null);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent));
    }
    prefs.setString(Constants.appTheme, value);
  }

  void colorChangedPrimary(int value) async {
    var prefs = await SharedPreferences.getInstance();
    if (value == orangeApp.value) {
      _primaryColorNotifier.setColor(orangeApp);
    } else if (value == purpleApp.value) {
      _primaryColorNotifier.setColor(purpleApp);
    }
    prefs.setInt('color_primary', value);
  }

  void colorChangedAccent(int value) async {
    var prefs = await SharedPreferences.getInstance();
    if (value == orangeApp.value) {
      _accentColorNotifier.setColor(orangeApp);
    } else if (value == purpleApp.value) {
      _accentColorNotifier.setColor(purpleApp);
    }
    prefs.setInt('color_accent', value);
  }
}
