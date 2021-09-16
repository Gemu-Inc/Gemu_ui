import 'package:flutter/material.dart';
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
      ChangeNotifierProvider<PrimaryColorNotifier>(create: (_) {
        Color primaryColor;
        primaryColor =
            Color(value.getInt('color_primary') ?? Color(0xFFB27D75).value);
        return PrimaryColorNotifier(primaryColor);
      }),
      ChangeNotifierProvider<AccentColorNotifier>(create: (_) {
        Color accentColor;
        accentColor =
            Color(value.getInt('color_accent') ?? Color(0xFF6E78B1).value);
        return AccentColorNotifier(accentColor);
      }),
      ChangeNotifierProvider<ThemeNotifier>(create: (_) {
        String? theme = value.getString(Constants.appTheme);
        ThemeData themeData;
        if (theme == 'DarkPurple') {
          themeData = darkThemePurple;
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Color(0xFF1A1C25)));
          return ThemeNotifier(themeData);
        } else if (theme == 'LightOrange') {
          themeData = lightThemeOrange;
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Color(0xFFDEE4E7)));
          return ThemeNotifier(themeData);
        } else if (theme == 'LightPurple') {
          themeData = lightThemePurple;
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Color(0xFFDEE4E7)));
          return ThemeNotifier(themeData);
        } else if (theme == 'DarkOrange') {
          themeData = darkThemeOrange;
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Color(0xFF1A1C25)));
          return ThemeNotifier(themeData);
        } else {
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.transparent));
          return ThemeNotifier(null);
        }
      }),
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
    final _primaryColor = Provider.of<PrimaryColorNotifier>(context);
    final _accentColor = Provider.of<AccentColorNotifier>(context);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Gemu',
        themeMode: themeNotifier.getTheme() == null ? ThemeMode.system : null,
        //Light theme system
        theme: themeNotifier.getTheme() == null
            ? ThemeData(
                brightness: Brightness.light,
                scaffoldBackgroundColor: Color(0xFFDEE4E7),
                primaryColor: _primaryColor.getColor(),
                colorScheme: ColorScheme.light(),
                accentColor: _accentColor.getColor(),
                canvasColor: Color(0xFFD3D3D3),
                shadowColor: Color(0xFFBDBDBD),
                iconTheme: IconThemeData(
                  color: Colors.black45,
                ),
                appBarTheme: AppBarTheme(
                  color: Colors.transparent,
                  titleTextStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  iconTheme: IconThemeData(
                    color: Colors.black45,
                  ),
                ),
                bottomNavigationBarTheme: BottomNavigationBarThemeData(
                    elevation: 0,
                    type: BottomNavigationBarType.fixed,
                    selectedIconTheme: IconThemeData(size: 26),
                    selectedLabelStyle: TextStyle(fontSize: 14.0),
                    selectedItemColor: _primaryColor.getColor(),
                    unselectedIconTheme: IconThemeData(size: 23),
                    unselectedLabelStyle: TextStyle(fontSize: 12.0),
                    unselectedItemColor: Colors.black45))
            : themeNotifier.getTheme(),
        //Dark theme system
        darkTheme: themeNotifier.getTheme() == null
            ? ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: Color(0xFF1A1C25),
                primaryColor: _primaryColor.getColor(),
                accentColor: _accentColor.getColor(),
                colorScheme: ColorScheme.dark(),
                canvasColor: Color(0xFF222831),
                shadowColor: Color(0xFF121212),
                iconTheme: IconThemeData(
                  color: Colors.white60,
                ),
                appBarTheme: AppBarTheme(
                  color: Colors.transparent,
                  titleTextStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  iconTheme: IconThemeData(
                    color: Colors.white60,
                  ),
                ),
                bottomNavigationBarTheme: BottomNavigationBarThemeData(
                    elevation: 0,
                    type: BottomNavigationBarType.fixed,
                    selectedIconTheme: IconThemeData(size: 26),
                    selectedLabelStyle: TextStyle(fontSize: 14.0),
                    selectedItemColor: _primaryColor.getColor(),
                    unselectedIconTheme: IconThemeData(size: 23),
                    unselectedLabelStyle: TextStyle(fontSize: 12.0),
                    unselectedItemColor: Colors.white60))
            : themeNotifier.getTheme(),
        onGenerateRoute: generateRoute,
        home: LogController());
  }
}
