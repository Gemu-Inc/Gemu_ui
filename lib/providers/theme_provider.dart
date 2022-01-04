import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gemu/constants/constants.dart';

final themeProviderNotifier =
    StateNotifierProvider<ThemeProvider, ThemeData>((ref) => ThemeProvider());
final primaryProviderNotifier =
    StateNotifierProvider<PrimaryColorProvider, Color>(
        (ref) => PrimaryColorProvider());
final accentProviderNotifier =
    StateNotifierProvider<AccentColorProvider, Color>(
        (ref) => AccentColorProvider());

class ThemeProvider extends StateNotifier<ThemeData> {
  ThemeProvider() : super(ThemeData());

  createTheme(String theme) {
    if (theme == 'DarkPurple') {
      state = darkThemePurple;
    } else if (theme == 'DarkOrange') {
      state = darkThemeOrange;
    } else if (theme == 'LightPurple') {
      state = lightThemePurple;
    } else if (theme == 'LightOrange') {
      state = lightThemeOrange;
    } else {
      state = ThemeData();
    }
  }

  updateTheme(ThemeData? mode) {
    state = mode!;
  }
}

class PrimaryColorProvider extends StateNotifier<Color> {
  PrimaryColorProvider() : super(cOrange);

  createPrimaryColor(Color color) {
    state = color;
  }

  updatePrimaryColor(Color color) {
    state = color;
  }
}

class AccentColorProvider extends StateNotifier<Color> {
  AccentColorProvider() : super(cMauve);

  createAccentColor(Color color) {
    state = color;
  }

  updateAccentColor(Color color) {
    state = color;
  }
}
