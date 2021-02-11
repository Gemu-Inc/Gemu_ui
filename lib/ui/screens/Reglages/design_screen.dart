import 'package:Gemu/screensmodels/Reglages/design_screen_model.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/styles/styles.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';
import 'dart:math';
import 'package:Gemu/ui/widgets/busy_button.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

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
  bool createTheme = false;

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
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: GradientAppBar(
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => model.navigateToProfilMenu()),
            title: Text('Apparence'),
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
                        "Default Theme Colors",
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      Text(
                        "Select your default theme color",
                        style: TextStyle(fontSize: 15),
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
                        "Create Theme Colors",
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      Text(
                        "Select, create and save your own design",
                        style: TextStyle(fontSize: 15),
                      ),
                      Column(
                        children: [
                          Container(
                              height: 100,
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
                                  setState(() {
                                    createTheme = true;
                                  });
                                  if (isSwitched == false) {
                                    _openDialogLight(
                                        currentPrimaryColor:
                                            themeCustomLight.primaryColor,
                                        currentAccentColor:
                                            themeCustomLight.accentColor,
                                        primaryColor: true,
                                        accentColor: false);
                                  } else if (isSwitched == true) {
                                    _openDialogDark(
                                        currentPrimaryColor:
                                            themeCustomDark.primaryColor,
                                        currentAccentColor:
                                            themeCustomDark.accentColor,
                                        primaryColor: true,
                                        accentColor: false);
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
                          SizedBox(
                            height: 30,
                          ),
                          createTheme
                              ? BusyButton(
                                  onPressed: () {
                                    if (isSwitched == false) {
                                      _updateState(4);
                                      colorChangedPrimary(
                                          themeCustomLight.primaryColor.value);
                                      colorChangedAccent(
                                          themeCustomLight.accentColor.value);
                                      setState(() {
                                        createTheme = false;
                                      });
                                    } else if (isSwitched == true) {
                                      _updateState(5);
                                      colorChangedPrimary(
                                          themeCustomDark.primaryColor.value);
                                      colorChangedAccent(
                                          themeCustomDark.accentColor.value);
                                      setState(() {
                                        createTheme = false;
                                      });
                                    }
                                  },
                                  title: 'Save',
                                )
                              : Container(
                                  height: 50,
                                  color: Colors.transparent,
                                ),
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

  void _openDialogLight(
      {@required Color currentPrimaryColor,
      @required Color currentAccentColor,
      @required bool primaryColor,
      @required bool accentColor}) {
    List<String> title = ['Primary color', 'Accent color'];
    List<Widget> content = [
      Container(
          height: 250,
          child: MaterialColorPicker(
            colors: fullMaterialColors,
            selectedColor: currentPrimaryColor,
            onColorChange: (color) => setState(() => themeCustomLight =
                (primaryColor)
                    ? themeCustomLight.copyWith(primaryColor: color)
                    : themeCustomLight.copyWith(accentColor: color)),
            onMainColorChange: (color) => setState(() => themeCustomLight =
                (primaryColor)
                    ? themeCustomLight.copyWith(primaryColor: color)
                    : themeCustomLight.copyWith(accentColor: color)),
          )),
      Container(
          height: 250,
          child: MaterialColorPicker(
            colors: fullMaterialColors,
            selectedColor: currentAccentColor,
            onColorChange: (color) => setState(() => themeCustomLight =
                (accentColor)
                    ? themeCustomLight.copyWith(primaryColor: color)
                    : themeCustomLight.copyWith(accentColor: color)),
            onMainColorChange: (color) => setState(() => themeCustomLight =
                (accentColor)
                    ? themeCustomLight.copyWith(primaryColor: color)
                    : themeCustomLight.copyWith(accentColor: color)),
          ))
    ];

    showDialog(
        context: context,
        builder: (_) => MyAlertDialog(
              title: title,
              content: content,
            ));
  }

  void _openDialogDark(
      {@required Color currentPrimaryColor,
      @required Color currentAccentColor,
      @required bool primaryColor,
      @required bool accentColor}) {
    List<String> title = ['Primary color', 'Accent color'];
    List<Widget> content = [
      Container(
          height: 250,
          child: MaterialColorPicker(
            colors: fullMaterialColors,
            selectedColor: currentPrimaryColor,
            onColorChange: (color) => setState(() => themeCustomDark =
                (primaryColor)
                    ? themeCustomDark.copyWith(primaryColor: color)
                    : themeCustomDark.copyWith(accentColor: color)),
            onMainColorChange: (color) => setState(() => themeCustomDark =
                (primaryColor)
                    ? themeCustomDark.copyWith(primaryColor: color)
                    : themeCustomDark.copyWith(accentColor: color)),
          )),
      Container(
          height: 250,
          child: MaterialColorPicker(
            colors: fullMaterialColors,
            selectedColor: currentAccentColor,
            onColorChange: (color) => setState(() => themeCustomDark =
                (accentColor)
                    ? themeCustomDark.copyWith(primaryColor: color)
                    : themeCustomDark.copyWith(accentColor: color)),
            onMainColorChange: (color) => setState(() => themeCustomDark =
                (accentColor)
                    ? themeCustomDark.copyWith(primaryColor: color)
                    : themeCustomDark.copyWith(accentColor: color)),
          ))
    ];

    showDialog(
        context: context,
        builder: (_) => MyAlertDialog(
              title: title,
              content: content,
            ));
  }
}

class MyAlertDialog extends StatefulWidget {
  final title;
  final content;

  MyAlertDialog({@required this.title, @required this.content});

  @override
  _MyAlertDialogState createState() => _MyAlertDialogState();
}

class _MyAlertDialogState extends State<MyAlertDialog> {
  int currentPosition = 0;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(6.0),
      title: Text(widget.title[currentPosition]),
      content: widget.content[currentPosition],
      actions: [
        Row(
          children: [
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
                onPressed: () => setState(() {
                      if (currentPosition != 0) {
                        currentPosition -= 1;
                      } else {
                        currentPosition = 0;
                      }
                    }),
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 15,
                )),
            FlatButton(
                onPressed: () => setState(() {
                      if (currentPosition != 1) {
                        currentPosition += 1;
                      } else {
                        currentPosition = 1;
                      }
                    }),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                )),
            FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Done')),
          ],
        )
      ],
    );
  }
}
