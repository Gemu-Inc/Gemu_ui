import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/models/post.dart';
import 'package:gemu/components/post_tile.dart';
import 'package:gemu/providers/Home/home_provider.dart';

class GameSection extends ConsumerStatefulWidget {
  final Game game;
  final PageController pageController;
  final AnimationController animationRotateController, animationGamesController;

  GameSection({
    required this.game,
    required this.pageController,
    required this.animationGamesController,
    required this.animationRotateController,
  });

  @override
  GameSectionState createState() => GameSectionState();
}

class GameSectionState extends ConsumerState<GameSection>
    with AutomaticKeepAliveClientMixin {
  List<Post> posts = [];
  bool loadedPosts = false;

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

  Future<void> getPostsGame() async {
    QuerySnapshot<Map<String, dynamic>> data = await FirebaseFirestore.instance
        .collection('posts')
        .where('gameName', isEqualTo: widget.game.name)
        .where('privacy', isEqualTo: 'Public')
        .orderBy('date', descending: true)
        .get();

    for (var item in data.docs) {
      if (item.data()['uid'] != me!.uid) {
        posts.add(Post.fromMap(item, item.data()));
      }
    }

    posts.shuffle();

    setState(() {
      loadedPosts = true;
    });
  }

  Future<void> refreshPostsGame() async {
    setState(() {
      loadedPosts = false;
    });

    posts.clear();

    QuerySnapshot<Map<String, dynamic>> data = await FirebaseFirestore.instance
        .collection('posts')
        .where('gameName', isEqualTo: widget.game.name)
        .where('privacy', isEqualTo: 'Public')
        .orderBy('date', descending: true)
        .get();

    for (var item in data.docs) {
      if (item.data()['uid'] != me!.uid) {
        posts.add(Post.fromMap(item, item.data()));
      }
    }

    posts.shuffle();

    setState(() {
      loadedPosts = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Stack(
      children: [
        loadedPosts
            ? posts.length == 0
                ? Center(
                    child: Text(
                      'Pas de posts actuellement sur ${widget.game.name}',
                      style: textStyleCustomRegular(Colors.white, 14),
                      textAlign: TextAlign.center,
                    ),
                  )
                : PageView.builder(
                    controller: widget.pageController,
                    onPageChanged: (index) {
                      if (widget.animationRotateController.isCompleted) {
                        widget.animationRotateController.reverse();
                        widget.animationGamesController.reverse();
                      }
                    },
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
                  strokeWidth: 1.0,
                ),
              ),
      ],
    );
  }
}
