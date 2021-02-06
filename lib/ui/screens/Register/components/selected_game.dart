import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SelectedGameButton extends StatefulWidget {
  final DocumentSnapshot game;
  final List<String> test;

  SelectedGameButton({Key key, this.game, this.test}) : super(key: key);

  @override
  SelectedGameButtonState createState() => SelectedGameButtonState();
}

class SelectedGameButtonState extends State<SelectedGameButton>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _colorTween;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _colorTween = ColorTween(begin: Colors.red[400], end: Colors.green[400])
        .animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _colorTween,
        builder: (context, child) {
          return GestureDetector(
              onTap: () async {
                print(widget.game.data());
                if (_animationController.status == AnimationStatus.completed) {
                  widget.test.remove(widget.game.data()['name']);
                  _animationController.reverse();
                } else {
                  widget.test.add(widget.game.data()['name']);
                  _animationController.forward();
                }
                print(widget.test);
              },
              child: Container(
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                      color: _colorTween.value,
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(0xFF222831))),
                  child: _colorTween.value == Colors.red[400]
                      ? Icon(
                          Icons.add,
                          size: 20,
                        )
                      : Icon(
                          Icons.check,
                          size: 20,
                        )));
        });
  }
}
