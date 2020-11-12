import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:Gemu/components/components.dart';
import 'package:Gemu/core/data/data.dart';

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

class GAppBarNavScreen extends StatelessWidget {
  final String titre;
  final Widget buttonLeft, buttonRight;

  GAppBarNavScreen(
      {Key key,
      @required this.titre,
      @required this.buttonLeft,
      @required this.buttonRight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ClipperCustomAppBar(),
      child: GradientAppBar(
        elevation: 6,
        gradient: LinearGradient(
          colors: [Color(0xFF7C79A5), Color(0xFFDC804F)],
        ),
        leading: buttonLeft,
        title: Text(
          titre,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        actions: [buttonRight],
        bottom: PreferredSize(
            child: BodyAppBarNavScreen(
                banniere: ProfilBanniere(currentUser: currentUser),
                texte: MessageUser(currentUser: currentUser)),
            preferredSize: Size.fromHeight(210)),
      ),
    );
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

class GAppBarTest extends StatelessWidget {
  final String titre;
  final Widget buttonLeft, buttonRight;

  GAppBarTest(
      {Key key,
      @required this.titre,
      @required this.buttonLeft,
      @required this.buttonRight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ClipperCustomTest(),
      child: GradientAppBar(
        elevation: 0,
        gradient: LinearGradient(
          colors: [Color(0xFF7C79A5), Color(0xFFDC804F)],
        ),
        leading: buttonLeft,
        title: Text(
          titre,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        actions: [buttonRight],
        bottom: PreferredSize(
            child: BodyTest(
                banniere: ProfilBanniere(currentUser: currentUser),
                texte: MessageUser(currentUser: currentUser)),
            preferredSize: Size.fromHeight(160)),
      ),
    );
  }
}
