import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/models/post.dart';
import 'package:gemu/ui/views/Autres/post_tile.dart';

class FollowingSection extends StatefulWidget {
  final List followings;
  final PageController pageController;

  FollowingSection({required this.followings, required this.pageController});

  @override
  FollowingSectionState createState() => FollowingSectionState();
}

class FollowingSectionState extends State<FollowingSection>
    with AutomaticKeepAliveClientMixin {
  bool dataIsThere = false;

  List followings = [];
  List<Post> posts = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    followings = widget.followings;
    getPostsFollowing();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getPostsFollowing() async {
    print('followings: ${followings.length}');

    if (followings.length != 0) {
      for (var i = 0; i < followings.length; i++) {
        await FirebaseFirestore.instance
            .collection('posts')
            .where('uid', isEqualTo: followings[i])
            .orderBy('date', descending: true)
            .get()
            .then((data) {
          for (var item in data.docs) {
            posts.add(Post.fromMap(item, item.data()));
          }
        });
      }
    }

    if (!dataIsThere) {
      setState(() {
        dataIsThere = true;
      });
    }
  }

  Future refreshData() async {
    setState(() {
      dataIsThere = false;
    });

    await Future.delayed(Duration(seconds: 2));

    if (followings.length != 0) {
      posts.clear();
      print('posts clear: ${posts.length}');
      for (var i = 0; i < followings.length; i++) {
        await FirebaseFirestore.instance
            .collection('posts')
            .where('uid', isEqualTo: followings[i])
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
      print('${posts.length}');
      dataIsThere = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return dataIsThere
        ? posts.length == 0
            ? Center(
                child: Text('No following/posts at the moment',
                    style: mystyle(11, Colors.white)),
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
              color: Theme.of(context).primaryColor,
            ),
          );
  }
}
