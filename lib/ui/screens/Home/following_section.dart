import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/models/post.dart';
import 'package:gemu/ui/widgets/post_tile.dart';

class FollowingSection extends StatefulWidget {
  final List followings;

  FollowingSection({required this.followings});

  @override
  FollowingSectionState createState() => FollowingSectionState();
}

class FollowingSectionState extends State<FollowingSection>
    with AutomaticKeepAliveClientMixin {
  bool dataIsThere = false;

  int currentPageFollowingIndex = 0;
  late PageController _pageFollowingController;

  List followings = [];
  List<Post> posts = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _pageFollowingController =
        PageController(initialPage: currentPageFollowingIndex);
    followings = widget.followings;
    getPostsFollowing();
  }

  @override
  void dispose() {
    _pageFollowingController.dispose();
    super.dispose();
  }

  getPostsFollowing() async {
    print('followings: ${followings.length}');

    if (followings.length != 0) {
      for (var i = 0; i < followings.length; i++) {
        await FirebaseFirestore.instance
            .collection('posts')
            .where('uid', isEqualTo: followings[i])
            .get()
            .then((data) {
          for (var item in data.docs) {
            posts.add(Post.fromMap(item, item.data()));
          }
        });
      }
    }

    setState(() {
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
                    style: mystyle(11)),
              )
            : PageView.builder(
                controller: _pageFollowingController,
                scrollDirection: Axis.vertical,
                onPageChanged: (index) {
                  setState(() {
                    currentPageFollowingIndex = index;
                    print(
                        'currentPageGamesIndex est à: $currentPageFollowingIndex');
                  });
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
          );
  }
}
