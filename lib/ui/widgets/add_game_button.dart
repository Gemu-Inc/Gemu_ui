import 'package:flutter/material.dart';

class AddGameButton extends StatefulWidget {
  @override
  AddGameButtonState createState() => AddGameButtonState();
}

class AddGameButtonState extends State<AddGameButton>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _colorTween;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _colorTween = ColorTween(begin: Colors.red, end: Colors.green)
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
        builder: (context, child) => GestureDetector(
              onTap: () {
                if (_animationController.status == AnimationStatus.completed) {
                  _animationController.reverse();
                } else {
                  _animationController.forward();
                }
              },
              child: Container(
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                      color: _colorTween.value,
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(0xFF222831))),
                  child: _colorTween.value == Colors.red
                      ? Icon(Icons.add)
                      : Icon(Icons.check)),
            ));
  }
}
