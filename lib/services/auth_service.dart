import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:gemu/services/database_service.dart';
import 'package:gemu/ui/controller/log_controller.dart';
import 'package:gemu/ui/controller/navigation_controller.dart';
import 'package:gemu/ui/widgets/snack_bar_custom.dart';
import 'package:gemu/models/game.dart';

class AuthService {
  static final instance = AuthService._();
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  bool get isSignedIn => _auth.currentUser != null;

  //Voir les changements au niveau de la connexion de l'utilisateur sur le device
  Stream<User?> authStateChange() => _auth.authStateChanges();

  //Se connecter
  Future<void> signIn(
      {required BuildContext context,
      required String email,
      required String password}) async {
    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        await Future.delayed(Duration(seconds: 1));
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    NavController(uid: _auth.currentUser!.uid)),
            (route) => false);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'invalid-email') {
          print('Invalid email');
          ScaffoldMessenger.of(context).showSnackBar(SnackBarCustom(
            context: context,
            error: 'Try again, invalid email',
            padddingVertical: 40.0,
          ));
        } else if (e.code == 'user-disabled') {
          print('user disabled');
          ScaffoldMessenger.of(context).showSnackBar(SnackBarCustom(
            context: context,
            error: 'Try again, user disabled',
            padddingVertical: 40.0,
          ));
        } else if (e.code == 'user-not-found') {
          print('No user found for that email.');
          ScaffoldMessenger.of(context).showSnackBar(SnackBarCustom(
            context: context,
            error: 'Try again, user not found for that email',
            padddingVertical: 40.0,
          ));
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
          ScaffoldMessenger.of(context).showSnackBar(SnackBarCustom(
            context: context,
            error: 'Try again, wrong password for that user',
            padddingVertical: 40.0,
          ));
        } else {
          print('Try again');
          ScaffoldMessenger.of(context).showSnackBar(SnackBarCustom(
            context: context,
            error: 'Try again',
            padddingVertical: 40.0,
          ));
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBarCustom(
        context: context,
        error: 'Try again, no email or password',
        padddingVertical: 40.0,
      ));
    }
  }

  //Créer un utilisateur
  Future<void> registerUser(
      BuildContext context,
      List<Game> gamesFollow,
      String username,
      String email,
      String password,
      String confirmPassword,
      String country) async {
    try {
      final UserCredential user = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      String uid = user.user!.uid;
      Map<String, dynamic> map = {
        'id': uid,
        'email': email,
        'username': username,
        'imageUrl': null,
        'country': country
      };
      await DatabaseService.instance.addUser(uid, gamesFollow, map);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => NavController(uid: uid)),
          (route) => false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBarCustom(
          context: context,
          error: 'Email already use, try again',
          padddingVertical: 40.0,
        ));
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBarCustom(
          context: context,
          error: 'Invalid email, try again',
          padddingVertical: 40.0,
        ));
      } else if (e.code == 'operation-not-allowed') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBarCustom(
          context: context,
          error: 'Operation not allowed',
          padddingVertical: 40.0,
        ));
      } else if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBarCustom(
          context: context,
          error: 'Weak password, try again',
          padddingVertical: 40.0,
        ));
      }
    }
  }

  //Fonction de déconnexion de l'application
  Future signOut() => _auth.signOut();

  //Update
  static Future updateEmail(
      {required String password, required String newEmail}) async {
    try {
      var email = FirebaseAuth.instance.currentUser!.email;
      AuthCredential authCredential =
          EmailAuthProvider.credential(email: email!, password: password);
      UserCredential authResult = await FirebaseAuth.instance.currentUser!
          .reauthenticateWithCredential(authCredential);
      await authResult.user!.updateEmail(newEmail);
    } catch (e) {
      return print(e);
    }
  }

  static Future updatePassword(
      {required String currentPassword, required String newPassword}) async {
    var user = _auth.currentUser!;
    try {
      var authResult = await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(
              email: user.email!, password: currentPassword));
      await authResult.user!.updatePassword(newPassword);
    } catch (e) {
      return print(e);
    }
  }
}
