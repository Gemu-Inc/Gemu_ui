import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/core/repository/RepositoryInterface.dart';

class FirebaseRepository with ChangeNotifier implements RepositoryInterface {
  FirebaseRepository();

  final firestoreInstance = FirebaseFirestore.instance;

  static const String USERS_COLLECTION = 'users';

  static const String NAME_FIELD = 'name';
  static const String EMAIL_FIELD = 'email';

  void createUserInDatabaseWithEmail(auth.User firebaseUser) async {
    await firestoreInstance
        .collection(USERS_COLLECTION)
        .doc(firebaseUser.uid)
        .set({
      NAME_FIELD: firebaseUser.displayName,
      EMAIL_FIELD: firebaseUser.email,
    });
  }
}
