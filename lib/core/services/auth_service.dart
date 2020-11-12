import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:Gemu/core/repository/firebase_repository.dart';

class AuthService with ChangeNotifier {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  Stream<String> get onAuthStateChanged => _auth.authStateChanges().map(
        (auth.User user) => user?.uid,
      );

  //Get current user
  Future<auth.User> getUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        print('User signed in: ${user.email}');
      } else {
        print('No user signed in');
      }
      notifyListeners();
      return user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Sign Out
  Future signOut() async {
    var result = await auth.FirebaseAuth.instance.signOut();
    print('Signing out user');
    notifyListeners();
    return result;
  }

  // Email & Password Register
  Future<auth.User> registerUserWithEmailAndPassword(
      {String name, String email, String password}) async {
    var userCredential = await auth.FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    // FirebaseUser
    var newUser = userCredential.user;

    await newUser
        .updateProfile(displayName: name)
        .catchError((error) => print(error));

    // Refresh data
    await newUser.reload();

    // Need to make this call to get the updated display name; or else display name will be null
    auth.User updatedUser = auth.FirebaseAuth.instance.currentUser;

    print('new display name: ${updatedUser.displayName}');

    notifyListeners();

    // Return FirebaseUser with updated information
    return updatedUser;
  }

  //Update the username
  Future updateUserName(String name, auth.User currentUser) async {
    await currentUser.updateProfile(displayName: name);
    await currentUser.reload();
  }

  // Email & Password Sign In
  Future<auth.User> signInUserWithEmailAndPassword(
      {String email, String password}) async {
    try {
      var result = await auth.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      // since something changed, let's notify the listeners...
      notifyListeners();
      return result.user;
    } catch (firebaseAuthException) {
      throw new auth.FirebaseAuthException(
          message: firebaseAuthException.message,
          code: firebaseAuthException.code);
    }
  }

  // Reset Password
  Future sendPasswordResetEmail(String email) async {
    return _auth.sendPasswordResetEmail(email: email);
  }

  // Create Anonymous User
  Future singInAnonymously() {
    return _auth.signInAnonymously();
  }

  Future convertUserWithEmail(
      String email, String password, String name) async {
    final currentUser = _auth.currentUser;

    final credential =
        auth.EmailAuthProvider.credential(email: email, password: password);
    await currentUser.linkWithCredential(credential);
    await updateUserName(name, currentUser);
  }
}

class NameValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return "Name can't be empty";
    }
    if (value.length < 2) {
      return "Name must be at least 2 characters long";
    }
    if (value.length > 50) {
      return "Name must be less than 50 characters long";
    }
    return null;
  }
}

class EmailValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return "Email can't be empty";
    }
    return null;
  }
}

class PasswordValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return "Password can't be empty";
    }
    return null;
  }
}
