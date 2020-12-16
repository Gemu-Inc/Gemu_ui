import 'dart:async';
import 'package:Gemu/locator.dart';
import 'package:Gemu/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:Gemu/services/firestore_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = locator<FirestoreService>();

  UserC _currentUser;
  UserC get currentUser => _currentUser;

  Future updateEmail({@required String email}) async {
    try {
      var user = _firebaseAuth.currentUser;
      await user.updateEmail(email);
      return user != null;
    } catch (e) {
      return e.message;
    }
  }

  Future updatePassword({@required String password}) async {
    try {
      var user = _firebaseAuth.currentUser;
      await user.updatePassword(password);
      return user != null;
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
