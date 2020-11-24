import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:Gemu/ui/screens/screens.dart';

class MySplashScreen extends StatefulWidget {
  @override
  _MySplashScreenState createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SplashScreen(
        seconds: 3,
        navigateAfterSeconds: NavScreen(),
        image: Image.asset('img/share_chargement.png'),
        backgroundColor: Colors.black26,
        photoSize: 75.0,
        loaderColor: Color(0xFFDC804F),
      ),
    );
  }
}
