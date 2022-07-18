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

  List<Game> get getMyGames => state;

  initGames(List<Game> gameList) {
    state = gameList;
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
