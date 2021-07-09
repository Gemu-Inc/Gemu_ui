import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/ui/screens/Home/components/actions_postbar.dart';
import 'package:gemu/ui/screens/Home/components/content_postdescription.dart';
import 'package:gemu/ui/screens/Home/components/picture_item.dart';
import 'package:gemu/ui/screens/Home/components/video_player_item.dart';

class TrendingsScreen extends StatefulWidget {
  @override
  TrendingsScreenState createState() => TrendingsScreenState();
}

class TrendingsScreenState extends State<TrendingsScreen> {
  bool dataIsThere = false;

  List posts = [];

  late PageController _pageController;

  getPosts() async {
    var data = await FirebaseFirestore.instance
        .collection('posts')
        .where('popularity', isGreaterThanOrEqualTo: 100)
        .orderBy('popularity')
        .get();
    for (var item in data.docs) {
      posts.add(item);
    }

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
    super.dispose();
    _pageController.dispose();
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
          'Trendings',
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
