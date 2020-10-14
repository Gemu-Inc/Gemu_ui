import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';

class Game {
  final String nameGame;
  final Widget widget;
  final String imageUrl;

  const Game(
      {@required this.nameGame,
      @required this.widget,
      @required this.imageUrl});
}
