import 'package:flutter_riverpod/flutter_riverpod.dart';

final indexGamesNotifierProvider =
    StateNotifierProvider<IndexGamesProvider, int>(
        (ref) => IndexGamesProvider());

class IndexGamesProvider extends StateNotifier<int> {
  IndexGamesProvider() : super(0);

  updateIndex(int newIndex) {
    state = newIndex;
  }

  updateIndexNewGame(int gamesLength) {
    if (state == gamesLength) {
      state = gamesLength - 1;
    }
  }
}
