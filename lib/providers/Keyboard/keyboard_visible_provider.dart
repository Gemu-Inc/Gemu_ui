import 'package:flutter_riverpod/flutter_riverpod.dart';

final keyboardVisibilityNotifierProvider =
    StateNotifierProvider<KeyboardVisibleProvider, bool>(
        (ref) => KeyboardVisibleProvider());

class KeyboardVisibleProvider extends StateNotifier<bool> {
  KeyboardVisibleProvider() : super(false);

  void updateVisibilityKeyboard(bool newState) {
    state = newState;
  }
}
