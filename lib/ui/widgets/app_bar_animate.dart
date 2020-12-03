import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/ui/widgets/widgets.dart';
import 'package:Gemu/models/data.dart';
import 'package:Gemu/models/user.dart';

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

  static final _sizeTween = new Tween<double>(begin: 40.0, end: 550.0);

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
      child: Container(
          height: _sizeTween.evaluate(animation),
          child: expanded
              ? ClipPath(
                  clipper: ClipperCustomAppBar(),
                  child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).accentColor
                        ])),
                    child: Stack(children: [
                      Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Transform(
                              transform: Matrix4.rotationZ(
                                  getRadianFromDegree(animationRotate.value)),
                              alignment: Alignment.center,
                              child: GestureDetector(
                                  onTap: () {
                                    if (controllerRotate.isCompleted) {
                                      controllerRotate.reverse();
                                    } else {
                                      controllerRotate.forward();
                                    }
                                    _animateAppBar();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.black),
                                    ),
                                    child: Icon(
                                      Icons.expand_more,
                                      size: 35,
                                      color: Colors.black,
                                    ),
                                  ))),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 65, left: 65),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: MessageUser(),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 300),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Que veux-tu voir dans ton actualité aujourd\'hui?',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                          )),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Align(
                          alignment: Alignment.center,
                          child: ChoixCategorie(expanded: expanded),
                        ),
                      )
                    ]),
                  ))
              : Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Transform(
                      transform: Matrix4.rotationZ(
                          getRadianFromDegree(animationRotate.value)),
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          if (controllerRotate.isCompleted) {
                            controllerRotate.reverse();
                          } else {
                            controllerRotate.forward();
                          }
                          _animateAppBar();
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme.of(context).primaryColor,
                                  Theme.of(context).accentColor
                                ]),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black),
                          ),
                          child: Icon(
                            Icons.expand_more,
                            size: 35,
                            color: Colors.black,
                          ),
                        ),
                      )),
                )),
    );
  }
}
