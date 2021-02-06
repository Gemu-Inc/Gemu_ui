import 'package:Gemu/services/auth_service.dart';
import 'package:Gemu/ui/router.dart';
import 'package:Gemu/ui/screens/Connection/connection_screen.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/styles/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:Gemu/locator.dart';
import 'package:Gemu/services/navigation_service.dart';
import 'package:Gemu/services/dialog_service.dart';
import 'package:Gemu/managers/dialog_manager.dart';
import 'package:Gemu/services/provider_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp().catchError((error) => print(error));
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  setupLocator();

  prefs.then((value) {
    runApp(ChangeNotifierProvider<ThemeNotifier>(
        create: (_) {
          String theme = value.getString(Constants.appTheme);
          print(theme);
          ThemeData themeData;
          if (theme == 'DarkPurple') {
            themeData = darkThemePurple;
            return ThemeNotifier(themeData);
          } else if (theme == 'LightOrange') {
            themeData = lightThemeOrange;
            return ThemeNotifier(themeData);
          } else if (theme == 'LightPurple') {
            themeData = lightThemePurple;
            return ThemeNotifier(themeData);
          } else if (theme == 'DarkOrange') {
            themeData = darkThemeOrange;
            return ThemeNotifier(themeData);
          } else if (theme == 'ThemeCustomLight') {
            themeData = ThemeData(
              brightness: themeCustomLight.brightness,
              primaryColor:
                  Color(value.getInt('color_primary') ?? Colors.blue.value),
              accentColor:
                  Color(value.getInt('color_accent') ?? Colors.blue.value),
            );
            return ThemeNotifier(themeData);
          } else if (theme == 'ThemeCustomDark') {
            themeData = ThemeData(
              brightness: themeCustomDark.brightness,
              primaryColor:
                  Color(value.getInt('color_primary') ?? Colors.blue.value),
              accentColor:
                  Color(value.getInt('color_accent') ?? Colors.blue.value),
            );
            return ThemeNotifier(themeData);
          }
          return ThemeNotifier(darkThemeOrange);
        },
        child: MyApp()));
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return ProviderAuth(
      auth: AuthService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Gemu',
        builder: (context, child) => Navigator(
          key: locator<DialogService>().dialogNavigationKey,
          onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (context) => DialogManager(child: child)),
        ),
        navigatorKey: locator<NavigationService>().navigationKey,
        theme: themeNotifier.getTheme(),
        home: ConnectionScreen(),
        onGenerateRoute: generateRoute,
      ),
    );
  }
}
