import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/models/post.dart';
import 'package:gemu/components/post_tile.dart';

// ignore: must_be_immutable
class GameSection extends StatefulWidget {
  final Game game;
  final AnimationController animationRotateController, animationGamesController;
  bool panelGamesThere;
  final PageController pageController;

  GameSection(
      {required this.game,
      required this.animationGamesController,
      required this.animationRotateController,
      required this.panelGamesThere,
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

    await Future.delayed(Duration(seconds: 5));

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
        dataIsThere
            ? posts.length == 0
                ? Center(
                    child: Text(
                      'No posts at the moment ${widget.game.name}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  )
                : PageView.builder(
                    controller: widget.pageController,
                    physics: AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics()),
                    scrollDirection: Axis.vertical,
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      Post post = posts[index];
                      return PostTile(
                        idUserActual: me!.uid,
                        post: post,
                        positionDescriptionBar: 15.0,
                        positionActionsBar: 20.0,
                        isGameBar: false,
                        isFollowingsSection: false,
                      );
                    })
            : Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
      ],
    );
  }
}
