import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:Gemu/constants/variables.dart';

import 'components/picture_item.dart';
import 'components/video_player_item.dart';
import 'components/actions_postbar.dart';
import 'components/content_postdescription.dart';

class PostViewFollowing extends StatefulWidget {
  @override
  PostViewFollowingState createState() => PostViewFollowingState();
}

class PostViewFollowingState extends State<PostViewFollowing> {
  PageController _pageFollowingController;
  int currentPageFollowingIndex;

  String uid;
  bool dataIsThere = false;
  List posts = [];

  @override
  void initState() {
    super.initState();
    _pageFollowingController = PageController();
    currentPageFollowingIndex = 0;
    getAllData();
  }

  @override
  void dispose() {
    _pageFollowingController.dispose();
    super.dispose();
  }

  getAllData() async {
    uid = FirebaseAuth.instance.currentUser.uid;

    var following = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('following')
        .get();
    for (var item in following.docs) {
      posts.add(item.id);
      print(posts);
    }

    setState(() {
      dataIsThere = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return dataIsThere
        ? StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .where('uid', whereIn: posts)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.data.docs.length == 0) {
                return Center(
                  child: Text(
                    'No following at the moment',
                    style: mystyle(11),
                  ),
                );
              }

              return PageView.builder(
                  controller: _pageFollowingController,
                  scrollDirection: Axis.vertical,
                  onPageChanged: (index) {
                    setState(() {
                      currentPageFollowingIndex = index;
                      print(
                          'currentPageGamesIndex est à: $currentPageFollowingIndex');
                    });
                  },
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot post = snapshot.data.docs[index];
                    return Stack(children: [
                      post.data()['videoUrl'] == null
                          ? PictureItem(
                              idPost: post.data()['id'],
                              pictureUrl: post.data()['pictureUrl'],
                            )
                          : VideoPlayerItem(
                              videoUrl: post.data()['videoUrl'],
                            ),
                      Positioned(
                          left: 0,
                          bottom: 80,
                          child: ContentPostDescription(
                            idUser: post.data()['uid'],
                            username: post.data()['username'],
                            caption: post.data()['caption'],
                            hashtags: post.data()['hashtags'],
                          )),
                      Positioned(
                          right: 0,
                          bottom: 80,
                          child: ActionsPostBar(
                            idUser: post.data()['uid'],
                            idPost: post.data()['id'],
                            profilPicture: post.data()['profilepicture'],
                            commentsCounts:
                                post.data()['commentcount'].toString(),
                            up: post.data()['up'],
                            down: post.data()['down'],
                          ))
                    ]);
                  });
            })
        : Center(
            child: CircularProgressIndicator(),
          );
  }
}
