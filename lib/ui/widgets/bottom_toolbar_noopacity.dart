import 'package:flutter/material.dart';

class BottomToolBarNoOpa extends StatelessWidget {
  final List<IconData> icons;
  final TabController controller;

  const BottomToolBarNoOpa(
      {Key key, @required this.icons, @required this.controller})
      : super(key: key);

  static const double NavigationIconSize = 25.0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Positioned(
        left: 0,
        bottom: 0,
        child: Container(
          decoration: BoxDecoration(color: Color(0xFF1A1C25), boxShadow: [
            BoxShadow(
              color: Color(0xFF121212),
              blurRadius: 1,
              spreadRadius: 3,
            )
          ]),
          width: size.width,
          height: 55,
          child: TabBar(
            indicatorColor: Colors.transparent,
            /*indicator: CircleTabIndicator(
                    color: Theme.of(context).accentColor, radius: 3),*/
            tabs: [
              Tab(
                icon: Icon(
                  icons[0],
                  size: NavigationIconSize,
                  color: controller.index == 0
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                child: Text(
                  'Home',
                  style: TextStyle(fontSize: 8),
                ),
              ),
              Tab(
                  iconMargin: EdgeInsets.only(bottom: 10.0, right: 20.0),
                  icon: Icon(
                    icons[1],
                    size: NavigationIconSize,
                    color: controller.index == 1
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(right: 19.0),
                    child: Text(
                      'Highlights',
                      style: TextStyle(fontSize: 8),
                    ),
                  )),
              Tab(
                  iconMargin: EdgeInsets.only(bottom: 10.0, left: 20.0),
                  icon: Icon(
                    icons[2],
                    size: NavigationIconSize,
                    color: controller.index == 2
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Text(
                      'Games',
                      style: TextStyle(fontSize: 8),
                    ),
                  )),
              Tab(
                icon: Icon(
                  icons[3],
                  size: NavigationIconSize,
                  color: controller.index == 3
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                child: Text(
                  'Direct',
                  style: TextStyle(fontSize: 8),
                ),
              ),
            ],
            controller: controller,
          ),
        ));
  }
}

class BNBCustomPainter extends CustomPainter {
  final Color color;

  const BNBCustomPainter({Key key, @required this.color}) : super();

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, 20); // Start
    path.lineTo(20, size.width * 0.20);
    path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.20, 0);
    path.arcToPoint(Offset(size.width * 0.55, 20),
        radius: Radius.circular(50.0), clockwise: false);
    path.quadraticBezierTo(size.width * 0.55, 0, size.width * 0.60, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 20);
    canvas.drawShadow(path, Color(0xFF333333), 1, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class CircleTabIndicator extends Decoration {
  final BoxPainter _painter;

  CircleTabIndicator({@required Color color, @required double radius})
      : _painter = _CirclePainter(color, radius);

  @override
  BoxPainter createBoxPainter([onChanged]) => _painter;
}

class _CirclePainter extends BoxPainter {
  final Paint _paint;
  final double radius;

  _CirclePainter(Color color, this.radius)
      : _paint = Paint()
          ..color = color
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Offset circleOffset =
        offset + Offset(cfg.size.width / 2, cfg.size.height - radius - 5);
    canvas.drawCircle(circleOffset, radius, _paint);
  }
}
