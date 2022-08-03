import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemu/providers/Home/home_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/models/post.dart';
import 'package:gemu/components/post_tile.dart';
import 'package:gemu/services/database_service.dart';

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

class GameSectionState extends ConsumerState<GameSection> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<Post> posts = [];
  bool loadedPosts = false;
  int indexPageMoreData = 0;

  Future<void> getPosts() async {
    try {
      posts = await DatabaseService.getPostsGame(widget.game.name);
      setState(() {
        loadedPosts = true;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> getMorePosts() async {
    try {
      Post lastPost = posts.last;
      List<Post> newPosts =
          await DatabaseService.getMorePostsGame(widget.game.name, lastPost);
      if (newPosts.length != 0) {
        posts = [...posts, ...newPosts];
      }
      setState(() {
        indexPageMoreData = widget.pageController.page!.toInt();
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> refreshPosts() async {
    try {
      setState(() {
        loadedPosts = false;
      });
      posts = await DatabaseService.getPostsGame(widget.game.name);
      if (posts.length != 0) {
        widget.pageController.jumpToPage(0);
      }
      setState(() {
        loadedPosts = true;
      });
      _refreshController.refreshCompleted();
    } catch (e) {
      print(e);
      _refreshController.refreshFailed();
    }
  }

  @override
  void initState() {
    super.initState();

    getPosts();

    widget.pageController.addListener(() async {
      if (widget.pageController.page!.toInt() != 0 &&
          widget.pageController.page!.toInt() % 2 == 0) {
        if (indexPageMoreData != widget.pageController.page!.toInt() &&
            indexPageMoreData < widget.pageController.page!.toInt()) {
          await getMorePosts();
        }
      }
    });
  }

  @override
  void deactivate() {
    widget.pageController.removeListener(() async {
      if (widget.pageController.page!.toInt() != 0 &&
          widget.pageController.page!.toInt() % 2 == 0) {
        if (indexPageMoreData != widget.pageController.page!.toInt() &&
            indexPageMoreData < widget.pageController.page!.toInt()) {
          await getMorePosts();
        }
      }
    });
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return loadedPosts
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
          );
  }
}
