import 'package:flutter/material.dart';
import 'package:Gemu/config/config.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'dart:math';
import 'package:flutter_icons/flutter_icons.dart';

class ReglagesScreen extends StatefulWidget {
  ReglagesScreen({Key key}) : super(key: key);

  @override
  _ReglagesScreenState createState() => _ReglagesScreenState();
}

class _ReglagesScreenState extends State<ReglagesScreen> {
  /*List<ThemeItem> _themeItems = ThemeItem.getThemeItems();

  List<DropdownMenuItem<ThemeItem>> _dropDownMenuItems;

  ThemeItem _selectedItem;

  List<DropdownMenuItem<ThemeItem>> buildDropdownMenuItems() {
    List<DropdownMenuItem<ThemeItem>> items = List();
    for (ThemeItem themeItem in _themeItems) {
      items
          .add(DropdownMenuItem(value: themeItem, child: Text(themeItem.name)));
    }
    return items;
  }

  @override
  void initState() {
    _dropDownMenuItems = buildDropdownMenuItems();
    _selectedItem = _dropDownMenuItems[0].value;
    super.initState();
  }

  void changeColor() {
    DynamicTheme.of(context).setThemeData(this._selectedItem.themeData);
  }

  setSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('dynTheme', _selectedItem.slug);
  }

  onChangeDropdownItem(ThemeItem selectedItem) {
    setState(() {
      this._selectedItem = selectedItem;
    });
    changeColor();
    setSharedPrefs();
  }*/

  ThemeData _customThemeDark = ThemeData(
    brightness: Brightness.dark,
    primaryColor:
        Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
    accentColor:
        Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
    scaffoldBackgroundColor: Colors.grey[1000],
    secondaryHeaderColor: Colors.black,
    splashColor: Colors.grey[1000],
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    primaryTextTheme: TextTheme(
      headline6: TextStyle(color: Colors.black),
      bodyText1: TextStyle(color: Colors.black),
      bodyText2: TextStyle(color: Colors.black),
    ),
    appBarTheme: AppBarTheme(
      color: Colors.black45,
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
    ),
    cardTheme: CardTheme(color: Colors.black),
    cardColor: Colors.black45,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFDC804F),
    ),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.black),
    bottomAppBarTheme: BottomAppBarTheme(
      color: Colors.black45,
    ),
    /*tabBarTheme: TabBarTheme(
      unselectedLabelColor: Colors.grey[400],
      labelColor: Color(0xFFDC804F),
    ),*/
    indicatorColor: Color(0xFFDC804F),
  );

  ThemeData _customThemeLight = ThemeData(
    brightness: Brightness.light,
    primaryColor:
        Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
    accentColor:
        Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
    scaffoldBackgroundColor: Colors.grey[200],
    secondaryHeaderColor: Colors.white,
    splashColor: Colors.grey[200],
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    primaryTextTheme: TextTheme(
      headline6: TextStyle(color: Colors.black),
      bodyText1: TextStyle(color: Colors.black),
      bodyText2: TextStyle(color: Colors.black),
    ),
    appBarTheme: AppBarTheme(
      color: Colors.white,
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
    ),
    cardTheme: CardTheme(color: Colors.white),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFDC804F),
    ),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.white),
    bottomAppBarTheme: BottomAppBarTheme(
      color: Colors.white,
    ),
    /*tabBarTheme: TabBarTheme(
      unselectedLabelColor: Colors.black,
      labelColor: Color(0xFFDC804F),
    ),
    indicatorColor: Color(0xFFDC804F),*/
  );

  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
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
      body: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Spacer(),
            Text(
              "Current Theme Colors",
              style: Theme.of(context).textTheme.headline5,
            ),
            SizedBox(height: 8),
            _themeColorContainer(
                "Primary Color", Theme.of(context).primaryColor),
            _themeColorContainer("Accent Color", Theme.of(context).accentColor),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Select Pre-defined Themes",
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ThemeButton(buttonThemeData: dOrangeTheme),
                ThemeButton(buttonThemeData: dPurpleTheme),
                ThemeButton(buttonThemeData: lOrangeTheme),
                ThemeButton(buttonThemeData: lPurpleTheme),
              ],
            ),
            Spacer(),
            Text(
              "Select Custom Theme",
              style: Theme.of(context).textTheme.headline5,
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isSwitched
                    ? SizedBox()
                    : Icon(
                        Feather.sun,
                        color: Colors.yellow,
                      ),
                SizedBox(
                  width: 10.0,
                ),
                Text('Light'),
                Switch(
                  value: isSwitched,
                  inactiveThumbColor: Colors.yellow,
                  inactiveTrackColor: Theme.of(context).primaryColor,
                  activeTrackColor: Theme.of(context).accentColor,
                  activeColor: Colors.yellow,
                  onChanged: (value) {
                    setState(() {
                      isSwitched = value;
                    });
                  },
                ),
                Text('Dark'),
                SizedBox(
                  width: 10.0,
                ),
                isSwitched
                    ? Icon(
                        Feather.moon,
                        color: Colors.yellow,
                      )
                    : SizedBox()
              ],
            ),
            Container(
              width: double.infinity,
              child: FlatButton(
                  onPressed: () => _openDialog(
                      "Primary Color",
                      isSwitched
                          ? _customThemeDark.primaryColor
                          : _customThemeLight.primaryColor,
                      true),
                  color: isSwitched
                      ? _customThemeDark.primaryColor
                      : _customThemeLight.primaryColor,
                  child: Text("Choose Primary Color",
                      textAlign: TextAlign.center,
                      style: isSwitched
                          ? _customThemeDark.primaryTextTheme.button
                          : _customThemeLight.primaryTextTheme.button)),
            ),
            Spacer(),
            Container(
              width: double.infinity,
              child: FlatButton(
                  onPressed: () => _openDialog(
                      "Accent Color",
                      isSwitched
                          ? _customThemeDark.accentColor
                          : _customThemeLight.accentColor,
                      false),
                  color: isSwitched
                      ? _customThemeDark.accentColor
                      : _customThemeLight.accentColor,
                  child: Text("Choose Accent Color",
                      textAlign: TextAlign.center,
                      style: isSwitched
                          ? _customThemeDark.primaryTextTheme.button
                          : _customThemeLight.primaryTextTheme.button)),
            ),
            Spacer(),
            ThemeButton(
                buttonThemeData:
                    isSwitched ? _customThemeDark : _customThemeLight),
            Spacer(),
          ],
        ),
      ),

      /*CustomScrollView(
        slivers: [
          SliverGradientAppBar(
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.pop(context)),
            title: Text('Réglages'),
            gradient: LinearGradient(
              colors: [Color(0xFF7C79A5), Color(0xFFDC804F)],
            ),
          ),
          SliverToBoxAdapter(child: ,),
          SliverList(
              delegate: SliverChildListDelegate([
            /*Align(
              alignment: Alignment.topCenter,
              child: Container(
                  margin: EdgeInsets.only(top: 10.0, bottom: 30.0),
                  color: Theme.of(context).cardColor,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 15.0,
                        left: 15.0,
                        child: Text(
                          'Thème',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      DropdownButton(
                        items: _dropDownMenuItems,
                        onChanged: onChangeDropdownItem,
                        underline: SizedBox(),
                      ),
                    ],
                  )),
            ),
            Wrap(
              direction: Axis.horizontal,
              children: color
                  .map((e) => GestureDetector(
                        child: Container(
                          margin: EdgeInsets.all(10.0),
                          height: 80,
                          width: 80,
                          color: e.color,
                        ),
                      ))
                  .toList(),
            )*/
          ]))
        ],
      ),*/
    );
  }

  Widget _themeColorContainer(String colorName, Color color) {
    return Container(
      width: double.infinity,
      height: 50,
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(vertical: 16),
      color: color,
      child: Text(colorName,
          textAlign: TextAlign.center,
          style: Theme.of(context).primaryTextTheme.button),
    );
  }

  void _openDialog(String title, Color currentColor, bool primaryColor) {
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
              onColorChange: (color) => setState(() => isSwitched
                  ? _customThemeDark = (primaryColor)
                      ? _customThemeDark.copyWith(primaryColor: color)
                      : _customThemeDark.copyWith(accentColor: color)
                  : _customThemeLight = (primaryColor)
                      ? _customThemeLight.copyWith(primaryColor: color)
                      : _customThemeLight.copyWith(accentColor: color)),
              onMainColorChange: (color) => setState(() => isSwitched
                  ? _customThemeDark = (primaryColor)
                      ? _customThemeDark.copyWith(primaryColor: color)
                      : _customThemeDark.copyWith(accentColor: color)
                  : _customThemeLight = (primaryColor)
                      ? _customThemeLight.copyWith(primaryColor: color)
                      : _customThemeLight.copyWith(accentColor: color)),
            ),
          ),
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
}

/*class ChoixColor {
  int id;
  Color color;

  ChoixColor({@required this.id, @required this.color});
}

final List<ChoixColor> color = [
  ChoixColor(id: 01, color: Colors.blue),
  ChoixColor(id: 02, color: Colors.red),
  ChoixColor(id: 03, color: Colors.green),
  ChoixColor(id: 04, color: Colors.yellow)
];*/
