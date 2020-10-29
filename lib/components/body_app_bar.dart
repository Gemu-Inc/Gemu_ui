import 'package:flutter/material.dart';
import 'package:Gemu/components/components.dart';

class BodyAppBarNavScreen extends StatelessWidget {
  final Widget banniere, texte;

  const BodyAppBarNavScreen(
      {Key key, @required this.banniere, @required this.texte})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7C79A5), Color(0xFFDC804F)])),
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Expanded(
              child: Stack(
            children: [
              banniere,
              Positioned(left: 225, top: 30, child: texte),
              Container(),
            ],
          )),
        ],
      ),
    );
  }
}

class BodyAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ClipperCustomAppBar(),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF7C79A5), Color(0xFFDC804F)])),
      ),
    );
  }
}
