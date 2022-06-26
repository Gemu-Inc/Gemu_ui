import "package:flutter_riverpod/flutter_riverpod.dart";

final selectedIndexNavNotifierProvider =
    StateNotifierProvider<SelectedIndexNavProvider, int>(
        (ref) => SelectedIndexNavProvider());

class SelectedIndexNavProvider extends StateNotifier<int> {
  SelectedIndexNavProvider() : super(0);

  updateCurrentIndex(int newRoute) {
    state = newRoute;
  }
}
