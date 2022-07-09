import 'package:flutter_riverpod/flutter_riverpod.dart';

final loadingSignGoogleProvider =
    StateNotifierProvider<LoadingSignGoogle, bool>(
        (ref) => LoadingSignGoogle());
final loadingSignAppleProvider =
    StateNotifierProvider<LoadingSignApple, bool>((ref) => LoadingSignApple());

class LoadingSignGoogle extends StateNotifier<bool> {
  LoadingSignGoogle() : super(false);

  updateLoading(bool newState) {
    state = newState;
    print("state: $state");
  }
}

class LoadingSignApple extends StateNotifier<bool> {
  LoadingSignApple() : super(false);

  updateLoading(bool newState) {
    state = newState;
  }
}
