import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:Gemu/models/user.dart';
import 'package:Gemu/models/post.dart';

class FirestoreService {
  final CollectionReference _usersCollectionReference =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference _postsCollectionReference =
      FirebaseFirestore.instance.collection('posts');

  final StreamController<List<Post>> _postsController =
      StreamController<List<Post>>.broadcast();

  Future addPost(Post post) async {
    try {
      await _postsCollectionReference.add(post.toMap());
    } catch (e) {
      if (e is PlatformException) {
        return e.message;
      }

      return e.toString();
    }
  }

  Stream listenToPostsRealTime() {
    // Register the handler for when the posts data changes
    _postsCollectionReference.snapshots().listen((postsSnapshot) {
      if (postsSnapshot.docs.isNotEmpty) {
        var posts = postsSnapshot.docs
            .map((snapshot) => Post.fromMap(snapshot.data(), snapshot.id))
            .where((mappedItem) => mappedItem.imageFileName != null)
            .toList();

        // Add the posts onto the controller
        _postsController.add(posts);
      }
    });

    return _postsController.stream;
  }

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

  Future updateUserPseudo(String name, String uid) async {
    return await _usersCollectionReference.doc(uid).update({'pseudo': name});
  }

  Future updateUserImgProfile(String image, String uid) async {
    return await _usersCollectionReference.doc(uid).update({'photoURL': image});
  }

  Future updateUserEmail(String email, String uid) async {
    return await _usersCollectionReference.doc(uid).update({'email': email});
  }

  Future deleteUserImgProfile(String uid) async {
    return await _usersCollectionReference.doc(uid).update({'photoURL': null});
  }

  UserC _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserC(
      email: snapshot.data()['email'],
      pseudo: snapshot.data()['pseudo'],
      photoURL: snapshot.data()['photoURL'],
    );
  }

  Stream<UserC> userData(String uid) {
    return _usersCollectionReference
        .doc(uid)
        .snapshots()
        .map(_userDataFromSnapshot);
  }
}
