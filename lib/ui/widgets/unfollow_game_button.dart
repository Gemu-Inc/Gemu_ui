import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Gemu/services/auth_service.dart';
import 'package:Gemu/models/game.dart';
import 'package:Gemu/locator.dart';

class UnfollowGameButton extends StatefulWidget {
  final Game game;

  UnfollowGameButton({@required this.game});

  @override
  UnfollowGameButtonState createState() => UnfollowGameButtonState();
}

class UnfollowGameButtonState extends State<UnfollowGameButton>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = locator<AuthService>();
  AnimationController _animationController;
  Animation _colorTween;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _colorTween = ColorTween(begin: Colors.green[400], end: Colors.red[400])
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
                var currentUser = _authService.currentUser;
                if (_animationController.status == AnimationStatus.completed) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser.id)
                      .update({
                    'idGames': FieldValue.arrayUnion([widget.game.documentId])
                  });
                  _animationController.reverse();
                } else {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser.id)
                      .update({
                    'idGames': FieldValue.arrayRemove([widget.game.documentId])
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
                  child: _colorTween.value == Colors.green[400]
                      ? Icon(
                          Icons.check,
                          size: 20,
                        )
                      : Icon(
                          Icons.add,
                          size: 20,
                        )));
        });
  }
}
