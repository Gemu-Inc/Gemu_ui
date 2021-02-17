import 'dart:async';
import 'package:flutter/material.dart';
import 'package:Gemu/constants/route_names.dart';

class BottomShare extends StatefulWidget {
  BottomShare({Key key, @required this.animationController});

  final AnimationController animationController;
  @override
  _BottomShare createState() => _BottomShare();
}

class _BottomShare extends State<BottomShare>
    with SingleTickerProviderStateMixin {
  Animation degOneTranslationAnimation, degTwoTranslationAnimation;
  Animation rotationAnimationCircularButton;
  Animation rotationAnimationFlatButton;

  double getRadianFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  @override
  void initState() {
    degOneTranslationAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 1.2), weight: 75.0),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.2, end: 1.0), weight: 25.0),
    ]).animate(widget.animationController);
    degTwoTranslationAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 1.75), weight: 35.0),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.75, end: 1.0), weight: 35.0),
    ]).animate(widget.animationController);
    rotationAnimationCircularButton = Tween<double>(begin: 180.0, end: 0.0)
        .animate(CurvedAnimation(
            parent: widget.animationController, curve: Curves.easeOut));
    rotationAnimationFlatButton = Tween<double>(begin: 360.0, end: 0.0).animate(
        CurvedAnimation(
            parent: widget.animationController, curve: Curves.easeOut));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Positioned(
            left: size.width / 4,
            right: size.width / 4,
            bottom: 20,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                IgnorePointer(
                    child: Container(
                  height: 100,
                  width: 200,
                  color: Colors.transparent,
                )),
                Transform.translate(
                  offset: Offset.fromDirection(getRadianFromDegree(235),
                      degOneTranslationAnimation.value * 75),
                  child: Transform(
                      transform: Matrix4.rotationZ(getRadianFromDegree(
                          rotationAnimationCircularButton.value))
                        ..scale(degOneTranslationAnimation.value),
                      alignment: Alignment.center,
                      child: GestureDetector(
                          child: Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Theme.of(context).primaryColor),
                            child: Icon(
                              Icons.add,
                              size: 25,
                            ),
                          ),
                          onTap: () {
                            widget.animationController.reverse();
                            Navigator.pushNamed(context, CreatePostRoute);
                          })),
                ),
                Transform.translate(
                  offset: Offset.fromDirection(getRadianFromDegree(305),
                      degTwoTranslationAnimation.value * 75),
                  child: Transform(
                      transform: Matrix4.rotationZ(getRadianFromDegree(
                          rotationAnimationCircularButton.value))
                        ..scale(degTwoTranslationAnimation.value),
                      alignment: Alignment.center,
                      child: GestureDetector(
                          child: Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Theme.of(context).accentColor),
                            child: Icon(
                              Icons.play_arrow,
                              size: 25,
                            ),
                          ),
                          onTap: () {
                            widget.animationController.reverse();
                            print('Démarrer l\'enregistrement d\'un clip');
                          })),
                ),
                Transform(
                    transform: Matrix4.rotationZ(
                        getRadianFromDegree(rotationAnimationFlatButton.value)),
                    alignment: Alignment.center,
                    child: Container(
                      height: 50,
                      width: 50,
                      child: FloatingActionButton(
                          heroTag: null,
                          onPressed: () {
                            if (widget.animationController.isCompleted) {
                              widget.animationController.reverse();
                            } else {
                              widget.animationController.forward();
                              Timer(Duration(seconds: 15), () {
                                if (widget.animationController.isCompleted) {
                                  widget.animationController.reverse();
                                  print('Timer over');
                                }
                              });
                            }
                          },
                          backgroundColor: Colors.transparent,
                          elevation: 6.0,
                          tooltip: 'Share',
                          child: Stack(
                            children: [
                              Container(
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
                                  AssetImage('lib/assets/images/share.png'),
                                  size: 30,
                                  color: Theme.of(context).canvasColor,
                                ),
                              )
                            ],
                          )),
                    )),
              ],
            ))
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
