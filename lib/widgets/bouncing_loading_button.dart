import 'package:flutter/material.dart';

class BouncingLoadingButton extends StatefulWidget {
  final String title;
  final VoidCallback onPressed;

  BouncingLoadingButton({required this.title, required this.onPressed});

  @override
  BouncingLoadingButtonState createState() => BouncingLoadingButtonState();
}

class BouncingLoadingButtonState extends State<BouncingLoadingButton>
    with TickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  bool isLoading = false;

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
              width: MediaQuery.of(context).size.width / 1.5,
              height: 50,
              decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor,
                      offset: Offset(-5.0, 5.0),
                    )
                  ]),
              child: Center(
                child: isLoading
                    ? CircularProgressIndicator()
                    : Text(
                        widget.title,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
              ),
            )));
  }

  void _tapDown(TapDownDetails? details) async {
    setState(() {
      isLoading = true;
    });
    await _controller.forward();
  }

  void _tapUp(TapUpDetails? details) async {
    await _controller.reverse();
    widget.onPressed();
    setState(() {
      isLoading = false;
    });
  }
}
