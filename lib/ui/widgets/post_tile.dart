import 'package:flutter/material.dart';

import 'package:gemu/models/post.dart';

class PostTile extends StatefulWidget {
  final String idUserActual;
  final Post post;
  final bool isHome;

  PostTile(
      {required this.idUserActual, required this.post, this.isHome = false});

  @override
  PostTileState createState() => PostTileState();
}

class PostTileState extends State<PostTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
        tag: 'post',
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [],
          ),
        ));
  }
}
