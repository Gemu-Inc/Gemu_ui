import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/models/post.dart';
import 'package:gemu/ui/widgets/post_tile.dart';

class GameSection extends StatefulWidget {
  final Game game;
  final AnimationController animationRotateController, animationGamesController;
  final PageController pageController;

  GameSection(
      {required this.game,
      required this.animationGamesController,
      required this.animationRotateController,
      required this.pageController});

  @override
  GameSectionState createState() => GameSectionState();
}

class GameSectionState extends State<GameSection>
    with AutomaticKeepAliveClientMixin {
  bool dataIsThere = false;

  List<Post> posts = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    getPostsGame();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getPostsGame() async {
    await FirebaseFirestore.instance
        .collection('posts')
        .where('gameName', isEqualTo: widget.game.name)
        .where('privacy', isEqualTo: 'Public')
        .orderBy('date', descending: true)
        .get()
        .then((data) {
      for (var item in data.docs) {
        if (item.data()['uid'] != me!.uid) {
          posts.add(Post.fromMap(item, item.data()));
        }
      }
    });

    posts.shuffle();

    if (!dataIsThere && mounted) {
      setState(() {
        dataIsThere = true;
      });
    }
  }

  Future refreshData() async {
    setState(() {
      dataIsThere = false;
    });

    posts.clear();

    await Future.delayed(Duration(seconds: 2));

    await FirebaseFirestore.instance
        .collection('posts')
        .where('gameName', isEqualTo: widget.game.name)
        .where('privacy', isEqualTo: 'Public')
        .orderBy('date', descending: true)
        .get()
        .then((data) {
      for (var item in data.docs) {
        if (item.data()['uid'] != me!.uid) {
          posts.add(Post.fromMap(item, item.data()));
        }
      }
    });

    posts.shuffle();

    setState(() {
      dataIsThere = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        RefreshIndicator(
            backgroundColor: Theme.of(context).canvasColor,
            color: Theme.of(context).primaryColor,
            displacement:
                widget.animationRotateController.isCompleted ? 170 : 100,
            onRefresh: () {
              print('refresh');
              return refreshData();
            },
            child: dataIsThere
                ? posts.length == 0
                    ? Center(
                        child: Text(
                          'No posts at the moment',
                          style: mystyle(11, Colors.white),
                        ),
                      )
                    : PageView.builder(
                        controller: widget.pageController,
                        physics: AlwaysScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        onPageChanged: (index) {
                          /*setState(() {
                              currentPageGamesIndex = index;
                              print(
                                  'currentPageGamesIndex est à: $currentPageGamesIndex');
                            });*/
                          if (widget.animationRotateController.isCompleted) {
                            widget.animationRotateController.reverse();
                            widget.animationGamesController.reverse();
                          }
                        },
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          Post post = posts[index];

                          return PostTile(idUserActual: me!.uid, post: post);
                        })
                : Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  )),
      ],
    );
  }
}
