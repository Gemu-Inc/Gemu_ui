import 'package:flutter/material.dart';

class MessagerieMenu extends StatefulWidget {
  MessagerieMenu({Key key}) : super(key: key);

  @override
  _MessagerieMenuState createState() => _MessagerieMenuState();
}

class _MessagerieMenuState extends State<MessagerieMenu> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).accentColor
          ])),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 50,
            child: DrawerHeader(
              child: Text('Messagerie/Notifications'),
            ),
          ),
        ],
      ),
    ));
  }
}
