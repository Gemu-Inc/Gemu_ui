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

  void updateLoading(bool newState) {
    state = newState;
  }
}

class GamesDiscoverProvider extends StateNotifier<List<Game>> {
  GamesDiscoverProvider() : super([]);

  initGames(List<Game> games) {
    state = games;
  }

  loadMoreGame(List<Game> newGames) {
    state = [...state, ...newGames];
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
