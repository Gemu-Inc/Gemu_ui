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

  createTheme(String theme, BuildContext context) {
    if (theme == themeDarkPurple) {
      state = darkThemePurple;
    } else if (theme == themeDarkPink) {
      state = darkThemePink;
    } else if (theme == themeLightPurple) {
      state = lightThemePurple;
    } else if (theme == themeLightPink) {
      state = lightThemePink;
    } else {
      state = ThemeData();
    }
  }

  updateTheme(ThemeData? mode) {
    state = mode!;
  }
}

class PrimaryColorProvider extends StateNotifier<Color> {
  PrimaryColorProvider() : super(cPrimaryPink);

  createPrimaryColor(Color color) {
    state = color;
  }

  updatePrimaryColor(Color color) {
    state = color;
  }
}

class AccentColorProvider extends StateNotifier<Color> {
  AccentColorProvider() : super(cPrimaryPurple);

  createAccentColor(Color color) {
    state = color;
  }

  updateAccentColor(Color color) {
    state = color;
  }
}
