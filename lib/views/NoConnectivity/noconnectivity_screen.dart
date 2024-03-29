import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gemu/translations/app_localizations.dart';
import 'package:loading_indicator/loading_indicator.dart';

class NoConnectivityScreen extends StatelessWidget {
  const NoConnectivityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
            statusBarIconBrightness:
                Theme.of(context).brightness == Brightness.dark
                    ? Brightness.light
                    : Brightness.dark,
            systemNavigationBarIconBrightness:
                Theme.of(context).brightness == Brightness.dark
                    ? Brightness.light
                    : Brightness.dark),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 4,
              width: MediaQuery.of(context).size.width / 4,
              child: Center(
                child: LoadingIndicator(
                  indicatorType: Indicator.pacman,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(context).colorScheme.primary,
                  ],
                  strokeWidth: 6,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Text(
                AppLocalization.of(context)
                    .translate("connectivity_screen", "content"),
                style: Theme.of(context).textTheme.titleSmall!,
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }
}
