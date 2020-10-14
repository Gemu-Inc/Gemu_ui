import 'package:flutter/material.dart';
import 'package:Gemu/widgets/widgets.dart';

class BottomShare extends StatefulWidget {
  @override
  _BottomShare createState() => _BottomShare();
}

class _BottomShare extends State<BottomShare>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation degOneTranslationAnimation,
      degTwoTranslationAnimation,
      degThreeTranslationAnimation;
  Animation rotationAnimationCircularButton;
  Animation rotationAnimationFlatButton;

  double getRadianFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 350));
    degOneTranslationAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 1.2), weight: 75.0),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.2, end: 1.0), weight: 25.0),
    ]).animate(animationController);
    degTwoTranslationAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 1.4), weight: 55.0),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.4, end: 1.0), weight: 45.0),
    ]).animate(animationController);
    degThreeTranslationAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 1.75), weight: 35.0),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.75, end: 1.0), weight: 35.0),
    ]).animate(animationController);
    rotationAnimationCircularButton = Tween<double>(begin: 180.0, end: 0.0)
        .animate(CurvedAnimation(
            parent: animationController, curve: Curves.easeOut));
    rotationAnimationFlatButton = Tween<double>(begin: 360.0, end: 0.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOut));
    super.initState();
    animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Positioned(
            left: size.width / 4,
            right: size.width / 4,
            bottom: 40,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                IgnorePointer(
                    child: Container(
                  height: 250,
                  width: 200,
                  color: Colors.transparent,
                )),
                Transform.translate(
                  offset: Offset.fromDirection(getRadianFromDegree(225),
                      degOneTranslationAnimation.value * 85),
                  child: Transform(
                      transform: Matrix4.rotationZ(getRadianFromDegree(
                          rotationAnimationCircularButton.value))
                        ..scale(degOneTranslationAnimation.value),
                      alignment: Alignment.center,
                      child: GestureDetector(
                        child: Container(
                          height: 55,
                          width: 55,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Theme.of(context).primaryColor),
                          child: Icon(
                            Icons.photo_camera,
                            size: 30,
                          ),
                        ),
                        onTap: () => print('Photo'),
                      )),
                ),
                Transform.translate(
                  offset: Offset.fromDirection(getRadianFromDegree(270),
                      degTwoTranslationAnimation.value * 85),
                  child: Transform(
                      transform: Matrix4.rotationZ(getRadianFromDegree(
                          rotationAnimationCircularButton.value))
                        ..scale(degTwoTranslationAnimation.value),
                      alignment: Alignment.center,
                      child: GestureDetector(
                        child: Container(
                          height: 55,
                          width: 55,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Theme.of(context).primaryColor,
                                    Theme.of(context).accentColor
                                  ])),
                          child: Icon(
                            Icons.sms,
                            size: 30,
                          ),
                        ),
                        onTap: () => print('Texte'),
                      )),
                ),
                Transform.translate(
                  offset: Offset.fromDirection(getRadianFromDegree(315),
                      degThreeTranslationAnimation.value * 85),
                  child: Transform(
                      transform: Matrix4.rotationZ(getRadianFromDegree(
                          rotationAnimationCircularButton.value))
                        ..scale(degThreeTranslationAnimation.value),
                      alignment: Alignment.center,
                      child: GestureDetector(
                        child: Container(
                          height: 55,
                          width: 55,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Theme.of(context).accentColor),
                          child: Icon(
                            Icons.videocam,
                            size: 30,
                          ),
                        ),
                        onTap: () => print('Caméra'),
                      )),
                ),
                Transform(
                    transform: Matrix4.rotationZ(
                        getRadianFromDegree(rotationAnimationFlatButton.value)),
                    alignment: Alignment.center,
                    child: FloatingActionButton(
                        heroTag: null,
                        onPressed: () {
                          if (animationController.isCompleted) {
                            animationController.reverse();
                          } else {
                            animationController.forward();
                          }
                        },
                        elevation: 8.0,
                        tooltip: 'Share',
                        child: Stack(
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Theme.of(context).primaryColor,
                                        Theme.of(context).accentColor
                                      ])),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: ImageIcon(
                                AssetImage('img/share.png'),
                                size: 40,
                                color: Theme.of(context).secondaryHeaderColor,
                              ),
                            )
                          ],
                        ))),
              ],
            ))
      ],
    );
  }
}
