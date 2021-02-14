import 'package:Gemu/models/models.dart';
import 'package:flutter/material.dart';

class ChoixTags extends StatefulWidget {
  final CategoriePost tag;

  ChoixTags({Key key, this.tag}) : super(key: key);

  @override
  _ChoixTagsState createState() => _ChoixTagsState();
}

class _ChoixTagsState extends State<ChoixTags>
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
                    child: Text('${widget.tag.name}'),
                  )),
              onTap: () {
                if (animationController.status == AnimationStatus.completed) {
                  animationController.reverse();
                } else {
                  animationController.forward();
                }
              });
        });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
