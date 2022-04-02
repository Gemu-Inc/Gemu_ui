import 'package:flutter_riverpod/flutter_riverpod.dart';

final passwordVisibilityNotifierProvider =
    StateNotifierProvider<PasswordVisibleProvider, bool>(
        (ref) => PasswordVisibleProvider());
final emailValidyNotifierProvider =
    StateNotifierProvider<EmailValidLoginProvider, bool>(
        (ref) => EmailValidLoginProvider());
final passwordValidNotifierProvider =
    StateNotifierProvider<PasswordValidLoginProvider, bool>(
        (ref) => PasswordValidLoginProvider());
final loadingLoginNotifierProvider =
    StateNotifierProvider<LoadingLoginProvider, bool>(
        (ref) => LoadingLoginProvider());
final loginCompleteProvider = FutureProvider<bool>((ref) async {
  final email = ref.watch(emailValidyNotifierProvider);
  final password = ref.watch(passwordValidNotifierProvider);

  if (email && password) {
    return true;
  }
  return false;
});

class EmailValidLoginProvider extends StateNotifier<bool> {
  EmailValidLoginProvider() : super(false);

  updateValidity(bool newState) {
    state = newState;
    print("email $state");
  }
}

class PasswordValidLoginProvider extends StateNotifier<bool> {
  PasswordValidLoginProvider() : super(false);

  updateValidity(bool newState) {
    state = newState;
    print("password $state");
  }
}

class PasswordVisibleProvider extends StateNotifier<bool> {
  PasswordVisibleProvider() : super(true);

  updateVisibilityPassword(bool newState) {
    state = newState;
  }
}

class LoadingLoginProvider extends StateNotifier<bool> {
  LoadingLoginProvider() : super(false);

  updateLoader() {
    state = !state;
  }
}
