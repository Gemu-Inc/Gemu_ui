import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:Gemu/ui/screens/Home/components/picture_item.dart';
import 'package:Gemu/ui/screens/Home/components/video_player_item.dart';
import 'package:Gemu/ui/screens/Home/components/actions_postbar.dart';
import 'package:Gemu/ui/screens/Home/components/content_postdescription.dart';

import 'comment_postbar.dart';

class PostsProfilScreen extends StatefulWidget {
  final String? userID;
  final int? indexPost;

  PostsProfilScreen({required this.userID, this.indexPost});

  @override
  PostsProfilScreenState createState() => PostsProfilScreenState();
}

class PostsProfilScreenState extends State<PostsProfilScreen> {
  bool dataIsThere = false;

  PageController? _pageController;
  FocusNode? _focusNode;

  Stream? stream;
  String? uid;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.indexPost!);
    _focusNode = FocusNode();

    getAllData();
  }

  @override
  void dispose() {
    _pageController!.dispose();
    _focusNode!.dispose();
    super.dispose();
  }

  getAllData() async {
    uid = FirebaseAuth.instance.currentUser!.uid;

    stream = FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: widget.userID)
        .where('privacy', isEqualTo: "Public")
        .snapshots();

    setState(() {
      dataIsThere = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: GestureDetector(
          onTap: () {
            if (_focusNode!.hasFocus) {
              _focusNode!.unfocus();
            }
          },
          child: Stack(
            children: [
              StreamBuilder(
                stream: stream,
                builder: (context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.vertical,
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        DocumentSnapshot<Map<String, dynamic>> post =
                            snapshot.data.docs[index];

                        return Stack(
                          children: [
                            post.data()!['videoUrl'] == null
                                ? PictureItem(
                                    idUser: post.data()!['uid'],
                                    idPost: post.data()!['id'],
                                    pictureUrl: post.data()!['pictureUrl'])
                                : VideoPlayerItem(
                                    idUser: post.data()!['uid'],
                                    idPost: post.data()!['id'],
                                    videoUrl: post.data()!['videoUrl']),
                            Positioned(
                                left: 0,
                                bottom: 70,
                                child: ContentPostDescription(
                                  idUser: post.data()!['uid'],
                                  username: post.data()!['username'],
                                  caption: post.data()!['caption'],
                                  hashtags: post.data()!['hashtags'],
                                )),
                            Positioned(
                                right: 0,
                                bottom: 50,
                                child: ActionsPostBar(
                                  idUser: post.data()!['uid'],
                                  idPost: post.data()!['id'],
                                  profilPicture: post.data()!['profilepicture'],
                                  commentsCounts:
                                      post.data()!['commentcount'].toString(),
                                  up: post.data()!['up'],
                                  down: post.data()!['down'],
                                )),
                            Positioned(
                                bottom: 0,
                                child: CommentPostBar(
                                  idPost: post.data()!['id'],
                                  focusNode: _focusNode,
                                ))
                          ],
                        );
                      });
                },
              ),
              Positioned(
                left: 10,
                top: 30,
                child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.expand_more,
                      size: 33,
                    )),
              ),
            ],
          )),
    );
  }
}
