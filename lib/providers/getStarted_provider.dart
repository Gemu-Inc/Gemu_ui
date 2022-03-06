import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getStartedNotifierProvider =
    StateNotifierProvider<GetStartedProvider, bool>(
        (ref) => GetStartedProvider());

class GetStartedProvider extends StateNotifier<bool> {
  GetStartedProvider() : super(false);

  Future<void> setSeenGetStarted() async {
    bool? seenGetStarted;
    final prefs = await SharedPreferences.getInstance();
    seenGetStarted = prefs.getBool("getStarted");

    if (seenGetStarted == null) {
      state = false;
    } else {
      state = true;
    }
  }

  Future<void> updateSeenGetStarted() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("getStarted", true);
    state = true;
  }
}
