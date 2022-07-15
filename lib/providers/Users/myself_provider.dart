import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/models/user.dart';

final myselfNotifierProvider =
    StateNotifierProvider<MyselfProvider, UserModel?>(
        (ref) => MyselfProvider());
final myGamesNotifierProvider =
    StateNotifierProvider<MyGamesProvider, List<Game>>(
        (ref) => MyGamesProvider());

class MyselfProvider extends StateNotifier<UserModel?> {
  MyselfProvider() : super(null);

  initUser(UserModel user) {
    state = user;
  }

  cleanUser() {
    state = null;
  }
}

class MyGamesProvider extends StateNotifier<List<Game>> {
  MyGamesProvider() : super([]);

  initGames(List<Game> gameList) {
    state = gameList;
  }
}
