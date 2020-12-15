import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:Gemu/models/user.dart';

class FirestoreService {
  final CollectionReference _usersCollectionReference =
      FirebaseFirestore.instance.collection('users');
  final String uid;
  FirestoreService({this.uid});

  Future createUser(UserC user) async {
    try {
      await _usersCollectionReference.doc(user.id).set(user.toJson());
    } catch (e) {
      if (e is PlatformException) {
        return e.message;
      }

      return e.toString();
    }
  }

  Future getUser(String uid) async {
    try {
      var userData = await _usersCollectionReference.doc(uid).get();
      print('${userData.data()}');
      return UserC.fromData(userData.data());
    } catch (e) {
      if (e is PlatformException) {
        return e.message;
      }

      return e.toString();
    }
  }

  Future updateUserPseudo(String name) async {
    return await _usersCollectionReference.doc(uid).update({'pseudo': name});
  }

  Future updateUserImgProfile(String image, String uid) async {
    return await _usersCollectionReference.doc(uid).update({'photoURL': image});
  }

  Future deleteUserImgProfile(String uid) async {
    return await _usersCollectionReference.doc(uid).update({'photoURL': null});
  }

  UserC _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserC(
      id: uid,
      pseudo: snapshot.data()['pseudo'],
      photoURL: snapshot.data()['photoURL'],
    );
  }

  Stream<UserC> get userData {
    return _usersCollectionReference
        .doc(uid)
        .snapshots()
        .map(_userDataFromSnapshot);
  }
}
