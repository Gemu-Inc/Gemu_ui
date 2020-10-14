import 'package:Gemu/screens/nav_screen.dart';
import 'package:Gemu/screens/profil_screen.dart';
import 'package:flutter/material.dart';

class PrincipalScreen extends StatefulWidget {
  PrincipalScreen({Key key}) : super(key: key);

  @override
  _PrincipalScreenState createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [ProfilMenu(), NavScreen()],
      ),
    );
  }
}
