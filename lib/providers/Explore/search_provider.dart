import 'package:algolia/algolia.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/models/hashtag.dart';
import 'package:gemu/models/user.dart';

final loadedRecentSearchesNotifierProvider =
    StateNotifierProvider<RecentSearchesLoadedProvider, bool>(
        (ref) => RecentSearchesLoadedProvider());
final recentSearchesNotifierProvider =
    StateNotifierProvider<RecentSearchesProvider, List>(
        (ref) => RecentSearchesProvider());

class RecentSearchesLoadedProvider extends StateNotifier<bool> {
  RecentSearchesLoadedProvider() : super(false);

  void recentSearchesLoaded() {
    state = true;
  }

  void cleanLoadedRecentSearches() {
    state = false;
  }
}

class RecentSearchesProvider extends StateNotifier<List> {
  RecentSearchesProvider() : super([]);

  void initRecentSearches(List recentSearch) {
    state = [...recentSearch];
  }

  void addRecentSearches(AlgoliaObjectSnapshot recentSearch) {
    List newState = [];
    List recentSearches = [];

    if (recentSearch.data["type"] == "user") {
      recentSearches
          .add(UserModel.fromMapAlgolia(recentSearch, recentSearch.data));
    } else if (recentSearch.data["type"] == "game") {
      recentSearches.add(Game.fromMapAlgolia(recentSearch, recentSearch.data));
    } else {
      recentSearches
          .add(Hashtag.fromMapAlgolia(recentSearch, recentSearch.data));
    }

    newState = [...recentSearches, ...state];
    state = [...newState];
  }

  void deleteRecentSearches(var recentSearch) {
    List newState = [...state];
    newState.removeWhere(
        (element) => element.documentId == recentSearch.documentId);
    state = [...newState];
  }
}
