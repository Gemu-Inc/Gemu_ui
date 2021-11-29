import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:gemu/services/auth_service.dart';
import 'package:gemu/ui/controller/navigation_controller.dart';
import 'package:gemu/ui/views/Splash/splash_screen.dart';
import 'package:gemu/ui/views/Welcome/welcome_screen.dart';

class LogController extends StatefulWidget {
  @override
  LogControllerState createState() => LogControllerState();
}

class LogControllerState extends State<LogController> {
  bool isLoading = true;

  loading() async {
    await Future.delayed(Duration(seconds: 3));
    if (isLoading && mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loading();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: AuthService.instance.authStateChange(),
        builder: (context, snapshot) {
          final isSignedIn = snapshot.data != null;
          return isLoading
              ? SplashScreen()
              : isSignedIn
                  ? NavController(uid: snapshot.data!.uid)
                  : WelcomeScreen();
        });
  }
}
