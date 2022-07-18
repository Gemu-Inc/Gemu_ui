import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemu/models/game.dart';

final loadingGamesDiscoverNotifierProvider =
    StateNotifierProvider<LoadingGamesDiscoverProvider, bool>(
        (ref) => LoadingGamesDiscoverProvider());
final loadingMoreGamesDiscoverNotifierProvider =
    StateNotifierProvider<LoadingMoreGamesDiscoverProvider, bool>(
        (ref) => LoadingMoreGamesDiscoverProvider());
final stopReachedDiscoverNotifierProvider =
    StateNotifierProvider<StopReachedDiscoverProvider, bool>(
        (ref) => StopReachedDiscoverProvider());
final gamesDiscoverNotifierProvider =
    StateNotifierProvider<GamesDiscoverProvider, List<Game>>(
        (ref) => GamesDiscoverProvider());
final newGamesDiscoverNotifierProvider =
    StateNotifierProvider<NewGamesDiscoverProvider, List<Game>>(
        (ref) => NewGamesDiscoverProvider());

class LoadingGamesDiscoverProvider extends StateNotifier<bool> {
  LoadingGamesDiscoverProvider() : super(false);

  bool get getState => state;

  void updateLoading(bool newState) {
    state = newState;
  }
}

class GamesDiscoverProvider extends StateNotifier<List<Game>> {
  GamesDiscoverProvider() : super([]);

  initGames(List<Game> games) {
    state = games;
  }

  List<Game> get getGamesDiscover => state;

  loadMoreGame(List<Game> newGames) {
    List<Game> newState = [...state, ...newGames];
    newState
        .sort(((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())));
    state = newState;
  }

  addGame(Game game, bool stopReached) {
    if (!stopReached) {
      List<Game> newState = [game, ...state];
      state = newState;
    } else {
      List<Game> newState = [...state, game];
      newState.sort(
          ((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())));
      state = newState;
    }
  }

  removeGame(Game game) {
    List<Game> newState = [...state];
    newState.removeWhere((element) => element.name == game.name);
    state = newState;
  }

  copyState() {
    List<Game> games = [];
    for (var game in state) {
      games.add(game);
    }
    return games;
  }
}

class NewGamesDiscoverProvider extends StateNotifier<List<Game>> {
  NewGamesDiscoverProvider() : super([]);

  seeNewGames(List<Game> newGames) {
    state = newGames;
  }
}

class LoadingMoreGamesDiscoverProvider extends StateNotifier<bool> {
  LoadingMoreGamesDiscoverProvider() : super(false);

  update(bool newState) {
    state = newState;
  }
}

class StopReachedDiscoverProvider extends StateNotifier<bool> {
  StopReachedDiscoverProvider() : super(false);

  update() {
    state = !state;
  }
}
