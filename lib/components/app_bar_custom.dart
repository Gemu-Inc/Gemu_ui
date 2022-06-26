import 'package:flutter/material.dart';

class AppBarCustom extends AppBar {
  AppBarCustom(
      {required BuildContext context,
      required String title,
      required List<Widget> actions})
      : super(
            backgroundColor: Colors.transparent,
            elevation: 6,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary
                  ])),
            ),
            leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios)),
            title: Text(title),
            centerTitle: false,
            actions: actions);
}
