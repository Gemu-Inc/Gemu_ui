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
    return Stack(
      children: [
        RefreshIndicator(
          backgroundColor: Theme.of(context).canvasColor,
          color: Theme.of(context).primaryColor,
          displacement: 100,
          onRefresh: () {
            print('refresh');
            return refreshData();
          },
          child: dataIsThere
              ? posts.length == 0
                  ? Center(
                      child: Text('No following/posts at the moment',
                          style: mystyle(11)),
                    )
                  : PageView.builder(
                      controller: _pageFollowingController,
                      physics: AlwaysScrollableScrollPhysics(),
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
                ),
        ),
        topAppBarFollowing()
      ],
    );
  }

  Widget topAppBarFollowing() {
    return GestureDetector(
      onTap: () {
        _pageFollowingController.jumpToPage(0);
        setState(() {
          currentPageFollowingIndex = 0;
        });
      },
      child: Container(
          height: 55,
          alignment: Alignment.center,
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10.0),
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).accentColor
                    ])),
            child: Icon(
              Icons.subscriptions,
              color: Colors.black,
              size: 30,
            ),
          )),
    );
  }
}
