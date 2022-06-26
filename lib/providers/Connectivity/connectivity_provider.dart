import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityNotifierProvider =
    StateNotifierProvider<ConnectivityProvider, ConnectivityResult>(
        (ref) => ConnectivityProvider());

class ConnectivityProvider extends StateNotifier<ConnectivityResult> {
  ConnectivityProvider() : super(ConnectivityResult.none);

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    final Connectivity _connectivity = Connectivity();

    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.message);
      return;
    }

    if (!mounted) {
      return Future.value(null);
    }

    state = result;
  }

  connectivityState(ConnectivityResult result) {
    state = result;
    print("connectivity: $state");
  }
}
