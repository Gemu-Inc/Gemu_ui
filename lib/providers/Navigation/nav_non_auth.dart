import "package:flutter_riverpod/flutter_riverpod.dart";

final currentRouteNonAuthNotifierProvider =
    StateNotifierProvider<NavNonAuthCurrentRouteProvider, String>(
        (ref) => NavNonAuthCurrentRouteProvider());

class NavNonAuthCurrentRouteProvider extends StateNotifier<String> {
  NavNonAuthCurrentRouteProvider() : super("Welcome");

  updateCurrentRoute(String newRoute) {
    state = newRoute;
  }
}
