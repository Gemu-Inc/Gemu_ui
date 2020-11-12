import 'package:firebase_auth/firebase_auth.dart' as auth;

abstract class RepositoryInterface {
  /// Create
  void createUserInDatabaseWithEmail(auth.User user);
}
