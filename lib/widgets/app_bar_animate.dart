import 'package:Gemu/models/categorie_model.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/widgets/widgets.dart';
import 'package:Gemu/data/data.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class AppBarAnimate extends StatefulWidget {
  AppBarAnimate({Key key}) : super(key: key);

  @override
  _AppBarAnimateState createState() => _AppBarAnimateState();
}

class _AppBarAnimateState extends State<AppBarAnimate>
    with SingleTickerProviderStateMixin {
  _AppBarAnimateState() {
    controller = new AnimationController(
        duration: new Duration(milliseconds: 500), vsync: this);
    animation = new CurvedAnimation(parent: controller, curve: Curves.easeIn);
  }

  AnimationController controller;
  Animation animation;
  bool expanded = false;
  Function onPress;

  bool _animateAppBar() {
    expanded ? controller.reverse() : controller.forward();
    expanded = !expanded;
    //print(expanded);
    return expanded;
  }

  @override
  Widget build(BuildContext context) {
    return AppBarAnimateSize(
      animation: animation,
      onPress: _animateAppBar,
    );
  }
}

class AppBarAnimateSize extends AnimatedWidget {
  AppBarAnimateSize({
    Key key,
    Animation<double> animation,
    this.onPress,
  }) : super(key: key, listenable: animation);

  final Function onPress;

  static final _sizeTween = new Tween<double>(begin: 100.0, end: 555.0);

  bool expanded = false;

  bool _test() {
    bool test = false;
    if (_sizeTween.evaluate(listenable) == _sizeTween.end) {
      test = true;
    } else {
      test = false;
    }
    return test;
  }

  @override
  Widget build(BuildContext context) {
    expanded = _test();
    return PreferredSize(
        preferredSize: new Size.fromHeight(_sizeTween.evaluate(listenable)),
        child: ClipPath(
          clipper: ClipperCustomAppBar(),
          child: Container(
              height: _sizeTween.evaluate(listenable),
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
                          //color: expanded ? Colors.pink : Colors.purple,
                          child: ChoixCategorie(
                            expanded: expanded,
                          ),
                        ),
                      )),
                  Align(
                    alignment: Alignment.topCenter,
                    child: IconButton(
                        icon: Icon(
                          Icons.expand_more,
                          size: 35,
                          color: Colors.black,
                        ),
                        onPressed: onPress),
                  ),
                ],
              )),
        ));
  }
}
