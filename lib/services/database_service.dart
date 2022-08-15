import 'dart:async';
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemu/components/snack_bar_custom.dart';
import 'package:gemu/models/post.dart';

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

  ///Partie register/login

  //Récupérer les 12 premiers jeux de la bdd pour la partie inscription
  static Future<void> getGamesRegister(WidgetRef ref) async {
    List<Game> allGames = [];

    QuerySnapshot<Map<String, dynamic>> data = await FirebaseFirestore.instance
        .collection('games')
        .doc('verified')
        .collection('games_verified')
        .orderBy('name')
        .limit(12)
        .get();

    for (var item in data.docs) {
      allGames.add(Game.fromMap(item, item.data()));
    }

    ref.read(allGamesRegisterNotifierProvider.notifier).initGames(allGames);
    ref.read(loadingGamesRegisterNotifierProvider.notifier).updateLoading(true);
  }

  //Récupère 12 nouveaux jeux dans la bdd pour la partie inscription
  static Future<void> loadMoreGamesRegister(WidgetRef ref, Game game) async {
    List<Game> newGames = [];

    QuerySnapshot<Map<String, dynamic>> data = await FirebaseFirestore.instance
        .collection('games')
        .doc('verified')
        .collection('games_verified')
        .orderBy('name')
        .startAfterDocument(game.snapshot!)
        .limit(12)
        .get();

    for (var item in data.docs) {
      newGames.add(Game.fromMap(item, item.data()));
    }

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
          .set(Game(
                  documentId: gamesFollow[i].documentId,
                  name: gamesFollow[i].name,
                  imageUrl: gamesFollow[i].imageUrl,
                  categories: gamesFollow[i].categories)
              .toMap());
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
    List<UserModel> followings = [];

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

    QuerySnapshot<Map<String, dynamic>> userIDList = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(user.uid)
        .collection('following')
        .get();
    for (var element in userIDList.docs) {
      var user = await FirebaseFirestore.instance
          .collection("users")
          .doc(element.id)
          .get();
      followings
          .add(UserModel.fromMap(user, user.data() as Map<String, dynamic>));
    }

    ref.read(myGamesNotifierProvider.notifier).initGames(gamesList);
    ref.read(gamesTabNotifierProvider.notifier).initGamesTab(gamesList);
    ref.read(myFollowingsNotifierProvider.notifier).initFollowings(followings);

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
      QuerySnapshot<Map<String, dynamic>> data = await FirebaseFirestore
          .instance
          .collection('games')
          .doc('verified')
          .collection('games_verified')
          .orderBy('name')
          .limit(12)
          .get();

      for (var item in data.docs) {
        Game game = Game.fromMap(item, item.data());

        if (!gamesFollow.any((element) => element.name == game.name)) {
          allGames.add(Game.fromMap(item, item.data()));
        }
      }

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

    QuerySnapshot<Map<String, dynamic>> data = await FirebaseFirestore.instance
        .collection('games')
        .doc('verified')
        .collection('games_verified')
        .orderBy('name')
        .startAfterDocument(game.snapshot!)
        .limit(12)
        .get();

    for (var item in data.docs) {
      Game game = Game.fromMap(item, item.data());

      if (!gamesFollow.any((element) => element.name == game.name) &&
          !gamesDiscover.any((element) => element.name == game.name)) {
        newGames.add(Game.fromMap(item, item.data()));
      }
    }

    ref.read(gamesDiscoverNotifierProvider.notifier).loadMoreGame(newGames);
    ref.read(newGamesDiscoverNotifierProvider.notifier).seeNewGames(newGames);
  }

  //suivre un nouveau jeu pour son fil d'actualité
  static Future<bool> followGame(
      BuildContext context, Game game, WidgetRef ref) async {
    bool valid = false;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(me!.uid)
          .collection('games')
          .doc(game.name)
          .set(Game(
                  documentId: game.documentId,
                  name: game.name,
                  imageUrl: game.imageUrl,
                  categories: game.categories)
              .toMap());
      ref.read(myGamesNotifierProvider.notifier).addGame(game);
      ref.read(gamesDiscoverNotifierProvider.notifier).removeGame(game);
      ref.read(gamesTabNotifierProvider.notifier).addGameTab(game);
      await FirebaseFirestore.instance
          .collection('games')
          .doc("verified")
          .collection("games_verified")
          .doc(game.name)
          .collection("followers")
          .doc(me!.uid)
          .set({});
      valid = true;
    } catch (e) {
      messageUser(context, "Oups, un problème est survenu");
      print(e);
    }
    return valid;
  }

  //ne plus suivre un jeu pour son fil d'actualité
  static Future<bool> unfollowGame(BuildContext context, Game game,
      WidgetRef ref, List<Game> gamesList, bool stopReached) async {
    bool valid = false;
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
        ref.read(gamesTabNotifierProvider.notifier).removeGameTab(game);
        await FirebaseFirestore.instance
            .collection('games')
            .doc("verified")
            .collection("games_verified")
            .doc(game.name)
            .collection("followers")
            .doc(me!.uid)
            .delete();
        valid = true;
      } else {
        messageUser(context, "Vous devez au moins être abonné à 2 jeux");
      }
    } catch (e) {
      messageUser(context, "Oups, un problème est survenu");
      print(e);
    }
    return valid;
  }

  //get posts current user's games followings
  static Future<List<Post>> getPostsGamesFollows(List<Game> games) async {
    List<Post> posts = [];
    List<String> gamesID = [];

    for (var i = 0; i < games.length; i++) {
      gamesID.add(games[i].documentId);
    }

    QuerySnapshot<Map<String, dynamic>> data = await FirebaseFirestore.instance
        .collection('posts')
        .where('idGame', whereIn: gamesID)
        .where('privacy', isEqualTo: 'Public')
        .orderBy('date', descending: true)
        .limit(6)
        .get();

    for (var item in data.docs) {
      if (item.data()['uid'] != me!.uid) {
        DocumentSnapshot<Map<String, dynamic>> dataUser =
            await FirebaseFirestore.instance
                .collection("users")
                .doc(item.data()['uid'])
                .get();
        DocumentSnapshot<Map<String, dynamic>> dataGame =
            await FirebaseFirestore.instance
                .collection("games")
                .doc("verified")
                .collection("games_verified")
                .doc(item.data()["idGame"])
                .get();
        posts.add(Post.fromMap(
            item, item.data(), dataUser.data()!, dataGame.data()!));
      }
    }

    return posts;
  }

  //get more posts current user's games followings
  static Future<List<Post>> getMorePostsGamesFollows(
      List<Game> games, Post lastPost) async {
    List<Post> posts = [];
    List<String> gamesID = [];

    for (var i = 0; i < games.length; i++) {
      gamesID.add(games[i].documentId);
    }

    QuerySnapshot<Map<String, dynamic>> data = await FirebaseFirestore.instance
        .collection('posts')
        .where('idGame', whereIn: gamesID)
        .where('privacy', isEqualTo: 'Public')
        .orderBy('date', descending: true)
        .startAfterDocument(lastPost.snapshot!)
        .limit(3)
        .get();

    for (var item in data.docs) {
      if (item.data()['uid'] != me!.uid) {
        DocumentSnapshot<Map<String, dynamic>> dataUser =
            await FirebaseFirestore.instance
                .collection("users")
                .doc(item.data()['uid'])
                .get();
        DocumentSnapshot<Map<String, dynamic>> dataGame =
            await FirebaseFirestore.instance
                .collection("games")
                .doc("verified")
                .collection("games_verified")
                .doc(item.data()["idGame"])
                .get();
        posts.add(Post.fromMap(
            item, item.data(), dataUser.data()!, dataGame.data()!));
      }
    }

    return posts;
  }

  //get posts curent user's followings
  static Future<List<Post>> getPostsFollowings(
      List<UserModel> followings) async {
    List<Post> posts = [];
    List<String> uidFollowings = [];

    for (var i = 0; i < followings.length; i++) {
      uidFollowings.add(followings[i].uid);
    }

    QuerySnapshot<Map<String, dynamic>> data = await FirebaseFirestore.instance
        .collection('posts')
        .where('uid', whereIn: uidFollowings)
        .orderBy('date', descending: true)
        .limit(6)
        .get();

    for (var item in data.docs) {
      DocumentSnapshot<Map<String, dynamic>> dataUser = await FirebaseFirestore
          .instance
          .collection("users")
          .doc(item.data()['uid'])
          .get();
      DocumentSnapshot<Map<String, dynamic>> dataGame = await FirebaseFirestore
          .instance
          .collection("games")
          .doc("verified")
          .collection("games_verified")
          .doc(item.data()["idGame"])
          .get();
      posts.add(
          Post.fromMap(item, item.data(), dataUser.data()!, dataGame.data()!));
    }

    return posts;
  }

  //get more posts current user's followings
  static Future<List<Post>> getMorePostsFollowings(
      List<UserModel> followings, Post lastPost) async {
    List<Post> posts = [];
    List<String> uidFollowings = [];

    for (var i = 0; i < followings.length; i++) {
      uidFollowings.add(followings[i].uid);
    }

    QuerySnapshot<Map<String, dynamic>> data = await FirebaseFirestore.instance
        .collection('posts')
        .where('uid', whereIn: uidFollowings)
        .orderBy('date', descending: true)
        .startAfterDocument(lastPost.snapshot!)
        .limit(3)
        .get();

    for (var item in data.docs) {
      DocumentSnapshot<Map<String, dynamic>> dataUser = await FirebaseFirestore
          .instance
          .collection("users")
          .doc(item.data()['uid'])
          .get();
      DocumentSnapshot<Map<String, dynamic>> dataGame = await FirebaseFirestore
          .instance
          .collection("games")
          .doc("verified")
          .collection("games_verified")
          .doc(item.data()["idGame"])
          .get();
      posts.add(
          Post.fromMap(item, item.data(), dataUser.data()!, dataGame.data()!));
    }

    return posts;
  }

//Partie Games

  //get number of followers specific game
  static Future<int> getFollowersGame(Game game) async {
    int followers = 0;

    try {
      DocumentSnapshot<Map<String, dynamic>> data = await FirebaseFirestore
          .instance
          .collection('games')
          .doc("verified")
          .collection("games_verified")
          .doc(game.name)
          .get();
      followers = data["followers"];
    } catch (e) {
      print(e);
    }

    return followers;
  }

  //get posts for specific game
  static Future<List<Post>> getPostSpecificGame(Game game) async {
    List<Post> posts = [];

    QuerySnapshot<Map<String, dynamic>> data = await FirebaseFirestore.instance
        .collection('posts')
        .where('idGame', isEqualTo: game.documentId)
        .orderBy('date', descending: true)
        .limit(20)
        .get();

    for (var item in data.docs) {
      if (item.data()['uid'] != me!.uid) {
        DocumentSnapshot<Map<String, dynamic>> dataUser =
            await FirebaseFirestore.instance
                .collection("users")
                .doc(item.data()['uid'])
                .get();
        DocumentSnapshot<Map<String, dynamic>> dataGame =
            await FirebaseFirestore.instance
                .collection("games")
                .doc("verified")
                .collection("games_verified")
                .doc(item.data()["idGame"])
                .get();
        posts.add(Post.fromMap(
            item, item.data(), dataUser.data()!, dataGame.data()!));
      }
    }

    return posts;
  }

  //load more posts for specific game
  static Future<List<Post>> getMorePostsSpecificGame(
      Game game, Post lastPost) async {
    List<Post> posts = [];

    QuerySnapshot<Map<String, dynamic>> data = await FirebaseFirestore.instance
        .collection('posts')
        .where('idGame', isEqualTo: game.documentId)
        .orderBy('date', descending: true)
        .startAfterDocument(lastPost.snapshot!)
        .limit(20)
        .get();

    for (var item in data.docs) {
      if (item.data()['uid'] != me!.uid) {
        DocumentSnapshot<Map<String, dynamic>> dataUser =
            await FirebaseFirestore.instance
                .collection("users")
                .doc(item.data()['uid'])
                .get();
        DocumentSnapshot<Map<String, dynamic>> dataGame =
            await FirebaseFirestore.instance
                .collection("games")
                .doc("verified")
                .collection("games_verified")
                .doc(item.data()["idGame"])
                .get();
        posts.add(Post.fromMap(
            item, item.data(), dataUser.data()!, dataGame.data()!));
      }
    }

    return posts;
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
