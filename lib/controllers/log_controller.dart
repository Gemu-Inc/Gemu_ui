import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/riverpod/Connectivity/auth_provider.dart';
import 'package:gemu/riverpod/GetStarted/getStarted_provider.dart';
import 'package:gemu/riverpod/Connectivity/connectivity_provider.dart';
import 'package:gemu/riverpod/Navigation/nav_non_auth.dart';
import 'package:gemu/riverpod/Theme/dayMood_provider.dart';
import 'package:gemu/riverpod/Theme/theme_provider.dart';
import 'package:gemu/riverpod/Users/myself_provider.dart';
import 'package:gemu/services/auth_service.dart';
import 'package:gemu/services/database_service.dart';
import 'package:gemu/views/NoConnectivity/noconnectivity_screen.dart';
import 'package:gemu/widgets/alert_dialog_custom.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import "package:flutter_native_splash/flutter_native_splash.dart";

import 'package:gemu/router.dart';
import 'package:gemu/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogController extends ConsumerStatefulWidget {
  const LogController({Key? key}) : super(key: key);

  @override
  _LogControllerState createState() => _LogControllerState();
}

class _LogControllerState extends ConsumerState<LogController> {
  late Color primaryColor, accentColor;

  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  late StreamSubscription<User?> _userSubscription;

  final Connectivity _connectivity = Connectivity();

  bool isWaiting = false;

  User? activeUser;

  Future<void> initApp() async {
    final prefs = await SharedPreferences.getInstance();

    ref.read(getStartedNotifierProvider.notifier).setSeenGetStarted();

    String? theme = prefs.getString(appTheme);

    if (theme == null || theme == themeSystem) {
      if (theme == null) theme = themeSystem;
      if (prefs.getInt('color_primary') != null) {
        primaryColor = Color(prefs.getInt('color_primary')!);
      } else {
        primaryColor = cPrimaryPink;
      }
      if (prefs.getInt('color_accent') != null) {
        accentColor = Color(prefs.getInt('color_accent')!);
      } else {
        accentColor = cPrimaryPurple;
      }

      ref
          .read(primaryProviderNotifier.notifier)
          .createPrimaryColor(primaryColor);
      ref.read(accentProviderNotifier.notifier).createAccentColor(accentColor);
    }
    ref.read(themeProviderNotifier.notifier).createTheme(theme, context);

    ref.read(dayMoodNotifierProvider.notifier).timeMood();
    await ref.read(connectivityNotifierProvider.notifier).initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      ref
          .read(connectivityNotifierProvider.notifier)
          .updateConnectivity(result);
    });

    _userSubscription =
        AuthService.authStateChange().listen((User? user) async {
      if (!isWaiting) {
        if (user != null) {
          await getUserData(user);
        }
        await ref.read(authNotifierProvider.notifier).updateAuth(user);
      } else {
        await Future.delayed(Duration(seconds: 4));
        if (!isWaiting) {
          if (user != null) {
            await getUserData(user);
          }
          await ref.read(authNotifierProvider.notifier).updateAuth(user);
        }
      }
      FlutterNativeSplash.remove();
    });
  }

  getUserData(User user) async {
    List<Game> gamesList = [];
    List<PageController> gamePageController = [];

    await DatabaseService.getCurrentUser(user.uid, ref);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('games')
        .get()
        .then((value) {
      for (var item in value.docs) {
        gamesList.add(Game.fromMap(item, item.data()));
        gamePageController.add(PageController());
      }
    });

    ref.read(myGamesNotifierProvider.notifier).initGames(gamesList);
    ref
        .read(myGamesControllerNotifierProvider.notifier)
        .initGamesController(gamePageController);
  }

  @override
  void initState() {
    super.initState();
    initApp();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _userSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProviderNotifier);
    final primaryColor = ref.watch(primaryProviderNotifier);
    final accentColor = ref.watch(accentProviderNotifier);
    final seenGetStarted = ref.watch(getStartedNotifierProvider);
    final connectivityStatus = ref.watch(connectivityNotifierProvider);
    activeUser = ref.watch(authNotifierProvider);
    final currentRouteNonAuth = ref.watch(currentRouteNonAuthNotifierProvider);
    isWaiting = ref.watch(waitingAuthNotifierProvider);

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Gemu',
        themeMode: ThemeMode.system,
        theme: theme == ThemeData()
            ? (primaryColor == cPrimaryPink && accentColor == cPrimaryPurple)
                ? lightThemeSystemPink
                : lightThemeSystemPurple
            : theme,
        darkTheme: theme == ThemeData()
            ? (primaryColor == cPrimaryPink && accentColor == cPrimaryPurple)
                ? darkThemeSystemPink
                : darkThemeSystemPurple
            : theme,
        home: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            key: mainKey,
            body: connectivityStatus == ConnectivityResult.none
                ? NoConnectivityScreen()
                : activeUser == null
                    ? WillPopScope(
                        onWillPop: () async {
                          if (currentRouteNonAuth == "Register") {
                            showDialog(
                                context: navNonAuthKey.currentContext!,
                                builder: (_) {
                                  return AlertDialogCustom(
                                      _,
                                      "Annuler l'inscription",
                                      "Êtes-vous sur de vouloir annuler votre inscription?",
                                      [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(
                                                  mainKey.currentContext!);
                                              ref
                                                  .read(
                                                      currentRouteNonAuthNotifierProvider
                                                          .notifier)
                                                  .updateCurrentRoute(
                                                      "Welcome");
                                              navNonAuthKey.currentState!
                                                  .pushNamedAndRemoveUntil(
                                                      Welcome,
                                                      (route) => false);
                                            },
                                            child: Text(
                                              "Oui",
                                              style: textStyleCustomBold(
                                                  Colors.green, 12),
                                            )),
                                        TextButton(
                                            onPressed: () => Navigator.pop(
                                                mainKey.currentContext!),
                                            child: Text(
                                              "Non",
                                              style: textStyleCustomBold(
                                                  Colors.red, 12),
                                            ))
                                      ]);
                                });
                            return false;
                          } else {
                            return !(await navNonAuthKey.currentState!
                                .maybePop());
                          }
                        },
                        child: Navigator(
                          key: navNonAuthKey,
                          initialRoute:
                              !seenGetStarted ? GetStartedBefore : Welcome,
                          onGenerateRoute: (settings) =>
                              generateRouteNonAuth(settings, context),
                        ),
                      )
                    : WillPopScope(
                        onWillPop: () async {
                          return !(await navAuthKey.currentState!.maybePop());
                        },
                        child: Navigator(
                          key: navAuthKey,
                          initialRoute: Navigation,
                          onGenerateRoute: (settings) =>
                              generateRouteAuth(settings, context),
                        ))));
  }
}
