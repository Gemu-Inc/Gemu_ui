import 'package:flutter/material.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeData? _themeMode;

  ThemeNotifier(this._themeMode);

  getTheme() => _themeMode;

  setTheme(ThemeData? mode) async {
    _themeMode = mode;
    notifyListeners();
  }
}

class BackgroundNotifier with ChangeNotifier {
  late Color _backgroundColor;

  BackgroundNotifier(this._backgroundColor);

  getColor() => _backgroundColor;

  setColor(Color color) async {
    _backgroundColor = color;
    notifyListeners();
  }
}

class PrimaryColorNotifier with ChangeNotifier {
  late Color _coloPrimary;

  PrimaryColorNotifier(this._coloPrimary);

  getColor() => _coloPrimary;

  setColor(Color color) async {
    _coloPrimary = color;
    notifyListeners();
  }
}

class AccentColorNotifier with ChangeNotifier {
  late Color _colorAccent;

  AccentColorNotifier(this._colorAccent);

  getColor() => _colorAccent;

  setColor(Color color) async {
    _colorAccent = color;
    notifyListeners();
  }
}
