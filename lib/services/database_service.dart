import 'dart:async';
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gemu/models/user.dart';
import 'package:gemu/models/convo.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/riverpod/Register/searching_game.dart';

class DatabaseService {
  //references des collections de la bdd
  static final CollectionReference usersCollectionReference =
      FirebaseFirestore.instance.collection('users');

//Partie register

  //Récupérer les 12 premiers jeux de la bdd pour la partie inscription
  static Future<bool> getGamesRegister(WidgetRef ref) async {
    List<Game> allGames = [];

    await FirebaseFirestore.instance
        .collection('games')
        .doc('verified')
        .collection('games_verified')
        .orderBy('name')
        .limit(12)
        .get()
        .then((value) {
      for (var item in value.docs) {
        allGames.add(Game.fromMap(item, item.data()));
      }
    });
    ref.read(allGamesRegisterNotifierProvider.notifier).initGames(allGames);

    return true;
  }

  //Récupère 12 nouveaux jeux dans la bdd pour la partie inscription
  static Future<void> loadMoreGamesRegister(WidgetRef ref, Game game) async {
    List<Game> newGames = [];

    await FirebaseFirestore.instance
        .collection('games')
        .doc('verified')
        .collection('games_verified')
        .orderBy('name')
        .startAfterDocument(game.snapshot!)
        .limit(12)
        .get()
        .then((value) {
      for (var item in value.docs) {
        newGames.add(Game.fromMap(item, item.data()));
      }
    });

    ref.read(allGamesRegisterNotifierProvider.notifier).loadMoreGame(newGames);
    ref.read(newGamesRegisterNotifierProvider.notifier).seeNewGames(newGames);
  }

  //Vérification du pseudo pour éviter les doublons dans la base
  static Future verifPseudo(String username) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: username)
        .get();
  }

  //Ajout d'un nouvel utilisateur dans la base
  static Future<void> addUser(
      String uid, List<Game> gamesFollow, Map<String, dynamic> map) async {
    await usersCollectionReference.doc(uid).set(map);
    for (var i = 0; i < gamesFollow.length; i++) {
      await usersCollectionReference
          .doc(uid)
          .collection('games')
          .doc(gamesFollow[i].name)
          .set({
        'name': gamesFollow[i].name,
        'imageUrl': gamesFollow[i].imageUrl
      });
    }
  }

  //recherche d'un compte vérifié ou non dans la base
  static Future<UserModel?> searchVerifiedAccount(String email) async {
    UserModel? userData;
    await usersCollectionReference
        .where("email", isEqualTo: email)
        .get()
        .then((value) {
      for (var item in value.docs) {
        userData = UserModel.fromMap(item, item.data() as Map<String, dynamic>);
      }
    });
    return userData;
  }

  //Update verify account
  static Future<void> updateVerifyAccount(String uid) async {
    await usersCollectionReference.doc(uid).update({"verify_account": true});
  }

//Others parties

  //partie réglages "Mon compte"
  static Future updateUserImgProfile(String? image, String uid) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'imageUrl': image});
  }

  static Future deleteUserImgProfile(String uid) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'imageUrl': null});
  }

  static Future updateUserPseudo(String? name, String? uid) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'username': name});
  }

  static Future updateUserEmail(String? email, String? uid) async {
    return await usersCollectionReference.doc(uid).update({'email': email});
  }

  //Partie Highlights

  //Partie messagerie

  static Stream<List<UserModel>> streamUsers() {
    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .map((QuerySnapshot list) => list.docs
            .map((DocumentSnapshot snap) =>
                UserModel.fromMap(snap, snap.data() as Map<String, dynamic>))
            .toList())
        .handleError((dynamic e) {
      print(e);
    });
  }

  static Stream<List<UserModel>> getUsersByList(List<String> userIds) {
    final List<Stream<UserModel>> streams = [];
    for (String id in userIds) {
      streams.add(FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .snapshots()
          .map((DocumentSnapshot snap) {
        return UserModel.fromMap(snap, snap.data() as Map<String, dynamic>);
      }));
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

  static void sendMessage(String? convoID, String? id, String? pid,
      String content, String timestamp) {
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
      'users': <String?>[id, pid]
    }).then((dynamic success) {
      final DocumentReference messageDoc = FirebaseFirestore.instance
          .collection('messages')
          .doc(convoID)
          .collection(convoID!)
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

  //Partie Notifications
  static void addNotification(
      String from, String to, String text, String type) {
    FirebaseFirestore.instance
        .collection('notifications')
        .doc(to)
        .collection('singleNotif')
        .add({
      'from': from,
      'text': text,
      'type': type,
      'seen': false,
      'date': DateTime.now().millisecondsSinceEpoch.toInt()
    });
  }
}
