import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';

final emailValidRegisterNotifierProvider =
    StateNotifierProvider<EmailValidRegisterProvider, bool>(
        (ref) => EmailValidRegisterProvider());
final passwordValidRegisterNotifierProvider =
    StateNotifierProvider<PasswordValidRegisterProvider, bool>(
        (ref) => PasswordValidRegisterProvider());
final confirmPasswordValidRegisterNotifierProvider =
    StateNotifierProvider<ConfirmPasswordValidRegisterProvider, bool>(
        (ref) => ConfirmPasswordValidRegisterProvider());
final pseudonymeValidRegisterNotifierProvider =
    StateNotifierProvider<PseudonymeValidRegisterProvider, bool>(
        (ref) => PseudonymeValidRegisterProvider());
final anniversaryValidRegisterNotifierProvider =
    StateNotifierProvider<AnnniversaryValidRegisterProvider, bool>(
        (ref) => AnnniversaryValidRegisterProvider());
final gamesValidRegisterNotifierProvider =
    StateNotifierProvider<FollowGamesValidRegisterProvider, bool>(
        (ref) => FollowGamesValidRegisterProvider());
final registerCompleteProvider = FutureProvider<bool>((ref) async {
  final email = ref.watch(emailValidRegisterNotifierProvider);
  final password = ref.watch(passwordValidRegisterNotifierProvider);
  final confirmPassword =
      ref.watch(confirmPasswordValidRegisterNotifierProvider);
  final pseudonyme = ref.watch(pseudonymeValidRegisterNotifierProvider);
  final anniversary = ref.watch(anniversaryValidRegisterNotifierProvider);
  final games = ref.watch(gamesValidRegisterNotifierProvider);

  if (email &&
      password &&
      confirmPassword &&
      pseudonyme &&
      anniversary &&
      games) {
    return true;
  }
  return false;
});

class EmailValidRegisterProvider extends StateNotifier<bool> {
  EmailValidRegisterProvider() : super(false);

  updateValidity(bool newState) {
    state = newState;
  }
}

class PasswordValidRegisterProvider extends StateNotifier<bool> {
  PasswordValidRegisterProvider() : super(false);

  updateValidity(bool newState) {
    state = newState;
  }
}

class ConfirmPasswordValidRegisterProvider extends StateNotifier<bool> {
  ConfirmPasswordValidRegisterProvider() : super(false);

  updateValidity(bool newState) {
    state = newState;
  }
}

class PseudonymeValidRegisterProvider extends StateNotifier<bool> {
  PseudonymeValidRegisterProvider() : super(false);

  updateValidity(bool newState) {
    state = newState;
  }
}

class AnnniversaryValidRegisterProvider extends StateNotifier<bool> {
  AnnniversaryValidRegisterProvider() : super(false);

  updateValidity(bool newState) {
    state = newState;
  }
}

class FollowGamesValidRegisterProvider extends StateNotifier<bool> {
  FollowGamesValidRegisterProvider() : super(false);

  updateValidity(bool newState) {
    state = newState;
  }
}
