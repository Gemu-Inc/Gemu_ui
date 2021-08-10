import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/models/post.dart';
import 'package:gemu/ui/screens/Highlights/highlights_posts_view.dart';

class DiscoverScreen extends StatefulWidget {
  @override
  DiscoverScreenState createState() => DiscoverScreenState();
}

class DiscoverScreenState extends State<DiscoverScreen>
    with AutomaticKeepAliveClientMixin {
  bool dataIsThere = false;

  List gamesUser = [];
  List allGames = [];
  List<Post> posts = [];

  getPosts() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(me!.uid)
        .collection('games')
        .get()
        .then((value) {
      for (var item in value.docs) {
        gamesUser.add(item.id);
      }
    });

    await FirebaseFirestore.instance.collection('games').get().then((value) {
      for (var item in value.docs) {
        allGames.add(item.id);
      }
    });

    for (var i = 0; i < gamesUser.length; i++) {
      for (var j = 0; j < allGames.length; j++) {
        if (allGames[j] == gamesUser[i]) {
          allGames.remove(allGames[j]);
        }
      }
    }

    for (var i = 0; i < allGames.length; i++) {
      //allGames.shuffle();
      await FirebaseFirestore.instance
          .collection('posts')
          .where('gameName', isEqualTo: allGames[i])
          .where('privacy', isEqualTo: 'Public')
          .limit(2)
          .get()
          .then((value) {
        for (var item in value.docs) {
          if (!posts.contains(Post.fromMap(item, item.data()))) {
            posts.add(Post.fromMap(item, item.data()));
          }
        }
      });
    }

    posts.shuffle();

    if (!dataIsThere) {
      setState(() {
        dataIsThere = true;
      });
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    getPosts();
  }

  @override
  void dispose() {
    gamesUser.clear();
    allGames.clear();
    posts.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return dataIsThere
        ? posts.length != 0
            ? GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6),
                itemCount: posts.length,
                itemBuilder: (_, index) {
                  Post post = posts[index];
                  return post.type == 'picture'
                      ? GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => DiscoverPostsView(
                                        indexPost: index, posts: posts)));
                          },
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(10.0),
                                image: DecorationImage(
                                    image: CachedNetworkImageProvider(
                                        post.postUrl),
                                    fit: BoxFit.cover)),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => DiscoverPostsView(
                                        indexPost: index, posts: posts)));
                          },
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(10.0),
                                image: DecorationImage(
                                    image: CachedNetworkImageProvider(
                                        post.previewImage!),
                                    fit: BoxFit.cover)),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                })
            : Center(
                child: Text(
                  'Pas encore de posts pour cette section',
                  style: mystyle(12),
                ),
              )
        : Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          );
  }
}
