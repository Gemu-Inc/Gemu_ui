import 'package:Gemu/screens/Profil/reglages_screen.dart';
import 'package:Gemu/components/components.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/configuration/configuration.dart';
import 'package:Gemu/screens/screens.dart';
import 'package:Gemu/screens/Welcome/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Gemu/services/authentication_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  prefs.then((value) {
    runApp(
      ChangeNotifierProvider<ThemeNotifier>(
        create: (_) {
          String theme = value.getString(Constants.appTheme);
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
          } else if (theme == 'LightCustom') {
            themeData = ThemeData(
                brightness: lightThemeCustom.brightness,
                primaryColor:
                    Color(value.getInt('color_primary') ?? Colors.blue.value),
                accentColor:
                    Color(value.getInt('color_accent') ?? Colors.blue.value),
                scaffoldBackgroundColor:
                    lightThemeCustom.scaffoldBackgroundColor);
            return ThemeNotifier(themeData);
          } else if (theme == 'DarkCustom') {
            themeData = ThemeData(
                brightness: darkThemeCustom.brightness,
                primaryColor:
                    Color(value.getInt('color_primary') ?? Colors.blue.value),
                accentColor:
                    Color(value.getInt('color_accent') ?? Colors.blue.value),
                scaffoldBackgroundColor:
                    darkThemeCustom.scaffoldBackgroundColor);
            return ThemeNotifier(themeData);
          }
          return ThemeNotifier(darkThemeOrange);
        },
        child: MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MultiProvider(
        providers: [
          Provider<AuthenticationService>(
            create: (_) => AuthenticationService(FirebaseAuth.instance),
          ),
          StreamProvider(
            create: (context) =>
                context.read<AuthenticationService>().authStateChanges,
          )
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Gemu',
          theme: themeNotifier.getTheme(),
          routes: {
            '/': (context) => AuthenticationWrapper(),
            '/reglagesScreen': (context) => ReglagesScreen(),
            '/searchBar': (context) => SearchBar()
          },
          initialRoute: '/',
        ));
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();

    if (firebaseUser != null) {
      return NavScreen();
    }
    return WelcomeScreen();
  }
}
