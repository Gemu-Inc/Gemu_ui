import 'package:flutter/material.dart';
import 'package:Gemu/models/models.dart';

class ProfilButton extends StatelessWidget {
  final String currentUser;
  final double width, height;
  final Color colorFond, colorBorder;
  final Function onPress;

  const ProfilButton(
      {Key key,
      @required this.currentUser,
      @required this.width,
      @required this.height,
      @required this.colorFond,
      @required this.colorBorder,
      @required this.onPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onPress,
        child: Opacity(
          opacity: 0.7,
          child: Container(
            margin: EdgeInsets.only(top: 3.0, left: 3.0),
            width: width,
            height: height,
            decoration: BoxDecoration(
                color: colorFond,
                shape: BoxShape.circle,
                //borderRadius: BorderRadius.circular(15.0),
                border: Border.all(color: colorBorder),
                image: DecorationImage(
                    fit: BoxFit.cover, image: NetworkImage(currentUser))),
          ),
        ));
  }
}
