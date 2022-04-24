import 'dart:async';
import 'package:flutter/material.dart';

class BottomShare extends StatefulWidget {
  @override
  _BottomShare createState() => _BottomShare();
}

class _BottomShare extends State<BottomShare> with TickerProviderStateMixin {
  late AnimationController animationController;
  late Animation degOneTranslationAnimation, degTwoTranslationAnimation;
  late Animation rotationAnimationCircularButton;
  late Animation rotationAnimationFlatButton;

  double getRadianFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    degOneTranslationAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 1.2), weight: 75.0),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.2, end: 1.0), weight: 25.0),
    ]).animate(animationController);
    degTwoTranslationAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 1.75), weight: 35.0),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.75, end: 1.0), weight: 35.0),
    ]).animate(animationController);
    rotationAnimationCircularButton = Tween<double>(begin: 180.0, end: 0.0)
        .animate(CurvedAnimation(
            parent: animationController, curve: Curves.easeOut));
    rotationAnimationFlatButton = Tween<double>(begin: 180.0, end: 0.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOut));
    animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 15,
      left: MediaQuery.of(context).size.width / 4,
      right: MediaQuery.of(context).size.width / 4,
      child: Container(
        height: 150,
        child: Stack(
          children: [
            Transform.translate(
              offset: Offset.fromDirection(getRadianFromDegree(235),
                  degOneTranslationAnimation.value * 75),
              child: Align(
                alignment: Alignment.bottomCenter,
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
                              color: Theme.of(context).colorScheme.primary),
                          child: Icon(
                            Icons.photo,
                            color: Theme.of(context).canvasColor,
                            size: 25,
                          ),
                        ),
                        onTap: () {
                          animationController.reverse();
                          print('Post picture');
                          // Navigator.push(context,
                          //     MaterialPageRoute(builder: (context) {
                          //   return AddPostScreen();
                          // }));
                        })),
              ),
            ),
            Transform.translate(
              offset: Offset.fromDirection(getRadianFromDegree(305),
                  degTwoTranslationAnimation.value * 75),
              child: Align(
                alignment: Alignment.bottomCenter,
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
                              color: Theme.of(context).colorScheme.secondary),
                          child: Icon(
                            Icons.play_arrow,
                            color: Theme.of(context).canvasColor,
                            size: 25,
                          ),
                        ),
                        onTap: () {
                          animationController.reverse();
                          print('Post vidéo');
                        })),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Transform(
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
                          Timer(Duration(seconds: 6), () {
                            if (animationController.isCompleted) {
                              animationController.reverse();
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
                                      Theme.of(context).colorScheme.primary,
                                      Theme.of(context).colorScheme.secondary
                                    ])),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.add,
                              color: Theme.of(context).canvasColor,
                              size: 40,
                            ),
                          )
                        ],
                      ))),
            ),
          ],
        ),
      ),
    );
  }
}
