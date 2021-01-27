import 'package:flutter/material.dart';
import 'package:Gemu/models/categorie.dart';

class ChoixCategories extends StatefulWidget {
  final Categorie e;

  ChoixCategories({
    Key key,
    @required this.e,
  }) : super(key: key);

  @override
  ChoixCategoriesState createState() => ChoixCategoriesState();
}

class ChoixCategoriesState extends State<ChoixCategories>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation _colorTween;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this)
          ..addListener(() {
            this.setState(() {
              print(widget.key);
            });
          });
    _colorTween = ColorTween(begin: Colors.black45, end: Colors.transparent)
        .animate(animationController);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _colorTween,
        builder: (context, child) {
          return GestureDetector(
            child: Container(
                margin: EdgeInsets.all(5.0),
                height: 50,
                width: 120,
                decoration: BoxDecoration(
                    color: _colorTween.value,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.black45)),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(widget.e.name),
                )),
            onTap: () {
              if (animationController.status == AnimationStatus.completed) {
                animationController.reverse();
              } else {
                animationController.forward();
              }
            },
          );
        });
  }
}
