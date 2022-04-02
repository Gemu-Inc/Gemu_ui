import 'package:flutter_riverpod/flutter_riverpod.dart';

final passwordVisibilityLoginNotifierProvider =
    StateNotifierProvider.autoDispose<PasswordVisibleLoginProvider, bool>(
        (ref) => PasswordVisibleLoginProvider());
final emailValidLoginNotifierProvider =
    StateNotifierProvider.autoDispose<EmailValidLoginProvider, bool>(
        (ref) => EmailValidLoginProvider());
final passwordValidLoginNotifierProvider =
    StateNotifierProvider.autoDispose<PasswordValidLoginProvider, bool>(
        (ref) => PasswordValidLoginProvider());
final loadingLoginNotifierProvider =
    StateNotifierProvider.autoDispose<LoadingLoginProvider, bool>(
        (ref) => LoadingLoginProvider());
final loginCompleteProvider = FutureProvider.autoDispose<bool>((ref) async {
  final email = ref.watch(emailValidLoginNotifierProvider);
  final password = ref.watch(passwordValidLoginNotifierProvider);

  if (email && password) {
    return true;
  }
  return false;
});

class EmailValidLoginProvider extends StateNotifier<bool> {
  EmailValidLoginProvider() : super(false);

  updateValidity(bool newState) {
    state = newState;
  }
}

class PasswordValidLoginProvider extends StateNotifier<bool> {
  PasswordValidLoginProvider() : super(false);

  updateValidity(bool newState) {
    state = newState;
  }
}

class PasswordVisibleLoginProvider extends StateNotifier<bool> {
  PasswordVisibleLoginProvider() : super(true);

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
