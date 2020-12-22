import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:Gemu/ui/widgets/widgets.dart';
import 'package:Gemu/models/data.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget child;

  TopAppBar({Key key, @required this.preferredSize, @required this.child})
      : super(key: key);

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class GAppBar extends StatelessWidget {
  final String titre;
  final Widget buttonLeft, buttonRight;

  GAppBar(
      {Key key,
      @required this.titre,
      @required this.buttonLeft,
      @required this.buttonRight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GradientAppBar(
      elevation: 0,
      gradient: LinearGradient(colors: null),
      leading: buttonLeft,
      title: Text(
        titre,
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
      ),
      actions: [buttonRight],
    );
  }
}
