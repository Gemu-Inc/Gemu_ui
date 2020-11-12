import 'package:Gemu/components/components.dart';
import 'package:Gemu/core/services/auth_service.dart';
import 'package:Gemu/screens/Login/login_screen.dart';
import 'package:Gemu/screens/Register/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/styles/styles.dart';
import 'package:Gemu/screens/screens.dart';
import 'package:Gemu/screens/Welcome/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:Gemu/core/services/authentication_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp().catchError((error) => print(error));
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  prefs.then((value) {
    runApp(ChangeNotifierProvider<ThemeNotifier>(
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
        child: ChangeNotifierProvider(
            create: (context) => AuthService(), child: MyApp())));
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
      home: FutureBuilder(
          future: Provider.of<AuthService>(context, listen: true).getUser(),
          builder: (context, AsyncSnapshot<auth.User> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.error != null) {
                print("error");
                return Text(snapshot.error.toString());
              }
              return snapshot.hasData
                  ? NavScreen(firebaseUser: snapshot.data)
                  : WelcomeScreen();
            } else {
              return LoadingCircle();
            }
          }),
      routes: {
        NavScreen.routeName: (context) => NavScreen(),
        LoginScreen.routeName: (context) => LoginScreen(),
        RegisterScreen.routeName: (context) => RegisterScreen(),
        ProfilMenu.routeName: (context) => ProfilMenu(),
        ReglagesScreen.routeName: (context) => ReglagesScreen(),
        'welcome': (context) => WelcomeScreen(),
      },
    );
  }
}

class LoadingCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: CircularProgressIndicator(
          backgroundColor: Theme.of(context).primaryColor,
        ),
        alignment: Alignment(0.0, 0.0),
      ),
    );
  }
}
