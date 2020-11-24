import 'package:flutter/material.dart';
import 'package:Gemu/models/models.dart';

class ProfilButton extends StatelessWidget {
  final UserLogin currentUser;
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
        child: Container(
          margin: EdgeInsets.all(3.0),
          width: width,
          height: height,
          decoration: BoxDecoration(
              color: colorFond,
              shape: BoxShape.circle,
              border: Border.all(color: colorBorder),
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(currentUser.imageProfil))),
        ));
  }
}
