import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:gemu/constants/constants.dart';

class BottomShare extends StatefulWidget {
  @override
  _BottomShare createState() => _BottomShare();
}

class _BottomShare extends State<BottomShare> with TickerProviderStateMixin {
  late AnimationController animationController;
  late Animation degOneTranslationAnimation, degTwoTranslationAnimation;
  late Animation rotationAnimationCircularButton;
  late Animation rotationAnimationFlatButton;

  Timer? timer;

  double getRadianFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  void startTimer() {
    timer = Timer(Duration(seconds: 6), () {
      if (animationController.isCompleted) {
        animationController.reverse();
      }
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  showOptionsImage() {
    return showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0))),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 6,
        builder: (context) {
          return Container(
            height: 175,
            child: Column(
              children: [
                ListTile(
                  onTap: () => pickImage(ImageSource.camera),
                  leading: Icon(Icons.photo_camera),
                  title: Text('Appareil photo',
                      style: Theme.of(context).textTheme.titleSmall),
                ),
                ListTile(
                  onTap: () => pickImage(ImageSource.gallery),
                  leading: Icon(Icons.photo),
                  title: Text('Gallerie',
                      style: Theme.of(context).textTheme.titleSmall),
                ),
                ListTile(
                  onTap: () => Navigator.pop(context),
                  leading: Icon(Icons.clear),
                  title: Text('Annuler',
                      style: Theme.of(context).textTheme.titleSmall),
                )
              ],
            ),
          );
        });
  }

  showOptionsVideo() {
    return showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0))),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 6,
        builder: (context) {
          return Container(
            height: 175,
            child: Column(
              children: [
                ListTile(
                  onTap: () => pickVideo(ImageSource.camera),
                  leading: Icon(Icons.photo_camera),
                  title: Text('Caméra',
                      style: Theme.of(context).textTheme.titleSmall),
                ),
                ListTile(
                  onTap: () => pickVideo(ImageSource.gallery),
                  leading: Icon(Icons.photo),
                  title: Text('Gallerie',
                      style: Theme.of(context).textTheme.titleSmall),
                ),
                ListTile(
                  onTap: () => Navigator.pop(context),
                  leading: Icon(Icons.clear),
                  title: Text('Annuler',
                      style: Theme.of(context).textTheme.titleSmall),
                )
              ],
            ),
          );
        });
  }

  pickImage(ImageSource src) async {
    try {
      final image =
          await ImagePicker().getImage(source: src, imageQuality: 100);
      if (image != null) {
        navMainAuthKey.currentState!
            .pushNamed(PictureEditor, arguments: [File(image.path)]);
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      print(e);
    }
  }

  pickVideo(ImageSource src) async {
    try {
      final video = await ImagePicker()
          .getVideo(source: src, maxDuration: Duration(seconds: 10));
      if (video != null) {
        navMainAuthKey.currentState!
            .pushNamed(VideoEditor, arguments: [File(video.path)]);
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      print(e);
    }
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
    rotationAnimationFlatButton = Tween<double>(begin: 0.0, end: 180.0).animate(
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
    return Stack(
      children: [
        Transform.translate(
          offset: Offset.fromDirection(
              getRadianFromDegree(235), degOneTranslationAnimation.value * 75),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Transform(
                transform: Matrix4.rotationZ(
                    getRadianFromDegree(rotationAnimationCircularButton.value))
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
                      stopTimer();
                      animationController.reverse();
                      showOptionsImage();
                    })),
          ),
        ),
        Transform.translate(
          offset: Offset.fromDirection(
              getRadianFromDegree(305), degTwoTranslationAnimation.value * 75),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Transform(
                transform: Matrix4.rotationZ(
                    getRadianFromDegree(rotationAnimationCircularButton.value))
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
                      stopTimer();
                      animationController.reverse();
                      showOptionsVideo();
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
                      stopTimer();
                    } else {
                      animationController.forward();
                      startTimer();
                    }
                  },
                  backgroundColor: Colors.transparent,
                  elevation: 2.0,
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
    );
  }
}
