import 'package:flutter/material.dart';
import 'package:gemu/providers/theme_provider.dart';
import 'package:gemu/services/auth_service.dart';
import 'package:gemu/views/Splash/splash_screen.dart';
import 'package:gemu/views/Welcome/welcome_screen.dart';
import 'package:loader/loader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gemu/router.dart';
import 'package:gemu/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gemu/views/Navigation/navigation_screen.dart';

class LogController extends StatefulWidget {
  const LogController({Key? key}) : super(key: key);

  @override
  _LogControllerState createState() => _LogControllerState();
}

class _LogControllerState extends State<LogController> {
  late Color primaryColor, accentColor;

  Future<bool> loading(WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    String? theme = prefs.getString(appTheme);
    if (theme == null || theme == "ThemeSystem") {
      if (theme == null) theme = "ThemeSystem";
      if (prefs.getInt('color_primary') != null) {
        primaryColor = Color(prefs.getInt('color_primary')!);
      } else {
        primaryColor = cOrange;
      }
      if (prefs.getInt('color_accent') != null) {
        accentColor = Color(prefs.getInt('color_accent')!);
      } else {
        accentColor = cMauve;
      }

      ref
          .read(primaryProviderNotifier.notifier)
          .createPrimaryColor(primaryColor);
      ref.read(accentProviderNotifier.notifier).createAccentColor(accentColor);
    }
    ref.read(themeProviderNotifier.notifier).createTheme(theme, context);
    await Future.delayed(Duration(seconds: 3));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, ref, child) {
      final theme = ref.watch(themeProviderNotifier);
      final primaryColor = ref.watch(primaryProviderNotifier);
      final accentColor = ref.watch(accentProviderNotifier);
      return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Gemu',
          themeMode: ThemeMode.system,
          theme: theme == ThemeData()
              ? (primaryColor == cOrange && accentColor == cMauve)
                  ? lightThemeSystemOrange
                  : lightThemePurple
              : theme,
          darkTheme: theme == ThemeData()
              ? (primaryColor == cOrange && accentColor == cMauve)
                  ? darkThemeSystemOrange
                  : darkThemeSystemPurple
              : theme,
          onGenerateRoute: (settings) => generateRoute(settings, context),
          home: StreamBuilder<User?>(
            stream: AuthService.authStateChange(),
            builder: (context, snapshot) {
              final isSignedIn = snapshot.data != null;
              return Loader<bool>(
                load: () => loading(ref),
                loadingWidget: SplashScreen(),
                builder: (_, value) {
                  return isSignedIn
                      ? NavigationScreen(uid: snapshot.data!.uid)
                      : WelcomeScreen();
                },
              );
            },
          ));
    });
  }
}