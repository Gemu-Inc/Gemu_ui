import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  final List<IconData> icons;
  final TabController controller;

  const CustomTabBar({Key key, @required this.icons, @required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Positioned(
            left: 0,
            bottom: 0,
            child: Container(
                width: size.width,
                height: 65,
                color: Colors.transparent,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size(size.width, 70),
                      painter: BNBCustomPainter(
                          color: Colors.black12.withOpacity(0.4)),
                    ),
                    Container(
                      width: size.width,
                      height: 70,
                      child: TabBar(
                        indicator: CircleTabIndicator(
                            color: Theme.of(context).accentColor, radius: 3),
                        tabs: [
                          Tab(
                            icon: Icon(
                              icons[0],
                              size: 30,
                              color: controller.index == 0
                                  ? Theme.of(context).accentColor
                                  : Colors.grey,
                            ),
                          ),
                          Tab(
                            icon: Icon(
                              icons[1],
                              size: 30,
                              color: controller.index == 1
                                  ? Theme.of(context).accentColor
                                  : Colors.grey,
                            ),
                          ),
                          Tab(
                            icon: Icon(
                              icons[2],
                              size: 30,
                              color: controller.index == 2
                                  ? Theme.of(context).accentColor
                                  : Colors.grey,
                            ),
                          ),
                          Tab(
                            icon: Icon(
                              icons[3],
                              size: 30,
                              color: controller.index == 3
                                  ? Theme.of(context).accentColor
                                  : Colors.grey,
                            ),
                          ),
                        ],
                        controller: controller,
                      ),
                    )
                  ],
                )))
      ],
    );
  }
}

class BNBCustomPainter extends CustomPainter {
  final Color color;

  const BNBCustomPainter({Key key, @required this.color}) : super();

  @override
  void paint(Canvas canvas, Size size) {
    print(color);
    Paint paint = new Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, 20); // Start
    path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.40, 0);
    path.quadraticBezierTo(size.width * 0.45, 0, size.width * 0.45, 20);
    path.arcToPoint(Offset(size.width * 0.55, 20),
        radius: Radius.circular(50.0), clockwise: false);
    path.quadraticBezierTo(size.width * 0.55, 0, size.width * 0.60, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 20);
    canvas.drawShadow(path, Colors.black, 5, true);
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
