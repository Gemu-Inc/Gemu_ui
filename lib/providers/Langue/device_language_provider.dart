import 'package:flutter_riverpod/flutter_riverpod.dart';

final deviceLanguageProvider =
    StateNotifierProvider<DeviceLanguageProvider, String>(
        (ref) => DeviceLanguageProvider());

class DeviceLanguageProvider extends StateNotifier<String> {
  DeviceLanguageProvider() : super("en");

  setLanguage(String language) {
    state = language;
  }
}
