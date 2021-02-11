import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:Gemu/models/user.dart';
import 'package:Gemu/models/post.dart';
import 'package:Gemu/models/categorie.dart';
import 'package:Gemu/models/game.dart';

class FirestoreService {
  final CollectionReference _usersCollectionReference =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference _postsCollectionReference =
      FirebaseFirestore.instance.collection('posts');
  final CollectionReference _categoriesCollectionReference =
      FirebaseFirestore.instance.collection('categories');
  final CollectionReference _gamesCollectionReference =
      FirebaseFirestore.instance.collection('games');

  final StreamController<List<Post>> _postsController =
      StreamController<List<Post>>.broadcast();
  final StreamController<List<Categorie>> _categoriesController =
      StreamController<List<Categorie>>.broadcast();
  final StreamController<List<Game>> _gamesController =
      StreamController<List<Game>>.broadcast();

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

  Stream listenToGamesRealTime() {
    FirebaseFirestore.instance
        .collection('games')
        .snapshots()
        .listen((gamesSnapshot) {
      if (gamesSnapshot.docs.isNotEmpty) {
        var games = gamesSnapshot.docs
            .map((snapshot) => Game.fromMap(snapshot.data(), snapshot.id))
            .toList();
        _gamesController.add(games);
      }
    });

    return _gamesController.stream;
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

  Stream listenToCategoriesRealTime() {
    // Register the handler for when the posts data changes
    _categoriesCollectionReference.snapshots().listen((categoriesSnapshot) {
      if (categoriesSnapshot.docs.isNotEmpty) {
        var categories = categoriesSnapshot.docs
            .map((snapshot) => Categorie.fromMap(snapshot.data(), snapshot.id))
            .toList();

        // Add the posts onto the controller
        _categoriesController.add(categories);
      }
    });

    return _categoriesController.stream;
  }

  UserC _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserC(
        id: snapshot.data()['id'],
        email: snapshot.data()['email'],
        pseudo: snapshot.data()['pseudo'],
        photoURL: snapshot.data()['photoURL'],
        idGames: List<String>.from(snapshot.data()['idGames'].map((item) {
          return item;
        }).toList()));
  }

  Stream<UserC> userData(String uid) {
    return _usersCollectionReference
        .doc(uid)
        .snapshots()
        .map(_userDataFromSnapshot);
  }

  Stream<List<Game>> getGamesFollow(List<dynamic> snapshot) {
    return _gamesCollectionReference
        .where(FieldPath.documentId, whereIn: snapshot)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((document) => Game.fromMap(document.data(), document.id))
            .toList());
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
}
