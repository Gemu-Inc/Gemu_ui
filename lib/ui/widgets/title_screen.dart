import 'package:flutter/material.dart';

class TitleScreen extends StatelessWidget {
  final String title;

  const TitleScreen({
    Key key,
    @required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
          color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
    );
  }
}
