import 'package:flutter/material.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/router.dart';

class AuthController extends StatelessWidget {
  const AuthController({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: WillPopScope(
          onWillPop: () async {
            return !(await navMainAuthKey.currentState!.maybePop());
          },
          child: Navigator(
            key: navMainAuthKey,
            initialRoute: BottomTabNav,
            onGenerateRoute: (settings) =>
                generateRouteMainAuth(settings, context),
          )),
    );
  }
}
