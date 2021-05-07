import 'package:Gemu/services/provider_auth.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/ui/screens/Navigation/nav_screen.dart';
import 'package:Gemu/ui/screens/Welcome/welcome_screen.dart';

class ConnectionScreen extends StatefulWidget {
  @override
  ConnectionScreenState createState() => ConnectionScreenState();
}

class ConnectionScreenState extends State<ConnectionScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ProviderAuth.of(context)!.auth!.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          print('user log in');
          ProviderAuth.of(context)!.auth!.getCurrentUID();
          return NavScreen();
        } else {
          print('user log out');
          return WelcomeScreen();
        }
      },
    );
  }
}
