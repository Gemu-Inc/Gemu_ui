import 'package:cloud_firestore/cloud_firestore.dart';
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
  List<Post> posts = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    getPosts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getPosts() async {
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

  Future refreshData() async {
    List<UserModel> followings = ref.read(myFollowingsNotifierProvider);

    setState(() {
      loadedPosts = false;
    });

    await Future.delayed(Duration(seconds: 2));

    if (followings.length != 0) {
      posts.clear();
      print('posts clear: ${posts.length}');
      for (var i = 0; i < followings.length; i++) {
        await FirebaseFirestore.instance
            .collection('posts')
            .where('uid', isEqualTo: followings[i].uid)
            .orderBy('date', descending: true)
            .get()
            .then((data) {
          for (var item in data.docs) {
            posts.add(Post.fromMap(item, item.data()));
          }
        });
      }
    }
    setState(() {
      loadedPosts = true;
    });
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
