import 'package:Gemu/screens/reglages_screen.dart';
import 'package:Gemu/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/config/config.dart';
import 'package:Gemu/screens/screens.dart';
import 'package:Gemu/screens/Welcome/welcome_screen.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Gemu/screens/Welcome/components/authentication_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(dPurpleTheme), child: MyApp()));
}

class MyApp extends StatelessWidget {
  /*List<ThemeItem> data = List();
  String dynTheme;
https://gemu.page.link
  Future<void> getDefault() async {
    data = ThemeItem.getThemeItems();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynTheme = prefs.getString("dynTheme");
  }*/

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

    // return MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   title: 'Gemu',
    //   theme: themeNotifier.getTheme(),
    //   routes: {
    //     '/': (context) => MySplashScreen(),
    //     '/reglagesScreen': (context) => ReglagesScreen(),
    //     '/searchBar': (context) => SearchBar()
    //   },
    //   initialRoute: '/',
    // );
    //});
  }
  /*getDefault();
    return DynamicTheme(data: (Brightness brightness) {
      getDefault();
      for (int i = 0; i < data.length; i++) {
        if (data[i].slug == this.dynTheme) {
          return data[i].themeData;
        }
      }
      return data[0].themeData;
    }, themedWidgetBuilder: (context, theme) {*/
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
