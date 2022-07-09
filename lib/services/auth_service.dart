import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemu/constants/constants.dart';
import 'package:gemu/providers/Navigation/nav_non_auth.dart';
import 'package:gemu/providers/Register/register_provider.dart';

import 'package:gemu/services/database_service.dart';
import 'package:gemu/components/snack_bar_custom.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/translations/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  //Voir les changements au niveau de la connexion de l'utilisateur sur le device
  static Stream<User?> authStateChange() => _auth.authStateChanges();

  //get current user
  static Future<User?> getUser() async {
    User? user = _auth.currentUser;
    return user;
  }

  static Future<void> setUserToken(User user) async {
    user.getIdToken().then((token) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      if (token != prefs.getString("token")) {
        prefs.setString("token", token);
      }
    });
  }

  //Check pour la connexion d'un compte
  static Future<User?> signIn(
      {required BuildContext context,
      required String email,
      required String password}) async {
    User? user;

    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        user = await AuthService.getUser();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-disabled') {
          messageUser(
              context,
              AppLocalization.of(context)
                  .translate("message_user", "user_disabled"));
        } else if (e.code == 'user-not-found') {
          messageUser(
              context,
              AppLocalization.of(context)
                  .translate("message_user", "wrong_mail"));
        } else if (e.code == 'wrong-password') {
          messageUser(
              context,
              AppLocalization.of(context)
                  .translate("message_user", "wrong_password"));
        } else {
          messageUser(
              context,
              AppLocalization.of(context)
                  .translate("message_user", "try_again"));
        }
      }
    }
    return user;
  }

  //Check pour la connexion/inscription d'un compte via Google
  static Future<void> signWithGoogle(WidgetRef ref) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.disconnect().catchError((e, stack) {
      print(e);
    });
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential authCredential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      // Getting users credential
      UserCredential result = await _auth.signInWithCredential(authCredential);
      User? user = result.user;

      if (user != null) {
        bool exist = await DatabaseService.userAlreadyExist(user.uid);
        if (exist) {
          await AuthService.setUserToken(user);
          await DatabaseService.getUserData(user, ref);
        } else {
          navNonAuthKey.currentState!
              .pushNamed(Register, arguments: [true, user]);
        }
      }
    } else {
      return null;
    }
  }

  //Créer un utilisateur
  static Future<User?> registerUser(
      BuildContext context,
      String email,
      String password,
      String username,
      DateTime dateBirthday,
      String country,
      List<Game> gamesFollow,
      WidgetRef ref) async {
    User? user;
    try {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) async {
        String uid = value.user!.uid;
        Map<String, dynamic> map = {
          'id': uid,
          'imageUrl': null,
          'privacy': 'public',
          'verified_account': false,
          'email': email,
          'username': username,
          'dateBirthday': dateBirthday,
          'country': country,
        };
        try {
          await DatabaseService.addUser(uid, gamesFollow, map);
          ref.read(successRegisterNotifierProvider.notifier).updateSuccess();
          messageUser(
              context,
              AppLocalization.of(context)
                  .translate("message_user", "create_account_success"));
          user = await AuthService.getUser();
        } catch (e) {
          messageUser(context,
              AppLocalization.of(context).translate("message_user", "problem"));
        }
      });
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        messageUser(
            context,
            AppLocalization.of(context)
                .translate("message_user", "already_use_mail"));
      } else if (e.code == 'operation-not-allowed') {
        messageUser(
            context,
            AppLocalization.of(context)
                .translate("message_user", "operation_not_allowed"));
      } else if (e.code == 'weak-password') {
        messageUser(
            context,
            AppLocalization.of(context)
                .translate("message_user", "weak_password"));
      } else {
        messageUser(context,
            AppLocalization.of(context).translate("message_user", "problem"));
      }
      return null;
    }
  }

  //Register user with credentials google/apple
  static Future<User?> registerUserSocials(
      BuildContext context,
      String email,
      String username,
      DateTime dateBirthday,
      String country,
      List<Game> gamesFollow,
      WidgetRef ref,
      String uid) async {
    User? user;
    Map<String, dynamic> map = {
      'id': uid,
      'imageUrl': null,
      'privacy': 'public',
      'verified_account': false,
      'email': email,
      'username': username,
      'dateBirthday': dateBirthday,
      'country': country,
    };
    try {
      await DatabaseService.addUser(uid, gamesFollow, map);
      ref.read(successRegisterNotifierProvider.notifier).updateSuccess();
      messageUser(
          context,
          AppLocalization.of(context)
              .translate("message_user", "create_account_success"));
      user = await AuthService.getUser();
    } catch (e) {
      messageUser(context,
          AppLocalization.of(context).translate("message_user", "problem"));
    }
    return user;
  }

  //Delete account firebase auth
  static Future<void> deleteAccount(BuildContext context, User user) async {
    try {
      await user.delete();
    } catch (e) {
      messageUser(
          context,
          AppLocalization.of(context)
              .translate("message_user", "oups_problem"));
    }
  }

  //Send mail reset password
  static Future<void> sendMailResetPassword(
      String email, BuildContext context) async {
    await _auth
        .sendPasswordResetEmail(email: email)
        .then((value) => messageUser(
            context,
            AppLocalization.of(context)
                .translate("message_user", "forgot_password_success")))
        .catchError((e) {
      print(e);
      messageUser(
          context,
          AppLocalization.of(context)
              .translate("message_user", "oups_error_mail"));
    });
  }

  //Send mail verify email
  static Future<void> sendMailVerifyEmail(BuildContext context) async {
    await _auth.currentUser!
        .sendEmailVerification()
        .then((value) => messageUser(
            context,
            AppLocalization.of(context)
                .translate("message_user", "send_verif_mail_success")))
        .catchError((e) {
      print(e);
      messageUser(
          context,
          AppLocalization.of(context)
              .translate("message_user", "oups_error_mail"));
    });
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
