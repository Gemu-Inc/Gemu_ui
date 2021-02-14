import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChoixCategories extends StatefulWidget {
  final DocumentSnapshot categorie;

  ChoixCategories({
    Key key,
    @required this.categorie,
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
            this.setState(() {});
          });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _colorTween = ColorTween(
                begin: Theme.of(context).canvasColor, end: Colors.transparent)
            .animate(animationController),
        builder: (context, child) {
          return GestureDetector(
            child: Container(
                margin: EdgeInsets.all(5.0),
                height: 50,
                width: 120,
                decoration: BoxDecoration(
                    color: _colorTween.value,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Theme.of(context).canvasColor)),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(widget.categorie['name']),
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

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
