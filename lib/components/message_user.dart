import 'package:flutter/material.dart';
import 'package:Gemu/core/models/models.dart';

class MessageUser extends StatelessWidget {
  final UserLogin currentUser;

  const MessageUser({
    Key key,
    @required this.currentUser,
  }) : super(key: key);

  String messageUser() {
    String texte;
    int heure;

    heure = DateTime.now().hour;

    if (heure >= 0 && heure < 12) {
      texte = 'Bonne matinée' + '\n' + currentUser.name;
    } else if (heure >= 12 && heure < 18) {
      texte = 'Bon après-midi' + '\n' + currentUser.name;
    } else if (heure >= 18 && heure <= 23) {
      texte = 'Bonne soirée' + '\n' + currentUser.name;
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
