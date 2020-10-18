import 'package:flutter/material.dart';
import 'package:Gemu/config/config.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_icons/flutter_icons.dart';

class ReglagesScreen extends StatefulWidget {
  ReglagesScreen({Key key}) : super(key: key);

  @override
  _ReglagesScreenState createState() => _ReglagesScreenState();
}

class _ReglagesScreenState extends State<ReglagesScreen> {
  int selectedPosition = 0;
  List themes = Constants.themes;
  SharedPreferences prefs;
  ThemeNotifier themeNotifier;

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
    return Scaffold(
        appBar: GradientAppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context)),
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
                                                Animation<double> animation) =>
                                            ScaleTransition(
                                                child: child, scale: animation),
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
                                                Animation<double> animation) =>
                                            ScaleTransition(
                                                child: child, scale: animation),
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
                                    fillColor:
                                        darkThemeOrange.scaffoldBackgroundColor,
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
                                                Animation<double> animation) =>
                                            ScaleTransition(
                                                child: child, scale: animation),
                                        child: _getIcon(
                                            themeNotifier, darkThemePurple)),
                                    shape: CircleBorder(),
                                    elevation: 2.0,
                                    fillColor:
                                        darkThemePurple.scaffoldBackgroundColor,
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
                          margin: EdgeInsets.all(5.0),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: FlatButton(
                              onPressed: () => _openDialogLight("Primary Color",
                                  lightThemeCustom.primaryColor, true),
                              color: lightThemeCustom.primaryColor,
                              child: Text("Choose Primary Color",
                                  textAlign: TextAlign.center,
                                  style: lightThemeCustom
                                      .primaryTextTheme.button)),
                        ),
                        Container(
                          margin: EdgeInsets.all(5.0),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: FlatButton(
                              onPressed: () => _openDialogLight("AccentColor",
                                  lightThemeCustom.accentColor, false),
                              color: lightThemeCustom.accentColor,
                              child: Text("Choose Accent Color",
                                  textAlign: TextAlign.center,
                                  style: lightThemeCustom
                                      .primaryTextTheme.button)),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        RawMaterialButton(
                          onPressed: () {
                            _updateState(4);
                            colorChangedPrimary(
                                lightThemeCustom.primaryColor.value);
                            colorChangedAccent(
                                lightThemeCustom.accentColor.value);
                          },
                          child: AnimatedSwitcher(
                              duration: Duration(milliseconds: 400),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) =>
                                      ScaleTransition(
                                          child: child, scale: animation),
                              child: _getIcon(themeNotifier, lightThemeCustom)),
                          shape: CircleBorder(),
                          elevation: 2.0,
                          fillColor: lightThemeCustom.scaffoldBackgroundColor,
                          padding: EdgeInsets.all(5.0),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(themes[4]),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(5.0),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: FlatButton(
                              onPressed: () => _openDialogDark("Primary Color",
                                  darkThemeCustom.primaryColor, true),
                              color: darkThemeCustom.primaryColor,
                              child: Text("Choose Primary Color",
                                  textAlign: TextAlign.center,
                                  style:
                                      darkThemeCustom.primaryTextTheme.button)),
                        ),
                        Container(
                          margin: EdgeInsets.all(5.0),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: FlatButton(
                              onPressed: () => _openDialogDark("AccentColor",
                                  darkThemeCustom.accentColor, false),
                              color: darkThemeCustom.accentColor,
                              child: Text("Choose Accent Color",
                                  textAlign: TextAlign.center,
                                  style:
                                      darkThemeCustom.primaryTextTheme.button)),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        RawMaterialButton(
                          onPressed: () {
                            _updateState(5);
                            colorChangedPrimary(
                                darkThemeCustom.primaryColor.value);
                            colorChangedAccent(
                                darkThemeCustom.accentColor.value);
                          },
                          child: AnimatedSwitcher(
                              duration: Duration(milliseconds: 400),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) =>
                                      ScaleTransition(
                                          child: child, scale: animation),
                              child: _getIcon(themeNotifier, darkThemeCustom)),
                          shape: CircleBorder(),
                          elevation: 2.0,
                          fillColor: darkThemeCustom.scaffoldBackgroundColor,
                          padding: EdgeInsets.all(5.0),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(themes[5]),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ));
  }

  void _openDialogLight(String title, Color currentColor, bool primaryColor) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(6.0),
          title: Text(title),
          content: Container(
              height: 250,
              child: MaterialColorPicker(
                selectedColor: currentColor,
                onColorChange: (color) => setState(() => lightThemeCustom =
                    (primaryColor)
                        ? lightThemeCustom.copyWith(primaryColor: color)
                        : lightThemeCustom.copyWith(accentColor: color)),
                onMainColorChange: (color) => setState(() => lightThemeCustom =
                    (primaryColor)
                        ? lightThemeCustom.copyWith(primaryColor: color)
                        : lightThemeCustom.copyWith(accentColor: color)),
              )),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Done",
                style: Theme.of(context).textTheme.button,
              ),
            )
          ],
        );
      },
    );
  }

  void _openDialogDark(String title, Color currentColor, bool primaryColor) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(6.0),
          title: Text(title),
          content: Container(
              height: 250,
              child: MaterialColorPicker(
                selectedColor: currentColor,
                onColorChange: (color) => setState(() => darkThemeCustom =
                    (primaryColor)
                        ? darkThemeCustom.copyWith(primaryColor: color)
                        : darkThemeCustom.copyWith(accentColor: color)),
                onMainColorChange: (color) => setState(() => darkThemeCustom =
                    (primaryColor)
                        ? darkThemeCustom.copyWith(primaryColor: color)
                        : darkThemeCustom.copyWith(accentColor: color)),
              )),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Done",
                style: Theme.of(context).textTheme.button,
              ),
            )
          ],
        );
      },
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
    } else if (value == 'LightCustom') {
      themeNotifier.setTheme(lightThemeCustom);
    } else if (value == 'DarkCustom') {
      themeNotifier.setTheme(darkThemeCustom);
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
