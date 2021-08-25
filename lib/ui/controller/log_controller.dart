import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:gemu/services/auth_service.dart';
import 'package:gemu/ui/controller/navigation_controller.dart';
import 'package:gemu/ui/screens/Welcome/welcome_screen.dart';

class LogController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: AuthService.instance.authStateChange(),
        builder: (context, snapshot) {
          final isSignedIn = snapshot.data != null;
          return isSignedIn
              ? NavController(
                  uid: snapshot.data!.uid,
                )
              : WelcomeScreen();
        });
  }
}
