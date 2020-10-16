import 'package:flutter/material.dart';
import 'package:Gemu/widgets/widgets.dart';

class AppBarAnimate extends StatefulWidget {
  AppBarAnimate({Key key}) : super(key: key);

  @override
  _AppBarAnimateState createState() => _AppBarAnimateState();
}

class _AppBarAnimateState extends State<AppBarAnimate>
    with TickerProviderStateMixin {
  AnimationController controllerRotate;
  Animation animationRotate;
  AnimationController controller;
  Animation animation;
  bool expanded = false;

  static final _sizeTween = new Tween<double>(begin: 100.0, end: 555.0);

  bool test() {
    bool test = false;
    if (_sizeTween.evaluate(animation) == _sizeTween.end) {
      test = true;
    } else {
      test = false;
    }
    return test;
  }

  double getRadianFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  bool _animateAppBar() {
    expanded ? controller.reverse() : controller.forward();
    expanded = !expanded;
    return expanded;
  }

  @override
  void initState() {
    controllerRotate =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    animationRotate = Tween<double>(begin: 0.0, end: 180.0).animate(
        CurvedAnimation(parent: controllerRotate, curve: Curves.easeOut));
    controller = new AnimationController(
        duration: new Duration(milliseconds: 500), vsync: this);
    animation = new CurvedAnimation(parent: controller, curve: Curves.easeIn);
    super.initState();
    controllerRotate.addListener(() {
      setState(() {});
    });
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
        preferredSize: new Size.fromHeight(_sizeTween.evaluate(animation)),
        child: ClipPath(
          clipper: ClipperCustomAppBar(),
          child: Container(
              height: _sizeTween.evaluate(animation),
              child: Stack(
                children: [
                  Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).accentColor
                          ])),
                      width: double.infinity,
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          margin: EdgeInsets.all(5.0),
                          height: 300,
                          child: ChoixCategorie(
                            expanded: expanded,
                          ),
                        ),
                      )),
                  Align(
                      alignment: Alignment.topCenter,
                      child: Transform(
                        transform: Matrix4.rotationZ(
                            getRadianFromDegree(animationRotate.value)),
                        alignment: Alignment.center,
                        child: IconButton(
                            icon: Icon(
                              Icons.expand_more,
                              size: 35,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              if (controllerRotate.isCompleted) {
                                controllerRotate.reverse();
                              } else {
                                controllerRotate.forward();
                              }
                              _animateAppBar();
                            }),
                      )),
                ],
              )),
        ));
  }
}
