import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:Gemu/constants/variables.dart';
import 'package:Gemu/models/game.dart';

import 'components/picture_item.dart';
import 'components/video_player_item.dart';
import 'components/actions_postbar.dart';
import 'components/content_postdescription.dart';

class PostViewGame extends StatefulWidget {
  final Game game;

  final AnimationController? animationRotateController,
      animationGamesController;

  PostViewGame(
      {required this.game,
      required this.animationGamesController,
      required this.animationRotateController});

  @override
  PostViewGameState createState() => PostViewGameState();
}

class PostViewGameState extends State<PostViewGame> {
  PageController? _pageGamesController;

  int? currentPageGamesIndex;

  Stream? stream;

  @override
  void initState() {
    super.initState();
    _pageGamesController = PageController();
    currentPageGamesIndex = 0;

    stream = FirebaseFirestore.instance
        .collection('posts')
        .where('game', isEqualTo: widget.game.name)
        .where('privacy', isEqualTo: 'Public')
        .snapshots();
  }

  @override
  void dispose() {
    _pageGamesController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
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
          DocumentSnapshot<Map<String, dynamic>> post = posts[i];
          if (post.data()!['uid'] == FirebaseAuth.instance.currentUser!.uid) {
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
            controller: _pageGamesController,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) {
              setState(() {
                currentPageGamesIndex = index;
                print('currentPageGamesIndex est à: $currentPageGamesIndex');
              });
              if (widget.animationRotateController!.isCompleted) {
                widget.animationRotateController!.reverse();
                widget.animationGamesController!.reverse();
              }
            },
            itemCount: posts.length,
            itemBuilder: (context, index) {
              DocumentSnapshot<Map<String, dynamic>> post = posts[index];

              return Stack(children: [
                post.data()!['videoUrl'] == null
                    ? PictureItem(
                        idUser: post.data()!['uid'],
                        idPost: post.data()!['id'],
                        pictureUrl: post.data()!['pictureUrl'],
                      )
                    : VideoPlayerItem(
                        idUser: post.data()!['uid'],
                        idPost: post.data()!['id'],
                        videoUrl: post.data()!['videoUrl'],
                      ),
                Positioned(
                    left: 0,
                    bottom: 15,
                    child: ContentPostDescription(
                      idUser: post.data()!['uid'],
                      username: post.data()!['username'],
                      caption: post.data()!['caption'],
                      hashtags: post.data()!['hashtags'],
                    )),
                Positioned(
                    right: 0,
                    bottom: 5,
                    child: ActionsPostBar(
                      idUser: post.data()!['uid'],
                      idPost: post.data()!['id'],
                      profilPicture: post.data()!['profilepicture'],
                      commentsCounts: post.data()!['commentcount'].toString(),
                      up: post.data()!['up'],
                      down: post.data()!['down'],
                    )),
              ]);
            });
      },
    );
  }
}
