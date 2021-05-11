import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:Gemu/constants/variables.dart';
import 'package:Gemu/ui/screens/Home/components/actions_postbar.dart';
import 'package:Gemu/ui/screens/Home/components/content_postdescription.dart';
import 'package:Gemu/ui/screens/Home/components/picture_item.dart';
import 'package:Gemu/ui/screens/Home/components/video_player_item.dart';
import 'package:Gemu/ui/screens/Profil/comment_postbar.dart';

class GameFocusScreen extends StatefulWidget {
  const GameFocusScreen({Key? key, required this.game}) : super(key: key);

  final DocumentSnapshot<Map<String, dynamic>>? game;

  @override
  _GameFocusScreenState createState() => _GameFocusScreenState();
}

class _GameFocusScreenState extends State<GameFocusScreen> {
  bool dataIsThere = false;

  PageController? _pageController;

  FocusNode? _focusNode;

  String? uid;
  Stream? stream;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _focusNode = FocusNode();
    getAllData();
  }

  @override
  void dispose() {
    _pageController!.dispose();
    super.dispose();
  }

  getAllData() async {
    uid = FirebaseAuth.instance.currentUser!.uid;

    stream = FirebaseFirestore.instance
        .collection('posts')
        .where('game', isEqualTo: widget.game!.data()!['name'])
        .where('privacy', isEqualTo: 'Public')
        .snapshots();

    setState(() {
      dataIsThere = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: dataIsThere
            ? GestureDetector(
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

                        List posts = snapshot.data.docs;
                        int i = 0;

                        while (i != posts.length) {
                          DocumentSnapshot<Map<String, dynamic>> post =
                              posts[i];
                          if (post.data()!['uid'] ==
                              FirebaseAuth.instance.currentUser!.uid) {
                            posts.remove(posts[i]);
                          } else {
                            i++;
                          }
                        }

                        if (posts.length == 0) {
                          return Center(
                            child: Text(
                              'Pas encore de posts pour ce jeu',
                              style: mystyle(11),
                            ),
                          );
                        }

                        return PageView.builder(
                            controller: _pageController,
                            scrollDirection: Axis.vertical,
                            itemCount: posts.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot<Map<String, dynamic>> post =
                                  posts[index];

                              return Stack(children: [
                                post.data()!['videoUrl'] == null
                                    ? PictureItem(
                                        idPost: post.data()!['id'],
                                        pictureUrl: post.data()!['pictureUrl'],
                                      )
                                    : VideoPlayerItem(
                                        idPost: post.data()!['id'],
                                        videoUrl: post.data()!['videoUrl'],
                                      ),
                                Positioned(
                                    left: 0,
                                    bottom: 50,
                                    child: ContentPostDescription(
                                      idUser: post.data()!['uid'],
                                      username: post.data()!['username'],
                                      caption: post.data()!['caption'],
                                      hashtags: post.data()!['hashtags'],
                                    )),
                                Positioned(
                                    right: 0,
                                    bottom: 45,
                                    child: ActionsPostBar(
                                      idUser: post.data()!['uid'],
                                      idPost: post.data()!['id'],
                                      profilPicture:
                                          post.data()!['profilepicture'],
                                      commentsCounts: post
                                          .data()!['commentcount']
                                          .toString(),
                                      up: post.data()!['up'],
                                      down: post.data()!['down'],
                                    )),
                                Positioned(
                                    bottom: 0,
                                    child: CommentPostBar(
                                      idPost: post.data()!['id'],
                                      focusNode: _focusNode,
                                    ))
                              ]);
                            });
                      },
                    ),
                    Positioned(
                        top: 30,
                        left: 10,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.expand_more,
                            size: 33,
                          ),
                        )),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 30.0),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Theme.of(context).primaryColor,
                                    Theme.of(context).accentColor
                                  ]),
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(color: Color(0xFF222831)),
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: CachedNetworkImageProvider(
                                      widget.game!.data()!['imageUrl']))),
                        ),
                      ),
                    )
                  ],
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ));
  }
}
