import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/models/post.dart';
import 'package:gemu/ui/widgets/post_tile.dart';

class GameSection extends StatefulWidget {
  final Game game;

  final AnimationController animationRotateController, animationGamesController;

  GameSection(
      {required this.game,
      required this.animationGamesController,
      required this.animationRotateController});

  @override
  GameSectionState createState() => GameSectionState();
}

class GameSectionState extends State<GameSection>
    with AutomaticKeepAliveClientMixin {
  late PageController _pageGamesController;
  int currentPageGamesIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _pageGamesController = PageController(initialPage: currentPageGamesIndex);
  }

  @override
  void dispose() {
    _pageGamesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('gameName', isEqualTo: widget.game.name)
            .where('privacy', isEqualTo: 'Public')
            .where('uid', isNotEqualTo: me!.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          }
          if (snapshot.data.docs.length == 0) {
            return Center(
              child: Text(
                'No posts at the moment',
                style: mystyle(11),
              ),
            );
          }
          return PageView.builder(
              controller: _pageGamesController,
              scrollDirection: Axis.vertical,
              onPageChanged: (index) {
                setState(() {
                  currentPageGamesIndex = index;
                  print('currentPageGamesIndex est à: $currentPageGamesIndex');
                });
                if (widget.animationRotateController.isCompleted) {
                  widget.animationRotateController.reverse();
                  widget.animationGamesController.reverse();
                }
              },
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                Post post = Post.fromMap(snapshot.data.docs[index],
                    snapshot.data.docs[index].data());

                return PostTile(idUserActual: me!.uid, post: post);
              });
        });
  }
}
