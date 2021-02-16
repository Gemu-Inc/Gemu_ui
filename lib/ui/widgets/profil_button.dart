import 'package:flutter/material.dart';

class ProfilButtonHome extends StatelessWidget {
  final String currentUser;
  final double width, height;
  final Color colorFond, colorBorder;
  final Function onPress;

  const ProfilButtonHome(
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
                border: Border.all(color: colorBorder),
                image: DecorationImage(
                    fit: BoxFit.cover, image: NetworkImage(currentUser))),
          ),
        ));
  }
}

class ProfilButtonHighlights extends StatelessWidget {
  final String currentUser;
  final double width, height;
  final Color colorFond, colorBorder;
  final Function onPress;

  const ProfilButtonHighlights(
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
    return Builder(
      builder: (context) => GestureDetector(
        onTap: onPress,
        child: Container(
          margin: EdgeInsets.only(top: 3.0, left: 3.0),
          width: width,
          height: height,
          decoration: BoxDecoration(
              color: colorFond,
              shape: BoxShape.circle,
              border: Border.all(color: colorBorder),
              image: DecorationImage(
                  fit: BoxFit.cover, image: NetworkImage(currentUser))),
        ),
      ),
    );
  }
}
