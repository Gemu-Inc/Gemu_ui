import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';

import 'package:gemu/models/game.dart';
import 'package:gemu/models/post.dart';
import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/ui/screens/Games/game_focus_screen.dart';

class GameScreen extends StatefulWidget {
  final Game game;

  const GameScreen({Key? key, required this.game}) : super(key: key);

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  bool gamePostsIsThere = false;
  bool isFollowing = false;

  late ScrollController _gameScrollController;

  List<Post> posts = [];

  getPostsGame() async {
    await FirebaseFirestore.instance
        .collection('posts')
        .where('gameName', isEqualTo: widget.game.name)
        .orderBy('date', descending: true)
        .limit(20)
        .get()
        .then((post) {
      for (var item in post.docs) {
        posts.add(Post.fromMap(item, item.data()));
      }
    });

    if (!gamePostsIsThere) {
      setState(() {
        gamePostsIsThere = true;
      });
    }
  }

  followGame() {
    setState(() {
      isFollowing = true;
    });
  }

  unfollowGame() {
    setState(() {
      isFollowing = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _gameScrollController = ScrollController();
    getPostsGame();
  }

  @override
  void dispose() {
    _gameScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              Theme.of(context).brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
          systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor),
      child: gamePostsIsThere
          ? Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 6,
                leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_ios)),
                title: Text('Games'),
                bottom: PreferredSize(
                    child: bottomAppBar(),
                    preferredSize: Size.fromHeight(100.0)),
              ),
              body: bodyView(),
            )
          : Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                  strokeWidth: 1.5,
                ),
              ),
            ),
    );
  }

  Widget bottomAppBar() {
    return Container(
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
            child: Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(5.0),
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary
                      ]),
                  image: DecorationImage(
                      image: CachedNetworkImageProvider(widget.game.imageUrl),
                      fit: BoxFit.cover)),
            ),
          ),
          Expanded(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.game.name),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2,
                    child: isFollowing
                        ? ElevatedButton(
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                side: BorderSide(color: Colors.black)),
                            onPressed: () => unfollowGame(),
                            child: Text(
                              'Unfollow',
                              style: mystyle(13, Colors.black),
                            ))
                        : ElevatedButton(
                            style: TextButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                side: BorderSide(color: Colors.black)),
                            onPressed: () => followGame(),
                            child: Text(
                              'Follow',
                              style: mystyle(13, Colors.black),
                            )),
                  ),
                ),
              ],
            ),
          ))
        ],
      ),
    );
  }

  Widget bodyView() {
    return posts.length != 0
        ? SingleChildScrollView(
            controller: _gameScrollController,
            physics:
                AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 15.0),
              height: MediaQuery.of(context).size.height,
              child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 1.0,
                      crossAxisSpacing: 1.0),
                  itemCount: posts.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (_, index) {
                    Post post = posts[index];
                    return post.type == 'video'
                        ? video(context, post, index)
                        : picture(context, post, index);
                  }),
            ),
          )
        : Center(
            child: Text(
              'No posts for ${widget.game.name} at this moment',
              style: mystyle(12),
            ),
          );
  }

  Widget picture(BuildContext context, Post post, int index) {
    return Material(
      color: Theme.of(context).canvasColor,
      borderRadius: BorderRadius.circular(5.0),
      child: Ink(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(5.0),
            image: DecorationImage(
                image: CachedNetworkImageProvider(post.postUrl),
                fit: BoxFit.cover)),
        child: Stack(
          children: [
            Positioned(
                bottom: 5.0,
                right: 5.0,
                child: Column(
                  children: [
                    Icon(
                      Icons.remove_red_eye,
                      color: Colors.white,
                    ),
                    Text(
                      post.viewcount.toString(),
                      style: mystyle(11, Colors.white),
                    )
                  ],
                )),
            Container(
              color: Colors.black.withOpacity(0.2),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(5.0),
              splashColor: Theme.of(context).primaryColor.withOpacity(0.5),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => GameFocusScreen(
                            game: widget.game,
                            index: index,
                            posts: posts,
                          ))),
            ),
          ],
        ),
      ),
    );
  }

  Widget video(BuildContext context, Post post, int index) {
    return Material(
      color: Theme.of(context).canvasColor,
      borderRadius: BorderRadius.circular(5.0),
      child: Ink(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(5.0),
            image: DecorationImage(
                image: CachedNetworkImageProvider(post.previewImage!),
                fit: BoxFit.cover)),
        child: Stack(
          children: [
            Positioned(
                top: 5.0,
                left: 5.0,
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                )),
            Positioned(
                bottom: 5.0,
                right: 5.0,
                child: Column(
                  children: [
                    Icon(
                      Icons.remove_red_eye,
                      color: Colors.white,
                    ),
                    Text(
                      post.viewcount.toString(),
                      style: mystyle(11, Colors.white),
                    )
                  ],
                )),
            Container(
              color: Colors.black.withOpacity(0.2),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(5.0),
              splashColor: Theme.of(context).primaryColor.withOpacity(0.5),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => GameFocusScreen(
                            game: widget.game,
                            index: index,
                            posts: posts,
                          ))),
            ),
          ],
        ),
      ),
    );
  }
}
