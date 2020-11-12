import 'package:flutter/material.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeData _themeMode;

  ThemeNotifier(this._themeMode);

  getTheme() => _themeMode;

  setTheme(ThemeData mode) async {
    _themeMode = mode;
    notifyListeners();
  }
}
