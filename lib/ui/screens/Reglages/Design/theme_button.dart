import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme_notifier.dart';

class ThemeButton extends StatelessWidget {
  final ThemeData buttonThemeData;

  ThemeButton({required this.buttonThemeData});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return RawMaterialButton(
      onPressed: () {
        themeNotifier.setTheme(buttonThemeData);
      },
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 400),
        transitionBuilder: (Widget child, Animation<double> animation) =>
            ScaleTransition(
          child: child,
          scale: animation,
        ),
        child: _getIcon(themeNotifier),
      ),
      shape: CircleBorder(),
      elevation: 2.0,
      fillColor: buttonThemeData.scaffoldBackgroundColor,
      padding: const EdgeInsets.all(5.0),
    );
  }

  Widget _getIcon(ThemeNotifier themeNotifier) {
    bool selected = (themeNotifier.getTheme() == buttonThemeData);

    return Container(
      height: 50,
      width: 50,
      key: Key((selected) ? "ON" : "OFF"),
      decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              buttonThemeData.colorScheme.primary,
              buttonThemeData.colorScheme.secondary
            ],
          ),
          borderRadius: BorderRadius.circular(40)),
      child: Icon(
        (selected) ? Icons.done : Icons.close,
        size: 20.0,
      ),
    );
  }
}
