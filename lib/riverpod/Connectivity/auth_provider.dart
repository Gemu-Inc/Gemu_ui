import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authNotifierProvider =
    StateNotifierProvider<AuthProvider, User?>((ref) => AuthProvider());
final waitingAuthNotifierProvider =
    StateNotifierProvider<WaitingAuthProvider, bool>(
        (ref) => WaitingAuthProvider());

class AuthProvider extends StateNotifier<User?> {
  AuthProvider() : super(null);

  updateAuth(User? user) {
    state = user;
    print("active user: $state");
  }
}

class WaitingAuthProvider extends StateNotifier<bool> {
  WaitingAuthProvider() : super(false);

  updateWaiting(bool newState) {
    state = newState;
  }
}
