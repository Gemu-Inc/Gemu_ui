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
  final int indexGames;
  final AnimationController animationRotateController, animationGamesController;

  GameSection({
    required this.game,
    required this.pageController,
    required this.indexGames,
    required this.animationGamesController,
    required this.animationRotateController,
  });

  @override
  GameSectionState createState() => GameSectionState();
}

class GameSectionState extends ConsumerState<GameSection>
    with AutomaticKeepAliveClientMixin {
  List<bool> loadedDataGame = [];
  List<List<Post>> posts = [];

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
    List<Post> posts = [];

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

    ref
        .read(postsGameNotifierProvider.notifier)
        .updatePostGameAtIndex(widget.indexGames, posts);

    ref
        .read(loadedDataGameProviderNotifier.notifier)
        .updateLoadedDataGamesAtIndex(widget.indexGames, true);
  }

  // Future<void> refreshPostsGame() async {
  //   ref
  //       .read(loadedDataGameProviderNotifier.notifier)
  //       .updateLoadedDataGamesAtIndex(widget.indexGames, false);

  //   posts.clear();

  //   QuerySnapshot<Map<String, dynamic>> data = await FirebaseFirestore.instance
  //       .collection('posts')
  //       .where('gameName', isEqualTo: widget.game.name)
  //       .where('privacy', isEqualTo: 'Public')
  //       .orderBy('date', descending: true)
  //       .get();

  //   for (var item in data.docs) {
  //     if (item.data()['uid'] != me!.uid) {
  //       posts.add(Post.fromMap(item, item.data()));
  //     }
  //   }

  //   posts.shuffle();

  //   ref
  //       .read(loadedDataGameProviderNotifier.notifier)
  //       .updateLoadedDataGamesAtIndex(widget.indexGames, true);
  // }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    loadedDataGame = ref.watch(loadedDataGameProviderNotifier);
    posts = ref.watch(postsGameNotifierProvider);

    return Stack(
      children: [
        loadedDataGame[widget.indexGames]
            ? posts[widget.indexGames].length == 0
                ? Center(
                    child: Text(
                      'Pas de posts actuellement sur ${widget.game.name}',
                      style: textStyleCustomRegular(Colors.white, 14),
                      textAlign: TextAlign.center,
                    ),
                  )
                : PageView.builder(
                    controller: widget.pageController,
                    physics: AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics()),
                    scrollDirection: Axis.vertical,
                    itemCount: posts[widget.indexGames].length,
                    itemBuilder: (context, index) {
                      Post post = posts[widget.indexGames][index];
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
