import 'package:flutter_riverpod/flutter_riverpod.dart';

final loadingLoginNotifierProvider =
    StateNotifierProvider<LoadingLoginProvider, bool>(
        (ref) => LoadingLoginProvider());
final passwordVisibilityNotifierProvider =
    StateNotifierProvider<PasswordVisibleProvider, bool>(
        (ref) => PasswordVisibleProvider());

class LoadingLoginProvider extends StateNotifier<bool> {
  LoadingLoginProvider() : super(false);

  updateLoader() {
    state = !state;
  }
}

class PasswordVisibleProvider extends StateNotifier<bool> {
  PasswordVisibleProvider() : super(true);

  updateVisibilityPassword(bool newState) {
    state = newState;
  }
}
