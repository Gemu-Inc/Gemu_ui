import 'package:Gemu/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/locator.dart';
import 'package:Gemu/services/auth_service.dart';
import 'package:Gemu/models/user.dart';
import 'package:Gemu/models/data.dart';

class MessageUser extends StatelessWidget {
  //final AuthService _authService = locator<AuthService>();

  String messageUser(String user) {
    String texte;
    int heure;

    heure = DateTime.now().hour;
    //var user = _authService.currentUser;

    if (heure >= 0 && heure < 12) {
      texte = 'Bonne matinée ' + user;
    } else if (heure >= 12 && heure < 18) {
      texte = 'Bon après-midi ' + user;
    } else if (heure >= 18 && heure <= 23) {
      texte = 'Bonne soirée ' + user;
    }

    return texte;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserC>(
        stream: FirestoreService(uid: userC.id).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserC _userC = snapshot.data;
            return Text(
              messageUser(_userC.pseudo),
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}
