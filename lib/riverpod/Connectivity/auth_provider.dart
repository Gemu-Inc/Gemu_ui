import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authNotifierProvider =
    StateNotifierProvider<AuthProvider, User?>((ref) => AuthProvider());

class AuthProvider extends StateNotifier<User?> {
  AuthProvider() : super(null);

  updateAuth(User? user) {
    state = user;
    print("active user: $state");
  }
}
