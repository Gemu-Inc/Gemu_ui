import 'package:flutter/material.dart';

class BouncingButton extends StatefulWidget {
  final Widget content;
  final double height;
  final double width;
  final VoidCallback onPressed;

  BouncingButton(
      {required this.content,
      required this.height,
      required this.width,
      required this.onPressed});

  @override
  BouncingButtonState createState() => BouncingButtonState();
}

class BouncingButtonState extends State<BouncingButton>
    with TickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300),
        lowerBound: 0.0,
        upperBound: 0.1)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void deactivate() {
    _controller.removeListener(() {
      setState(() {});
    });
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;
    return GestureDetector(
      onTapUp: _tapUp,
      onTapDown: _tapDown,
      child: Transform.scale(
        scale: _scale,
        child: Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Theme.of(context).colorScheme.primary),
            ),
            child: widget.content),
      ),
    );
  }

  void _tapDown(TapDownDetails? details) async {
    await _controller.forward();
  }

  void _tapUp(TapUpDetails? details) async {
    await _controller.reverse();
    widget.onPressed();
  }
}
