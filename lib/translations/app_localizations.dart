import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalization {
  late final Locale _locale;
  AppLocalization(this._locale);

  static AppLocalization of(BuildContext context) {
    return Localizations.of<AppLocalization>(context, AppLocalization)!;
  }

  static const LocalizationsDelegate<AppLocalization> delegate =
      _AppLocalizationDelegate();

  late Map<String, dynamic>
      _localizedValues; //your values are not String anymore and we use dynamic instead

  Future<bool> loadLanguage() async {
    // Load a language JSON file from the 'i18n' folder
    String value = await rootBundle
        .loadString("lib/translations/locales/${_locale.languageCode}.json");
    Map<String, dynamic> jsonMap = jsonDecode(value);
    _localizedValues = jsonMap.map((key, value) {
      return MapEntry(
          key, value); //not value.toString() so the value will be a map
    });
    return true;
  }

  String translate(String parentKey, String childKey) {
    // Returns a localized text
    return _localizedValues[parentKey][childKey];
  }
}

class _AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  const _AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) {
    return ["en", "fr"].contains(locale.languageCode);
  }

  @override
  Future<AppLocalization> load(Locale locale) async {
    AppLocalization appLocalization = AppLocalization(locale);
    await appLocalization.loadLanguage();
    return appLocalization;
  }

  @override
  bool shouldReload(_AppLocalizationDelegate old) => false;
}
