import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/models/user.dart';

final myselfNotifierProvider =
    StateNotifierProvider<MyselfProvider, UserModel?>(
        (ref) => MyselfProvider());
final myGamesNotifierProvider =
    StateNotifierProvider<MyGamesProvider, List<Game>>(
        (ref) => MyGamesProvider());
final myFollowingsNotifierProvider =
    StateNotifierProvider<MyFollowingsProvider, List<UserModel>>(
        (ref) => MyFollowingsProvider());

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

  List<Game> get getMyGames => state;

  initGames(List<Game> gameList) {
    state = gameList;
  }

  addGame(Game game) {
    List<Game> newState = [...state, game];
    newState
        .sort(((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())));
    state = newState;
  }

  removeGame(Game game) {
    List<Game> newState = copyState();
    newState.removeWhere((element) => element.name == game.name);
    state = newState;
  }

  List<Game> copyState() {
    List<Game> games = [];
    for (Game game in state) {
      games.add(game.copy());
    }
    return games;
  }
}

class MyFollowingsProvider extends StateNotifier<List<UserModel>> {
  MyFollowingsProvider() : super([]);

  initFollowings(List<UserModel> usersList) {
    state = usersList;
  }
}
