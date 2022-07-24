import 'dart:async';
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemu/components/snack_bar_custom.dart';

import 'package:gemu/models/user.dart';
import 'package:gemu/models/convo.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/providers/Games/games_discover_provider.dart';
import 'package:gemu/providers/Home/home_provider.dart';
import 'package:gemu/providers/Register/register_provider.dart';
import 'package:gemu/providers/Register/searching_game.dart';
import 'package:gemu/providers/Users/myself_provider.dart';

import '../constants/constants.dart';

class DatabaseService {
  //references des collections de la bdd
  static final CollectionReference usersCollectionReference =
      FirebaseFirestore.instance.collection('users');

//Partie register

  //Récupérer les 12 premiers jeux de la bdd pour la partie inscription
  static Future<void> getGamesRegister(WidgetRef ref) async {
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
    ref.read(loadingGamesRegisterNotifierProvider.notifier).updateLoading(true);
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

  //find if user already exist or not
  static Future<bool> userAlreadyExist(String uid) async {
    bool exist = false;
    var user = await usersCollectionReference.doc(uid).get();
    if (user.exists) {
      exist = true;
    }
    return exist;
  }

  //Get current user
  static Future<void> getCurrentUser(String uid, WidgetRef ref) async {
    await usersCollectionReference.doc(uid).get().then((value) async {
      ref.read(myselfNotifierProvider.notifier).initUser(
          UserModel.fromMap(value, value.data() as Map<String, dynamic>));
    });
  }

  //get data current user
  static Future<void> getUserData(User user, WidgetRef ref) async {
    List<Game> gamesList = [];
    List<PageController> gamePageController = [];

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('games')
        .get()
        .then((value) {
      for (var item in value.docs) {
        gamesList.add(Game.fromMap(item, item.data()));
        gamePageController.add(PageController());
      }
    });

    ref.read(myGamesNotifierProvider.notifier).initGames(gamesList);
    ref.read(gamesTabNotifierProvider.notifier).initGamesTab(gamesList);
    ref
        .read(myGamesControllerNotifierProvider.notifier)
        .initGamesController(gamePageController);
    ref
        .read(loadedDataGameProviderNotifier.notifier)
        .initLoadedDataGames(gamesList.length);
    ref
        .read(postsGameNotifierProvider.notifier)
        .initPostsGame(gamesList.length);

    await DatabaseService.getCurrentUser(user.uid, ref);
  }

  //recherche d'un compte vérifié ou non dans la base
  static Future<UserModel?> searchVerifiedAccount(String email) async {
    UserModel? userData;
    var user =
        await usersCollectionReference.where("email", isEqualTo: email).get();
    for (var item in user.docs) {
      userData = UserModel.fromMap(item, item.data() as Map<String, dynamic>);
    }
    return userData;
  }

  //Update verify account
  static Future<void> updateVerifyAccount(String uid) async {
    await usersCollectionReference.doc(uid).update({"verified_account": true});
  }

//Partie Home

//Récupérer les 12 premiers jeux de la bdd pour la partie add
  static Future<void> getGamesDiscover(
      BuildContext context, WidgetRef ref) async {
    List<Game> gamesFollow =
        ref.read(myGamesNotifierProvider.notifier).getMyGames;
    List<Game> allGames = [];

    try {
      await FirebaseFirestore.instance
          .collection('games')
          .doc('verified')
          .collection('games_verified')
          .orderBy('name')
          .limit(12)
          .get()
          .then((value) {
        for (var item in value.docs) {
          Game game = Game.fromMap(item, item.data());

          if (!gamesFollow.any((element) => element.name == game.name)) {
            allGames.add(Game.fromMap(item, item.data()));
          }
        }
      });

      ref.read(gamesDiscoverNotifierProvider.notifier).initGames(allGames);
      ref
          .read(loadingGamesDiscoverNotifierProvider.notifier)
          .updateLoading(true);
    } catch (e) {
      print(e);
      messageUser(context, "Oups, un problème est survenu!");
    }
  }

  //Récupère 12 nouveaux jeux dans la bdd pour la partie add
  static Future<void> loadMoreGamesDiscover(
      BuildContext context, WidgetRef ref, Game game) async {
    List<Game> newGames = [];
    List<Game> gamesFollow =
        ref.read(myGamesNotifierProvider.notifier).getMyGames;
    List<Game> gamesDiscover =
        ref.read(gamesDiscoverNotifierProvider.notifier).getGamesDiscover;

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
        Game game = Game.fromMap(item, item.data());

        if (!gamesFollow.any((element) => element.name == game.name) &&
            !gamesDiscover.any((element) => element.name == game.name)) {
          newGames.add(Game.fromMap(item, item.data()));
        }
      }
    });

    ref.read(gamesDiscoverNotifierProvider.notifier).loadMoreGame(newGames);
    ref.read(newGamesDiscoverNotifierProvider.notifier).seeNewGames(newGames);
  }

  //suivre un nouveau jeu pour son fil d'actualité
  static Future<void> followGame(
      BuildContext context, Game game, int index, WidgetRef ref) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(me!.uid)
          .collection('games')
          .doc(game.name)
          .set({"name": game.name, "imageUrl": game.imageUrl});
      ref.read(myGamesNotifierProvider.notifier).addGame(game);
      ref.read(gamesDiscoverNotifierProvider.notifier).removeGame(game);
      ref.read(modifGamesFollowsNotifierProvider.notifier).update(true);
    } catch (e) {
      messageUser(context, "Oups, un problème est survenu");
      print(e);
    }
  }

  //ne plus suivre un jeu pour son fil d'actualité
  static Future<void> unfollowGame(BuildContext context, Game game, int index,
      WidgetRef ref, List<Game> gamesList, bool stopReached) async {
    try {
      if (gamesList.length > 2) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(me!.uid)
            .collection('games')
            .doc(game.name)
            .delete();
        ref.read(myGamesNotifierProvider.notifier).removeGame(game);
        ref
            .read(gamesDiscoverNotifierProvider.notifier)
            .addGame(game, stopReached);
        ref.read(modifGamesFollowsNotifierProvider.notifier).update(true);
      } else {
        messageUser(context, "Vous devez au moins être abonné à 2 jeux");
      }
    } catch (e) {
      messageUser(context, "Oups, un problème est survenu");
      print(e);
    }
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
