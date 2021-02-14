import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:Gemu/models/game.dart';

class FollowGameButton extends StatefulWidget {
  final Game game;

  FollowGameButton({@required this.game});

  @override
  FollowGameButtonState createState() => FollowGameButtonState();
}

class FollowGameButtonState extends State<FollowGameButton>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
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
                if (_animationController.status == AnimationStatus.completed) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(_firebaseAuth.currentUser.uid)
                      .update({
                    'idGames': FieldValue.arrayRemove([widget.game.documentId])
                  });
                  _animationController.reverse();
                } else {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(_firebaseAuth.currentUser.uid)
                      .update({
                    'idGames': FieldValue.arrayUnion([widget.game.documentId])
                  });
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
