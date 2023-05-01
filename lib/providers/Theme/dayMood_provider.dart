import 'package:flutter_riverpod/flutter_riverpod.dart';

final dayMoodNotifierProvider =
    StateNotifierProvider<DayMoodProvider, bool>((ref) => DayMoodProvider());

class DayMoodProvider extends StateNotifier<bool> {
  DayMoodProvider() : super(false);

  void timeMood() {
    int hour = DateTime.now().hour;

    if (hour >= 8 && hour <= 18) {
      state = true;
    } else {
      state = false;
    }
  }
}
