import 'package:flutter/material.dart';

class CircularButton extends StatelessWidget {
  final double width;
  final double height;
  final Color colorFond;
  final Color colorBorder;
  final IconData icon;
  final double iconSize;
  final Function onPressed;

  CircularButton(
      {Key key,
      @required this.width,
      @required this.height,
      @required this.colorFond,
      @required this.colorBorder,
      @required this.icon,
      @required this.iconSize,
      @required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(3.0),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorFond,
        shape: BoxShape.circle,
        border: Border.all(color: colorBorder),
      ),
      child: Align(
          alignment: Alignment.center,
          child: IconButton(
              icon: Icon(icon),
              iconSize: iconSize,
              color: Colors.black,
              onPressed: onPressed)),
    );
  }
}
