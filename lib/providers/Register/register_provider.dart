import 'package:flutter_riverpod/flutter_riverpod.dart';

final loadingRegisterNotifierProvider =
    StateNotifierProvider.autoDispose<LoadingRegisterProvider, bool>(
        (ref) => LoadingRegisterProvider());
final passwordVisibleRegisterNotifierProvider =
    StateNotifierProvider<PasswordVisibleRegisterProvider, bool>(
        (ref) => PasswordVisibleRegisterProvider());
final successRegisterNotifierProvider =
    StateNotifierProvider.autoDispose<SuccessRegisterProvider, bool>(
        (ref) => SuccessRegisterProvider());
final emailValidRegisterNotifierProvider =
    StateNotifierProvider.autoDispose<EmailValidRegisterProvider, bool>(
        (ref) => EmailValidRegisterProvider());
final passwordValidRegisterNotifierProvider =
    StateNotifierProvider.autoDispose<PasswordValidRegisterProvider, bool>(
        (ref) => PasswordValidRegisterProvider());
final confirmPasswordValidRegisterNotifierProvider =
    StateNotifierProvider.autoDispose<ConfirmPasswordValidRegisterProvider,
        bool>((ref) => ConfirmPasswordValidRegisterProvider());
final pseudonymeValidRegisterNotifierProvider =
    StateNotifierProvider.autoDispose<PseudonymeValidRegisterProvider, bool>(
        (ref) => PseudonymeValidRegisterProvider());
final anniversaryValidRegisterNotifierProvider =
    StateNotifierProvider.autoDispose<AnnniversaryValidRegisterProvider, bool>(
        (ref) => AnnniversaryValidRegisterProvider());
final gamesValidRegisterNotifierProvider =
    StateNotifierProvider.autoDispose<FollowGamesValidRegisterProvider, bool>(
        (ref) => FollowGamesValidRegisterProvider());
final cguValidRegisterNotifierProvider =
    StateNotifierProvider.autoDispose<CGUValidRegisterProvider, bool>(
        (ref) => CGUValidRegisterProvider());
final policyPrivacyRegisterNotifierProvider =
    StateNotifierProvider.autoDispose<PolicyPrivacyRegisterProvider, bool>(
        (ref) => PolicyPrivacyRegisterProvider());
final registerCompleteProvider = FutureProvider.autoDispose<bool>((ref) async {
  final email = ref.watch(emailValidRegisterNotifierProvider);
  final password = ref.watch(passwordValidRegisterNotifierProvider);
  final confirmPassword =
      ref.watch(confirmPasswordValidRegisterNotifierProvider);
  final pseudonyme = ref.watch(pseudonymeValidRegisterNotifierProvider);
  final anniversary = ref.watch(anniversaryValidRegisterNotifierProvider);
  final games = ref.watch(gamesValidRegisterNotifierProvider);
  final cgu = ref.watch(cguValidRegisterNotifierProvider);
  final policyPrivacy = ref.watch(policyPrivacyRegisterNotifierProvider);

  if (email &&
      password &&
      confirmPassword &&
      pseudonyme &&
      anniversary &&
      games &&
      cgu &&
      policyPrivacy) {
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
    print(state);
  }
}

class CGUValidRegisterProvider extends StateNotifier<bool> {
  CGUValidRegisterProvider() : super(false);

  updateValidity() {
    state = !state;
  }
}

class PolicyPrivacyRegisterProvider extends StateNotifier<bool> {
  PolicyPrivacyRegisterProvider() : super(false);

  updateValidity() {
    state = !state;
  }
}

class PasswordVisibleRegisterProvider extends StateNotifier<bool> {
  PasswordVisibleRegisterProvider() : super(true);

  updateVisibilityPassword(bool newState) {
    state = newState;
  }
}

class LoadingRegisterProvider extends StateNotifier<bool> {
  LoadingRegisterProvider() : super(false);

  updateLoader() {
    state = !state;
  }
}

class SuccessRegisterProvider extends StateNotifier<bool> {
  SuccessRegisterProvider() : super(false);

  updateSuccess() {
    state = !state;
  }
}
