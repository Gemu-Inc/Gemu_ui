import 'package:Gemu/models/data.dart';
import 'package:Gemu/models/user.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/models/models.dart';
import 'package:Gemu/locator.dart';
import 'package:Gemu/services/auth_service.dart';
import 'package:Gemu/services/firestore_service.dart';

class MessageUser extends StatelessWidget {
  final FirestoreService _firestoreService = locator<FirestoreService>();
  final AuthService _authService = locator<AuthService>();

  Future getUserData() async {
    var user = _authService.currentUser;
    print('test ${user.photoURL}');
  }

  String messageUser() {
    String texte;
    int heure;

    heure = DateTime.now().hour;
    var user = _authService.currentUser;

    if (heure >= 0 && heure < 12) {
      texte = 'Bonne matinée ' + user.pseudo;
    } else if (heure >= 12 && heure < 18) {
      texte = 'Bon après-midi ' + user.pseudo;
    } else if (heure >= 18 && heure <= 23) {
      texte = 'Bonne soirée ' + user.pseudo;
    }

    return texte;
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      messageUser(),
      style: TextStyle(
          color: Colors.black54, fontSize: 20, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }
}