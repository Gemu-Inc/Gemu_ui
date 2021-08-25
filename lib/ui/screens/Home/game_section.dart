import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/models/post.dart';
import 'package:gemu/ui/widgets/post_tile.dart';

class GameSection extends StatefulWidget {
  final Game game;

  final AnimationController animationRotateController, animationGamesController;

  GameSection(
      {required this.game,
      required this.animationGamesController,
      required this.animationRotateController});

  @override
  GameSectionState createState() => GameSectionState();
}

class GameSectionState extends State<GameSection>
    with AutomaticKeepAliveClientMixin {
  bool dataIsThere = false;

  List<Post> posts = [];

  late PageController _pageGamesController;
  int currentPageGamesIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _pageGamesController = PageController(initialPage: currentPageGamesIndex);
    getPostsGame();
  }

  @override
  void dispose() {
    _pageGamesController.dispose();
    super.dispose();
  }

  String generateRandomId() {
    const int AUTO_ID_LENGTH = 20;
    const String AUTO_ID_ALPHABET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

    const int maxRandom = AUTO_ID_ALPHABET.length;
    final Random randomGen = Random();

    String id = 'post';
    for (int i = 0; i < AUTO_ID_LENGTH; i++) {
      id = id + AUTO_ID_ALPHABET[randomGen.nextInt(maxRandom)];
    }

    return id;
  }

  getPostsGame() async {
    await FirebaseFirestore.instance
        .collection('posts')
        .where('gameName', isEqualTo: widget.game.name)
        .where('privacy', isEqualTo: 'Public')
        .orderBy('date', descending: true)
        .get()
        .then((data) {
      for (var item in data.docs) {
        if (item.data()['uid'] != me!.uid) {
          posts.add(Post.fromMap(item, item.data()));
        }
      }
    });

    posts.shuffle();

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

    posts.clear();

    await Future.delayed(Duration(seconds: 2));

    await FirebaseFirestore.instance
        .collection('posts')
        .where('gameName', isEqualTo: widget.game.name)
        .where('privacy', isEqualTo: 'Public')
        .orderBy('date', descending: true)
        .get()
        .then((data) {
      for (var item in data.docs) {
        if (item.data()['uid'] != me!.uid) {
          posts.add(Post.fromMap(item, item.data()));
        }
      }
    });

    posts.shuffle();

    setState(() {
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
            displacement:
                widget.animationRotateController.isCompleted ? 170 : 100,
            onRefresh: () {
              print('refresh');
              return refreshData();
            },
            child: dataIsThere
                ? posts.length == 0
                    ? Center(
                        child: Text(
                          'No posts at the moment',
                          style: mystyle(11),
                        ),
                      )
                    : PageView.builder(
                        controller: _pageGamesController,
                        physics: AlwaysScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        onPageChanged: (index) {
                          setState(() {
                            currentPageGamesIndex = index;
                            print(
                                'currentPageGamesIndex est à: $currentPageGamesIndex');
                          });
                          if (widget.animationRotateController.isCompleted) {
                            widget.animationRotateController.reverse();
                            widget.animationGamesController.reverse();
                          }
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
                  )),
        topAppBarGames()
      ],
    );
  }

  Widget topAppBarGames() {
    return GestureDetector(
      onTap: () {
        print('retour au début');
        _pageGamesController.jumpToPage(0);
        setState(() {
          currentPageGamesIndex = 0;
        });
      },
      child: Container(
          height: 55,
          alignment: Alignment.center,
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
                  border: Border.all(color: Colors.black),
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image:
                          CachedNetworkImageProvider(widget.game.imageUrl))))),
    );
  }
}
