import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemu/models/user.dart';

final myselfNotifierProvider =
    StateNotifierProvider<MyselfProvider, UserModel?>(
        (ref) => MyselfProvider());

class MyselfProvider extends StateNotifier<UserModel?> {
  MyselfProvider() : super(null);

  initUser(UserModel user) {
    state = user;
  }

  cleanUser() {
    state = null;
  }
}
