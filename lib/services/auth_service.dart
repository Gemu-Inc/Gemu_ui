import 'dart:async';
import 'package:country_calling_code_picker/country.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemu/riverpod/Register/register_provider.dart';

import 'package:gemu/services/database_service.dart';
import 'package:gemu/widgets/snack_bar_custom.dart';
import 'package:gemu/models/game.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  //Voir les changements au niveau de la connexion de l'utilisateur sur le device
  static Stream<User?> authStateChange() => _auth.authStateChanges();

  //Check pour la connexion d'un compte
  static Future<void> signIn(
      {required BuildContext context,
      required String email,
      required String password}) async {
    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'invalid-email') {
          messageUser(context, 'Try again, invalid email');
        } else if (e.code == 'user-disabled') {
          messageUser(context, "Try again, user disabled");
        } else if (e.code == 'user-not-found') {
          messageUser(context, 'Try again, user not found for that email');
        } else if (e.code == 'wrong-password') {
          messageUser(context, 'Try again, wrong password for that user');
        } else {
          messageUser(context, 'Try again');
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBarCustom(
        context: context,
        error: 'Try again, no email or password',
      ));
    }
  }

  //Créer un utilisateur
  static Future<void> registerUser(
      BuildContext context,
      String email,
      String password,
      String username,
      DateTime dateBirthday,
      String country,
      List<Game> gamesFollow,
      WidgetRef ref) async {
    try {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) async {
        String uid = value.user!.uid;
        Map<String, dynamic> map = {
          'id': uid,
          'imageUrl': null,
          'privacy': 'public',
          'email': email,
          'username': username,
          'dateBirthday': dateBirthday,
          'country': country,
        };
        try {
          await DatabaseService.addUser(uid, gamesFollow, map);
          ref.read(successRegisterNotifierProvider.notifier).updateSuccess();
          messageUser(context,
              "Compte créé avec succès, vous allez être redirigé dans quelques instants");
        } catch (e) {
          messageUser(context,
              "Un problème est survenu, veuillez réessayer ultérieurement");
        }
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        messageUser(context, "Email already use, try again");
      } else if (e.code == 'invalid-email') {
        messageUser(context, "Invalid email, try again");
      } else if (e.code == 'operation-not-allowed') {
        messageUser(context, "Operation not allowed");
      } else if (e.code == 'weak-password') {
        messageUser(context, "Weak password, try again");
      } else {
        messageUser(context,
            "Un problème est survenu, veuillez réessayer ultérieurement");
      }
    }
  }

  //Fonction de déconnexion de l'application
  static Future signOut() => _auth.signOut();

  //Update email utilisateur
  static Future updateEmail(
      {required String password, required String newEmail}) async {
    try {
      var email = _auth.currentUser!.email;
      AuthCredential authCredential =
          EmailAuthProvider.credential(email: email!, password: password);
      UserCredential authResult = await FirebaseAuth.instance.currentUser!
          .reauthenticateWithCredential(authCredential);
      await authResult.user!.updateEmail(newEmail);
    } catch (e) {
      return print(e);
    }
  }

  //Update password utilisateur
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
