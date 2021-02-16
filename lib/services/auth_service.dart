import 'dart:async';
import 'package:Gemu/locator.dart';
import 'package:Gemu/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:Gemu/services/firestore_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = locator<FirestoreService>();

  // GET change about status connection
  Stream<User> get onAuthStateChanged => _firebaseAuth.authStateChanges();

  // GET UID
  Future<String> getCurrentUID() async {
    var currentUser = _firebaseAuth.currentUser.uid;
    print(currentUser);
    return currentUser;
  }

  UserC _currentUser;
  UserC get currentUser => _currentUser;

  Future updateEmail(
      {@required String password, @required String newEmail}) async {
    var user = _firebaseAuth.currentUser;
    try {
      var authResult = await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(email: user.email, password: password));
      await authResult.user.updateEmail(newEmail);
    } catch (e) {
      return e.message;
    }
  }

  Future updatePassword(
      {@required String currentPassword, @required String newPassword}) async {
    var user = _firebaseAuth.currentUser;
    try {
      var authResult = await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(
              email: user.email, password: currentPassword));
      await authResult.user.updatePassword(newPassword);
    } catch (e) {
      return e.message;
    }
  }

  Future loginWithEmail({
    @required String email,
    @required String password,
  }) async {
    try {
      var authResult = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _populateCurrentUser(authResult.user);
      return authResult.user != null;
    } catch (e) {
      return e.message;
    }
  }

  Future signUpWithEmail({
    @required String email,
    @required String password,
    @required String pseudo,
    @required String photoURL,
    @required String points,
  }) async {
    try {
      var authResult = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // create a new user profile on firestore
      _currentUser = UserC(
          id: authResult.user.uid,
          email: email,
          pseudo: pseudo,
          photoURL: photoURL,
          points: points);

      await _firestoreService.createUser(_currentUser);

      return authResult.user != null;
    } catch (e) {
      return e.message;
    }
  }

  Future<bool> isUserLoggedIn() async {
    var user = _firebaseAuth.currentUser;
    await _populateCurrentUser(user);
    return user != null;
  }

  Future signOut() async {
    await _firebaseAuth.signOut();
    print('Signing out user');
  }

  Future _populateCurrentUser(User user) async {
    if (user != null) {
      _currentUser = await _firestoreService.getUser(user.uid);
      print('${_currentUser.pseudo} is log');
      return user;
    } else {
      print('No user log');
      return null;
    }
  }
}
