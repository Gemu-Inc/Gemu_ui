import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gemu/providers/GetStarted/getStarted_provider.dart';
import 'package:gemu/providers/Connectivity/connectivity_provider.dart';
import 'package:gemu/providers/Langue/device_language_provider.dart';
import 'package:gemu/providers/Theme/dayMood_provider.dart';
import 'package:gemu/providers/Theme/theme_provider.dart';
import 'package:gemu/providers/Users/myself_provider.dart';
import 'package:gemu/services/auth_service.dart';
import 'package:gemu/services/database_service.dart';
import 'package:gemu/translations/app_localizations.dart';
import 'package:gemu/views/NoConnectivity/noconnectivity_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import "package:flutter_native_splash/flutter_native_splash.dart";

import 'package:gemu/router.dart';
import 'package:gemu/constants/constants.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:country_code_picker/country_code_picker.dart';

class LogController extends ConsumerStatefulWidget {
  const LogController({Key? key}) : super(key: key);

  @override
  _LogControllerState createState() => _LogControllerState();
}

class _LogControllerState extends ConsumerState<LogController> {
  late Color primaryColor, accentColor;

  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  final Connectivity _connectivity = Connectivity();

  late Locale localeLanguage;

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

    //logic langue device or choice user
    await ref.read(deviceLanguageProvider.notifier).setLocaleLanguage();

    ref.read(dayMoodNotifierProvider.notifier).timeMood();
    await ref.read(connectivityNotifierProvider.notifier).initConnectivity();

    if (prefs.getString("token") != null) {
      User? user = await AuthService.getUser();
      if (user != null) {
        await AuthService.setUserToken(user);
        await DatabaseService.getUserData(user, ref);
      } else {
        await prefs.remove("token");
      }
    }

    FlutterNativeSplash.remove();
  }

  @override
  void initState() {
    super.initState();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      ref.read(connectivityNotifierProvider.notifier).connectivityState(result);
    });

    initApp();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProviderNotifier);
    final primaryColor = ref.watch(primaryProviderNotifier);
    final accentColor = ref.watch(accentProviderNotifier);
    final seenGetStarted = ref.watch(getStartedNotifierProvider);
    final connectivityStatus = ref.watch(connectivityNotifierProvider);
    final activeUser = ref.watch(myselfNotifierProvider);
    localeLanguage = ref.watch(deviceLanguageProvider);

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Gemu',
        supportedLocales: [Locale("en", ""), Locale("fr", "")],
        locale: localeLanguage,
        localizationsDelegates: [
          CountryLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          AppLocalization.delegate,
        ],
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
        home: connectivityStatus == ConnectivityResult.none
            ? NoConnectivityScreen()
            : activeUser == null
                ? LoaderOverlay(
                    useDefaultLoading: false,
                    overlayWidget: Center(
                      child: CircularProgressIndicator(
                        color: cPrimaryPink,
                        strokeWidth: 1.0,
                      ),
                    ),
                    overlayColor: Colors.black,
                    overlayOpacity: 0.7,
                    child: WillPopScope(
                      onWillPop: () async {
                        return !(await navNonAuthKey.currentState!.maybePop());
                      },
                      child: Navigator(
                        key: navNonAuthKey,
                        initialRoute:
                            !seenGetStarted ? GetStartedBefore : Welcome,
                        onGenerateRoute: (settings) =>
                            generateRouteNonAuth(settings, context),
                      ),
                    ))
                : WillPopScope(
                    onWillPop: () async {
                      return !(await navMainAuthKey.currentState!.maybePop());
                    },
                    child: Navigator(
                      key: navMainAuthKey,
                      initialRoute: BottomTabNav,
                      onGenerateRoute: (settings) =>
                          generateRouteMainAuth(settings, context),
                    )));
  }
}
