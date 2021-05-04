import 'dart:async';
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:Gemu/models/user.dart';
import 'package:Gemu/models/convo.dart';
import 'package:Gemu/models/post.dart';
import 'package:Gemu/models/categorie.dart';
import 'package:Gemu/models/game.dart';

class DatabaseService {
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

  UserModel _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserModel(
        id: snapshot.data()['id'],
        email: snapshot.data()['email'],
        pseudo: snapshot.data()['pseudo'],
        photoURL: snapshot.data()['photoURL'],
        idGames: List<String>.from(snapshot.data()['idGames'].map((item) {
          return item;
        }).toList()));
  }

  Stream<UserModel> userData(String uid) {
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

  Future createUser(UserModel user) async {
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

      return UserModel.fromMap(userData.data());
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

  //Partie messagerie

  static Stream<List<UserModel>> streamUsers() {
    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .map((QuerySnapshot list) => list.docs
            .map((DocumentSnapshot snap) => UserModel.fromMap(snap.data()))
            .toList())
        .handleError((dynamic e) {
      print(e);
    });
  }

  static Stream<List<UserModel>> getUsersByList(List<String> userIds) {
    final List<Stream<UserModel>> streams = List();
    for (String id in userIds) {
      streams.add(FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .snapshots()
          .map((DocumentSnapshot snap) => UserModel.fromMap(snap.data())));
    }
    return StreamZip<UserModel>(streams).asBroadcastStream();
  }

  static Stream<List<Convo>> streamConversations(String uid) {
    return FirebaseFirestore.instance
        .collection('messages')
        .orderBy('lastMessage.timestamp', descending: true)
        .where('users', arrayContains: uid)
        .snapshots()
        .map((QuerySnapshot list) => list.docs
            .map((DocumentSnapshot doc) => Convo.fromFirestore(doc))
            .toList());
  }

  static void sendMessage(
      String convoID, String id, String pid, String content, String timestamp) {
    final DocumentReference convoDoc =
        FirebaseFirestore.instance.collection('messages').doc(convoID);

    convoDoc.set(<String, dynamic>{
      'lastMessage': <String, dynamic>{
        'idFrom': id,
        'idTo': pid,
        'timestamp': timestamp,
        'content': content,
        'read': false
      },
      'users': <String>[id, pid]
    }).then((dynamic success) {
      final DocumentReference messageDoc = FirebaseFirestore.instance
          .collection('messages')
          .doc(convoID)
          .collection(convoID)
          .doc(timestamp);

      FirebaseFirestore.instance
          .runTransaction((Transaction transaction) async {
        transaction.set(messageDoc, <String, dynamic>{
          'idFrom': id,
          'idTo': pid,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'content': content,
          'read': false
        });
      });
    });
  }

  static void updateMessageRead(DocumentSnapshot doc, String convoID) {
    final DocumentReference documentReference = FirebaseFirestore.instance
        .collection('messages')
        .doc(convoID)
        .collection(convoID)
        .doc(doc.id);

    documentReference
        .set(<String, dynamic>{'read': true}, SetOptions(merge: true));
  }

  static void updateLastMessage(
      DocumentSnapshot doc, String uid, String pid, String convoID) {
    final DocumentReference documentReference =
        FirebaseFirestore.instance.collection('messages').doc(convoID);

    documentReference
        .set(<String, dynamic>{
          'lastMessage': <String, dynamic>{
            'idFrom': doc['idFrom'],
            'idTo': doc['idTo'],
            'timestamp': doc['timestamp'],
            'content': doc['content'],
            'read': doc['read']
          },
          'users': <String>[uid, pid]
        })
        .then((dynamic success) {})
        .catchError((dynamic error) {
          print(error);
        });
  }
}
