import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/ui/screens/Home/components/actions_postbar.dart';
import 'package:gemu/ui/screens/Home/components/content_postdescription.dart';
import 'package:gemu/ui/screens/Home/components/picture_item.dart';
import 'package:gemu/ui/screens/Home/components/video_player_item.dart';

class DiscoverScreen extends StatefulWidget {
  @override
  DiscoverScreenState createState() => DiscoverScreenState();
}

class DiscoverScreenState extends State<DiscoverScreen> {
  bool dataIsThere = false;

  List gamesUser = [];
  List allGames = [];
  List posts = [];

  late PageController _pageController;

  getPosts() async {
    var uid = FirebaseAuth.instance.currentUser!.uid;

    var myGames = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('games')
        .get();
    for (var item in myGames.docs) {
      gamesUser.add(item.id);
    }

    var games = await FirebaseFirestore.instance.collection('games').get();
    for (var item in games.docs) {
      allGames.add(item.id);
    }

    for (var i = 0; i < gamesUser.length; i++) {
      for (var j = 0; j < allGames.length; j++) {
        if (allGames[j] == gamesUser[i]) {
          allGames.remove(allGames[j]);
        }
      }
    }

    for (var i = 0; i < allGames.length; i++) {
      allGames.shuffle();
      print(allGames[i]);
      var data = await FirebaseFirestore.instance
          .collection('posts')
          .where('game', isEqualTo: allGames[i])
          .limit(2)
          .get();
      for (var item in data.docs) {
        if (!posts.contains(item)) {
          posts.add(item);
        }
      }
    }

    posts.shuffle();

    setState(() {
      dataIsThere = !dataIsThere;
    });
  }

  @override
  void initState() {
    super.initState();
    getPosts();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        title: Text(
          'Discover',
          style: mystyle(18, Colors.white),
        ),
      ),
      body: dataIsThere
          ? posts.length != 0
              ? PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: posts.length,
                  itemBuilder: (_, int index) {
                    DocumentSnapshot<Map<String, dynamic>> post = posts[index];
                    return Stack(
                      children: [
                        post.data()!['pictureUrl'] != null
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
                            bottom: 30,
                            left: 0,
                            child: ContentPostDescription(
                              idUser: post.data()!['uid'],
                              username: post.data()!['username'],
                              caption: post.data()!['caption'],
                              hashtags: post.data()!['hashtags'],
                            )),
                        Positioned(
                            bottom: 30,
                            right: 0,
                            child: ActionsPostBar(
                              idUser: post.data()!['uid'],
                              idPost: post.data()!['id'],
                              profilPicture: post.data()!['profilepicture'],
                              commentsCounts:
                                  post.data()!['commentcount'].toString(),
                              up: post.data()!['up'],
                              down: post.data()!['down'],
                            ))
                      ],
                    );
                  })
              : Center(
                  child: Text('Pas encore de posts pour cette section'),
                )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
