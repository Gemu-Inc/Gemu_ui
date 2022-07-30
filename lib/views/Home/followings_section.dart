import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/models/post.dart';
import 'package:gemu/components/post_tile.dart';
import 'package:gemu/models/user.dart';
import 'package:gemu/providers/Users/myself_provider.dart';
import 'package:gemu/services/database_service.dart';

class FollowingSection extends ConsumerStatefulWidget {
  final PageController pageController;

  FollowingSection({required this.pageController});

  @override
  FollowingSectionState createState() => FollowingSectionState();
}

class FollowingSectionState extends ConsumerState<FollowingSection>
    with AutomaticKeepAliveClientMixin {
  bool loadedPosts = false;
  int indexPageMoreData = 0;
  List<Post> posts = [];

  @override
  bool get wantKeepAlive => true;

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
  void dispose() {
    super.dispose();
  }

  Future<void> getPosts() async {
    List<UserModel> followings = ref.read(myFollowingsNotifierProvider);

    try {
      if (followings.length != 0) {
        posts = await DatabaseService.getPostsFollowings(followings);
      }
      setState(() {
        loadedPosts = true;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> getMorePosts() async {
    List<UserModel> followings = ref.read(myFollowingsNotifierProvider);

    try {
      Post lastPost = posts.last;
      List<Post> newPosts =
          await DatabaseService.getMorePostsFollowings(followings, lastPost);
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

  Future refreshPosts() async {
    List<UserModel> followings = ref.read(myFollowingsNotifierProvider);

    try {
      setState(() {
        loadedPosts = false;
      });
      if (followings.length != 0) {
        posts = await DatabaseService.getPostsFollowings(followings);
      }
      widget.pageController.jumpToPage(0);
      setState(() {
        loadedPosts = true;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return loadedPosts
        ? posts.length == 0
            ? Center(
                child: Text(
                  'Pas de posts actuellement dans vos abonnements',
                  style: textStyleCustomRegular(Colors.white, 14),
                  textAlign: TextAlign.center,
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
                    isFollowingsSection: true,
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
