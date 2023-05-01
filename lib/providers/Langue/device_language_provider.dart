import 'dart:io';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final deviceLanguageProvider =
    StateNotifierProvider<DeviceLanguageProvider, Locale>(
        (ref) => DeviceLanguageProvider());

class DeviceLanguageProvider extends StateNotifier<Locale> {
  DeviceLanguageProvider() : super(const Locale('en', ''));

  Future<void> setLocaleLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Locale localeLanguage;
    String? languePrefs = prefs.getString("langue");
    if (languePrefs != null) {
      localeLanguage = Locale(languePrefs, '');
    } else {
      if (Platform.localeName.split("_")[0] == "en" ||
          Platform.localeName.split("_")[0] == "fr") {
        localeLanguage = Locale(Platform.localeName.split("_")[0], '');
      } else {
        localeLanguage = const Locale('en', '');
      }
    }
    state = localeLanguage;
  }
}
