import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemu/models/game.dart';

final allGamesRegisterNotifierProvider =
    StateNotifierProvider.autoDispose<GamesRegisterProvider, List<Game>>(
        (ref) => GamesRegisterProvider());
final newGamesRegisterNotifierProvider =
    StateNotifierProvider.autoDispose<NewGamesRegisterProvider, List<Game>>(
        (ref) => NewGamesRegisterProvider());
final gamesFollowRegisterNotifierProvider =
    StateNotifierProvider.autoDispose<GamesFollowRegisterProvider, List<Game>>(
        (ref) => GamesFollowRegisterProvider());
final loadingMoreGamesRegisterNotifierProvider =
    StateNotifierProvider.autoDispose<LoadingGamesRegisterProvider, bool>(
        (ref) => LoadingGamesRegisterProvider());
final stopReachedRegisterNotifierProvider =
    StateNotifierProvider.autoDispose<StopReachedRegisterProvider, bool>(
        (ref) => StopReachedRegisterProvider());
final searchingRegisterNotifierProvider =
    StateNotifierProvider<SearchingRegisterProvider, bool>(
        (ref) => SearchingRegisterProvider());

class GamesRegisterProvider extends StateNotifier<List<Game>> {
  GamesRegisterProvider() : super([]);

  initGames(List<Game> games) {
    state = games;
  }

  loadMoreGame(List<Game> newGames) {
    state.addAll(newGames);
  }
}

class NewGamesRegisterProvider extends StateNotifier<List<Game>> {
  NewGamesRegisterProvider() : super([]);

  seeNewGames(List<Game> newGames) {
    state = newGames;
  }
}

class GamesFollowRegisterProvider extends StateNotifier<List<Game>> {
  GamesFollowRegisterProvider() : super([]);

  addGame(Game game) {
    state.add(game);
    print(state.length);
  }

  removeGame(Game game) {
    state.removeWhere((element) => element.name == game.name);
    print(state.length);
  }
}

class LoadingGamesRegisterProvider extends StateNotifier<bool> {
  LoadingGamesRegisterProvider() : super(false);

  update(bool newState) {
    state = newState;
  }
}

class StopReachedRegisterProvider extends StateNotifier<bool> {
  StopReachedRegisterProvider() : super(false);

  update() {
    state = !state;
  }
}

class SearchingRegisterProvider extends StateNotifier<bool> {
  SearchingRegisterProvider() : super(false);

  update(bool newState) {
    state = newState;
  }
}
