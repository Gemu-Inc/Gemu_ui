import 'package:flutter/material.dart';

class IndexGamesHome extends ChangeNotifier {
  late int currentTabGamesIndex;

  IndexGamesHome(this.currentTabGamesIndex);

  getIndex() => currentTabGamesIndex;

  setIndex(int newIndex) async {
    currentTabGamesIndex = newIndex;
    notifyListeners();
  }

  setIndexNewGame(int gamesLength) async {
    print(gamesLength);
    if (currentTabGamesIndex == gamesLength) {
      currentTabGamesIndex = currentTabGamesIndex - 1;
      notifyListeners();
    }
  }
}
