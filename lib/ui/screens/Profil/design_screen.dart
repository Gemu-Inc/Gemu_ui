import 'package:Gemu/screensmodels/Profil/design_screen_model.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/styles/styles.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';
import 'dart:math';

class DesignScreen extends StatefulWidget {
  @override
  _DesignScreenState createState() => _DesignScreenState();
}

class _DesignScreenState extends State<DesignScreen> {
  int selectedPosition = 0;
  List themes = Constants.themes;
  SharedPreferences prefs;
  ThemeNotifier themeNotifier;
  bool isSwitched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    return ViewModelBuilder<DesignScreenModel>.reactive(
      viewModelBuilder: () => DesignScreenModel(),
      builder: (context, model, child) => Scaffold(
          appBar: GradientAppBar(
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => model.navigateToProfilMenu()),
            title: Text('Design'),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).accentColor
              ],
            ),
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.all(5.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Current Theme Colors",
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      Container(
                          margin: EdgeInsets.all(5.0),
                          height: 90,
                          width: MediaQuery.of(context).size.width,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              Container(
                                height: 80,
                                width: MediaQuery.of(context).size.width / 4,
                                child: Column(
                                  children: [
                                    RawMaterialButton(
                                      onPressed: () => _updateState(0),
                                      child: AnimatedSwitcher(
                                          duration: Duration(milliseconds: 400),
                                          transitionBuilder: (Widget child,
                                                  Animation<double>
                                                      animation) =>
                                              ScaleTransition(
                                                  child: child,
                                                  scale: animation),
                                          child: _getIcon(
                                              themeNotifier, lightThemeOrange)),
                                      shape: CircleBorder(),
                                      elevation: 2.0,
                                      fillColor: lightThemeOrange
                                          .scaffoldBackgroundColor,
                                      padding: EdgeInsets.all(5.0),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(themes[0]),
                                  ],
                                ),
                              ),
                              Container(
                                height: 80,
                                width: MediaQuery.of(context).size.width / 4,
                                child: Column(
                                  children: [
                                    RawMaterialButton(
                                      onPressed: () => _updateState(1),
                                      child: AnimatedSwitcher(
                                          duration: Duration(milliseconds: 400),
                                          transitionBuilder: (Widget child,
                                                  Animation<double>
                                                      animation) =>
                                              ScaleTransition(
                                                  child: child,
                                                  scale: animation),
                                          child: _getIcon(
                                              themeNotifier, lightThemePurple)),
                                      shape: CircleBorder(),
                                      elevation: 2.0,
                                      fillColor: lightThemePurple
                                          .scaffoldBackgroundColor,
                                      padding: EdgeInsets.all(5.0),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(themes[1]),
                                  ],
                                ),
                              ),
                              Container(
                                height: 80,
                                width: MediaQuery.of(context).size.width / 4,
                                child: Column(
                                  children: [
                                    RawMaterialButton(
                                      onPressed: () => _updateState(2),
                                      child: AnimatedSwitcher(
                                        duration: Duration(milliseconds: 400),
                                        transitionBuilder: (Widget child,
                                                Animation<double> animation) =>
                                            ScaleTransition(
                                                child: child, scale: animation),
                                        child: _getIcon(
                                            themeNotifier, darkThemeOrange),
                                      ),
                                      shape: CircleBorder(),
                                      elevation: 2.0,
                                      fillColor: darkThemeOrange
                                          .scaffoldBackgroundColor,
                                      padding: EdgeInsets.all(5.0),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(themes[2]),
                                  ],
                                ),
                              ),
                              Container(
                                height: 80,
                                width: MediaQuery.of(context).size.width / 4,
                                child: Column(
                                  children: [
                                    RawMaterialButton(
                                      onPressed: () => _updateState(3),
                                      child: AnimatedSwitcher(
                                          duration: Duration(milliseconds: 400),
                                          transitionBuilder: (Widget child,
                                                  Animation<double>
                                                      animation) =>
                                              ScaleTransition(
                                                  child: child,
                                                  scale: animation),
                                          child: _getIcon(
                                              themeNotifier, darkThemePurple)),
                                      shape: CircleBorder(),
                                      elevation: 2.0,
                                      fillColor: darkThemePurple
                                          .scaffoldBackgroundColor,
                                      padding: EdgeInsets.all(5.0),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(themes[3]),
                                  ],
                                ),
                              ),
                            ],
                          )),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Select Pre-defined Themes",
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      Column(
                        children: [
                          Container(
                              height: 250,
                              child: Center(
                                  child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text('Light'),
                                  Switch(
                                    value: isSwitched,
                                    onChanged: (value) {
                                      setState(() {
                                        isSwitched = value;
                                      });
                                    },
                                    inactiveThumbColor: Colors.blue,
                                    inactiveTrackColor: Colors.black,
                                    activeColor: Colors.red,
                                    activeTrackColor: Colors.black,
                                  ),
                                  Text('Dark')
                                ],
                              ))),
                          Container(
                            margin: EdgeInsets.all(5.0),
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [Colors.grey[200], Colors.black]),
                                borderRadius: BorderRadius.circular(40)),
                            child: RawMaterialButton(
                                onPressed: () {
                                  if (isSwitched == false) {
                                    model.openDialogThemeCustomLight();
                                  } else if (isSwitched == true) {
                                    model.openDialogThemeCustomDark();
                                  }
                                },
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color((Random().nextDouble() *
                                                        0xFFFFFF)
                                                    .toInt())
                                                .withOpacity(1.0),
                                            Color((Random().nextDouble() *
                                                        0xFFFFFF)
                                                    .toInt())
                                                .withOpacity(1.0)
                                          ]),
                                      borderRadius: BorderRadius.circular(40)),
                                  child: Icon(
                                    Icons.edit,
                                    size: 20.0,
                                  ),
                                )),
                          ),
                          FlatButton(
                              onPressed: () {
                                if (isSwitched == false) {
                                  _updateState(4);
                                  colorChangedPrimary(
                                      themeCustomLight.primaryColor.value);
                                  colorChangedAccent(
                                      themeCustomLight.accentColor.value);
                                } else if (isSwitched == true) {
                                  _updateState(5);
                                  colorChangedPrimary(
                                      themeCustomDark.primaryColor.value);
                                  colorChangedAccent(
                                      themeCustomDark.accentColor.value);
                                }
                              },
                              child: Text('Save')),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          )),
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