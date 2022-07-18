import 'package:flutter/material.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";
import 'package:gemu/models/game.dart';

final indexGamesNotifierProvider =
    StateNotifierProvider<IndexGamesProvider, int>(
        (ref) => IndexGamesProvider());
final myGamesControllerNotifierProvider =
    StateNotifierProvider<MyGamesControllerProvider, List<PageController>>(
        (ref) => MyGamesControllerProvider());
final gamesTabNotifierProvider =
    StateNotifierProvider<GamesTabProvider, List<Game>>(
        (ref) => GamesTabProvider());
final modifGamesFollowsNotifierProvider =
    StateNotifierProvider<ModifGamesFollowsProvider, bool>(
        (ref) => ModifGamesFollowsProvider());

class GamesTabProvider extends StateNotifier<List<Game>> {
  GamesTabProvider() : super([]);

  List<Game> get getGamesTab => state;

  initGames(List<Game> gameList) {
    state = [...gameList, Game(name: "Ajouter", imageUrl: "Ajouter")];
  }

  addGame(Game game) {
    List<Game> newState = [...state];
    newState.removeLast();
    newState.add(game);
    newState
        .sort(((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())));
    state = [...newState, Game(name: "Ajouter", imageUrl: "Ajouter")];
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

class IndexGamesProvider extends StateNotifier<int> {
  IndexGamesProvider() : super(0);

  updateIndex(int newIndex) {
    state = newIndex;
    print(state);
  }

  updateIndexNewGame(int gamesLength) {
    int newState = state;
    if (newState == gamesLength) {
      newState = newState - 1;
    }
    state = newState;
  }

  resetIndex(int index) {
    state = index;
  }

  clearIndex() {
    state = 0;
  }
}

class MyGamesControllerProvider extends StateNotifier<List<PageController>> {
  MyGamesControllerProvider() : super([]);

  initGamesController(List<PageController> gamesControllerList) {
    state = gamesControllerList;
  }

  addGamesController() {
    List<PageController> newState = [...state];
    newState.add(PageController());
    state = newState;
  }

  deleteGamesController(int index) {
    List<PageController> newState = copyState();
    newState.removeAt(index);
    state = newState;
  }

  copyState() {
    List<PageController> list = [];
    for (var controller in state) {
      list.add(controller);
    }
    return list;
  }
}

class ModifGamesFollowsProvider extends StateNotifier<bool> {
  ModifGamesFollowsProvider() : super(false);

  update(bool newState) {
    state = newState;
  }
}
