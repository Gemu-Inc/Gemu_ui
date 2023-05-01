import "package:flutter_riverpod/flutter_riverpod.dart";
import 'package:gemu/models/game.dart';

final gamesTabNotifierProvider =
    StateNotifierProvider<GamesTabProvider, List<Game>>(
        (ref) => GamesTabProvider());

class GamesTabProvider extends StateNotifier<List<Game>> {
  GamesTabProvider() : super([]);

  List<Game> get getGamesTab => state;

  initGamesTab(List<Game> gamesList) {
    state = [
      ...gamesList,
      Game(
          documentId: "Ajouter",
          name: "Ajouter",
          imageUrl: "Ajouter",
          categories: [])
    ];
  }

  addGameTab(Game game) {
    List<Game> newState = [...state, game];
    newState.removeWhere((element) => element.name == "Ajouter");
    newState
        .sort(((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())));
    state = [
      ...newState,
      Game(
          documentId: "Ajouter",
          name: "Ajouter",
          imageUrl: "Ajouter",
          categories: [])
    ];
  }

  removeGameTab(Game game) {
    List<Game> newState = [...state];
    newState.removeWhere((element) => element.name == game.name);
    state = newState;
  }
}
