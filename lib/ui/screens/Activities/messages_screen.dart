import 'package:flutter/material.dart';

class MessagesScreen extends StatefulWidget {
  @override
  MessagesScreenState createState() => MessagesScreenState();
}

class MessagesScreenState extends State<MessagesScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: 10,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: GestureDetector(
              onTap: () => print('Profil user'),
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    shape: BoxShape.circle),
                child: Icon(Icons.person),
              ),
            ),
            title: Text('User'),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('Message envoyé ou reçu'), Text('Date')],
            ),
            onTap: () => print('Entrer dans la conversation'),
            onLongPress: () => print('Dialog pour supprimer la conversation'),
          );
        });
  }
}
