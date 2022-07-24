import 'package:flutter/material.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";
import 'package:gemu/models/game.dart';
import 'package:gemu/models/post.dart';

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
final loadedDataGameProviderNotifier =
    StateNotifierProvider<LoadedDataMyGames, List<bool>>(
        (ref) => LoadedDataMyGames());
final postsGameNotifierProvider =
    StateNotifierProvider<PostsGameProvider, List<List<Post>>>(
        (ref) => PostsGameProvider());

class GamesTabProvider extends StateNotifier<List<Game>> {
  GamesTabProvider() : super([]);

  List<Game> get getGamesTab => state;

  initGamesTab(List<Game> gamesList) {
    state = [...gamesList, Game(name: "Ajouter", imageUrl: "Ajouter")];
  }

  updateGamesTab(List<Game> gamesList) {
    state = [...gamesList, Game(name: "Ajouter", imageUrl: "Ajouter")];
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

  updateGamesController(int nbGamesController) {
    List<PageController> newState = [];
    for (var i = 0; i < nbGamesController; i++) {
      newState.add(PageController());
    }
    state = [...newState];
  }

  copyState() {
    List<PageController> list = [];
    for (var controller in state) {
      list.add(controller);
    }
    return list;
  }
}

class LoadedDataMyGames extends StateNotifier<List<bool>> {
  LoadedDataMyGames() : super([]);

  initLoadedDataGames(int gamesListLength) {
    List<bool> newState = [];
    for (var i = 0; i < gamesListLength; i++) {
      newState.add(false);
    }
    state = [...newState];
  }

  updateLoadedDataGames(int gamesListLength) {
    List<bool> newState = [];
    for (var i = 0; i < gamesListLength; i++) {
      newState.add(false);
    }
    state = [...newState];
  }

  updateLoadedDataGamesAtIndex(int index, bool newStateBool) {
    List<bool> newState = [...state];
    newState[index] = newStateBool;
    state = [...newState];
  }
}

class PostsGameProvider extends StateNotifier<List<List<Post>>> {
  PostsGameProvider() : super([]);

  initPostsGame(int gamesListLength) {
    List<List<Post>> newState = [];
    for (var i = 0; i < gamesListLength; i++) {
      newState.add([]);
    }
    state = [...newState];
  }

  updatePostsGame(int gamesListLength) {
    List<List<Post>> newState = [];
    for (var i = 0; i < gamesListLength; i++) {
      newState.add([]);
    }
    state = [...newState];
  }

  updatePostGameAtIndex(int index, List<Post> posts) {
    List<List<Post>> newState = [...state];
    newState[index] = posts;
    state = [...newState];

    print(state);
  }
}

class ModifGamesFollowsProvider extends StateNotifier<bool> {
  ModifGamesFollowsProvider() : super(false);

  update(bool newState) {
    state = newState;
  }
}
