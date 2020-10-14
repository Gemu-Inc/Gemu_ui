import 'package:Gemu/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/data/data.dart';
import 'dart:math';

const CURVE_HEIGHT = 210.0;
const AVATAR_RADIUS = CURVE_HEIGHT * 0.20;
const AVATAR_DIAMETER = AVATAR_RADIUS * 2;

class BodyTest extends StatefulWidget {
  BodyTest({
    Key key,
    @required this.banniere,
    @required this.texte,
  }) : super(key: key);

  final Widget banniere, texte;

  @override
  _BodyTestState createState() => _BodyTestState();
}

class _BodyTestState extends State<BodyTest> {
  @override
  Widget build(BuildContext context) {
    return Flexible(
        child: CurvedShape(banniere: widget.banniere, texte: widget.texte));
  }
}

class CurvedShape extends StatelessWidget {
  final Widget banniere, texte;

  CurvedShape({
    Key key,
    @required this.banniere,
    @required this.texte,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ClipperCustomTest(),
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF7C79A5), Color(0xFFDC804F)])),
        width: double.infinity,
        height: 160,
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Expanded(
                child: Stack(
              children: [
                Align(alignment: Alignment.center, child: texte),
                //Positioned(left: 200, child: banniere),
                Container(),
              ],
            )),
          ],
        ),
      ),
    );
  }
}

class ClipperCustomTest extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Offset circleCenter = Offset(size.width / 2, size.height - 40);

    Offset topLeft = Offset(0, 0);
    Offset bottomLeft = Offset(0, size.height - 80);
    Offset topRight = Offset(size.width, 0);
    Offset bottomRight = Offset(size.width, size.height - 80);

    Offset leftCurveControlPoint =
        Offset(circleCenter.dx * 0.5, size.height - AVATAR_RADIUS);
    Offset rightCurveControlPoint =
        Offset(circleCenter.dx * 1.5, size.height - AVATAR_RADIUS);

    final arcStartAngle = 180 / 180 * pi;
    final avatarLeftPointX = circleCenter.dx + 32 * cos(arcStartAngle);
    final avatarLeftPointY = circleCenter.dy + 62 * sin(arcStartAngle);
    Offset avatarLeftPoint =
        Offset(avatarLeftPointX, avatarLeftPointY); // the left point of the arc

    final arcEndAngle = 0 / 180 * pi;
    final avatarRightPointX = circleCenter.dx + 32 * cos(arcEndAngle);
    final avatarRightPointY = circleCenter.dy + 62 * sin(arcEndAngle);
    Offset avatarRightPoint = Offset(avatarRightPointX, avatarRightPointY);

    var path = Path()
      ..lineTo(0, size.height * 0.75)
      ..quadraticBezierTo(
          size.width / 2, size.height, size.width, size.height * 0.75)
      ..lineTo(size.width, 0)
      ..close();

    /*..quadraticBezierTo(size.width / 2, 80, size.width, 0)
      ..close();*/

    /*..lineTo(0, size.height - 80)
      ..quadraticBezierTo(leftCurveControlPoint.dx, leftCurveControlPoint.dy,
          avatarLeftPoint.dx, avatarLeftPoint.dy)
      ..arcToPoint(avatarRightPoint, radius: Radius.circular(42))
      ..quadraticBezierTo(rightCurveControlPoint.dx, rightCurveControlPoint.dy,
          bottomRight.dx, bottomRight.dy)
      ..lineTo(size.width, 0)*/

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
