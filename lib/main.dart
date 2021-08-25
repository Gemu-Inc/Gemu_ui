import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import 'package:gemu/ui/router.dart';
import 'package:gemu/ui/constants/app_constants.dart';
import 'package:gemu/ui/screens/Reglages/Design/theme_notifier.dart';
import 'package:gemu/ui/screens/Reglages/Design/theme_values.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gemu/ui/controller/log_controller.dart';
import 'package:gemu/ui/providers/index_tab_games_home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp().catchError((error) {
    print(error);
  });

  //Mise en place du blocage de rotation automatique de l'écran sur l'app
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  prefs.then((value) {
    runApp(MultiProvider(providers: [
      ChangeNotifierProvider<ThemeNotifier>(
        create: (_) {
          String? theme = value.getString(Constants.appTheme);
          print(theme);
          ThemeData themeData;
          if (theme == 'DarkPurple') {
            themeData = darkThemePurple;
            //Mise en place de l'overlay des notifications Android et blocage de la rotation automatique sur l'app
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: Color(0xFF1A1C25),
                systemNavigationBarDividerColor: Colors.transparent));
            return ThemeNotifier(themeData);
          } else if (theme == 'LightOrange') {
            //Mise en place de l'overlay des notifications Android et blocage de la rotation automatique sur l'app
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: Color(0xFFDEE4E7),
                systemNavigationBarDividerColor: Colors.transparent));
            themeData = lightThemeOrange;
            return ThemeNotifier(themeData);
          } else if (theme == 'LightPurple') {
            //Mise en place de l'overlay des notifications Android et blocage de la rotation automatique sur l'app
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: Color(0xFFDEE4E7),
                systemNavigationBarDividerColor: Colors.transparent));
            themeData = lightThemePurple;
            return ThemeNotifier(themeData);
          } else if (theme == 'DarkOrange') {
            themeData = darkThemeOrange;
            //Mise en place de l'overlay des notifications Android et blocage de la rotation automatique sur l'app
            SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: Color(0xFF1A1C25),
                systemNavigationBarDividerColor: Colors.transparent));
            return ThemeNotifier(themeData);
          }
          //Mise en place de l'overlay des notifications Android et blocage de la rotation automatique sur l'app
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Color(0xFF1A1C25),
              systemNavigationBarDividerColor: Colors.transparent));
          return ThemeNotifier(darkThemeOrange);
        },
      ),
      ChangeNotifierProvider<IndexGamesHome>(
        create: (_) {
          return IndexGamesHome(0);
        },
      )
    ], child: MyApp()));
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Gemu',
        theme: themeNotifier.getTheme(),
        onGenerateRoute: generateRoute,
        home: LogController());
  }
}
