import 'dart:async';
//import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

//import 'package:gemu/ui/screens/Share/Post/camera.dart';
import 'package:gemu/ui/screens/Share/Post/create_post_screen.dart';

class BottomShare extends StatefulWidget {
  @override
  _BottomShare createState() => _BottomShare();
}

class _BottomShare extends State<BottomShare> with TickerProviderStateMixin {
  late AnimationController animationController;
  late Animation degOneTranslationAnimation, degTwoTranslationAnimation;
  late Animation rotationAnimationCircularButton;
  late Animation rotationAnimationFlatButton;
  //List<CameraDescription>? _cameras;

  double getRadianFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  void logError(String code, String? message) =>
      print('Error: $code\nError Message: $message');

  // Future<void> initializeCamera() async {
  //   try {
  //     final cameras = await availableCameras();
  //     _cameras = cameras;
  //     print('Camera description: $_cameras');
  //     Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //             builder: (context) => CameraPost(
  //                   cameras: _cameras,
  //                 )));
  //   } on CameraException catch (e) {
  //     logError(e.code, e.description);
  //   }
  // }

  @override
  void initState() {
    super.initState();
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
          tween: Tween<double>(begin: 0.0, end: 1.75), weight: 35.0),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.75, end: 1.0), weight: 35.0),
    ]).animate(animationController);
    rotationAnimationCircularButton = Tween<double>(begin: 180.0, end: 0.0)
        .animate(CurvedAnimation(
            parent: animationController, curve: Curves.easeOut));
    rotationAnimationFlatButton = Tween<double>(begin: 360.0, end: 0.0).animate(
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
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Positioned(
            left: size.width / 4,
            right: size.width / 4,
            bottom: (size.height / 11) - 40,
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
                            animationController.reverse();
                            //initializeCamera(); //Pour initialiser les cameras directement sur l'appli
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return AddPostScreen();
                            }));
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
                                color: Theme.of(context).colorScheme.secondary),
                            child: Icon(
                              Icons.play_arrow,
                              size: 25,
                            ),
                          ),
                          onTap: () {
                            animationController.reverse();
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
                          elevation: 3.0,
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
                                          Theme.of(context)
                                              .colorScheme
                                              .secondary
                                        ])),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: ImageIcon(
                                  AssetImage('assets/images/share.png'),
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
}
