import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:gemu/models/post.dart';
import 'package:gemu/models/hashtag.dart';
import 'package:gemu/constants/constants.dart';
import 'package:gemu/views/Highlights/highlights_posts_view.dart';

class HashtagsScreen extends StatefulWidget {
  final Hashtag hashtag;

  const HashtagsScreen({Key? key, required this.hashtag}) : super(key: key);

  Hashtagsviewstate createState() => Hashtagsviewstate();
}

class Hashtagsviewstate extends State<HashtagsScreen> {
  bool hashtagsIsThere = false;

  late ScrollController _hashtagsScrollController;

  List<Post> posts = [];

  getPostsHahstags() async {
    await FirebaseFirestore.instance
        .collection('hashtags')
        .doc(widget.hashtag.name)
        .collection('posts')
        .limit(20)
        .get()
        .then((post) async {
      for (var item in post.docs) {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(item.id)
            .get()
            .then((value) => posts.add(Post.fromMap(value, value.data()!)));
      }
    });

    posts.sort((a, b) => b.date.compareTo(a.date));

    if (!hashtagsIsThere) {
      setState(() {
        hashtagsIsThere = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _hashtagsScrollController = ScrollController();
    getPostsHahstags();
  }

  @override
  void dispose() {
    _hashtagsScrollController.dispose();
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
            systemNavigationBarColor:
                Theme.of(context).scaffoldBackgroundColor),
        child: hashtagsIsThere
            ? Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                appBar: AppBar(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 6,
                  leading: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios)),
                  title: Text('Hashtags'),
                  bottom: PreferredSize(
                      child: topView(context),
                      preferredSize: Size.fromHeight(100)),
                ),
                body: bodyView(context))
            : Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                    strokeWidth: 1.5,
                  ),
                ),
              ));
  }

  Widget topView(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
            child: Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black),
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary
                      ])),
              child: Icon(
                Icons.tag,
                size: 40,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
              child: ListTile(
            title: Text(widget.hashtag.name),
            subtitle:
                Text('${widget.hashtag.postsCount.toString()} publications'),
          ))
        ],
      ),
    );
  }

  Widget bodyView(BuildContext context) {
    return posts.length != 0
        ? SingleChildScrollView(
            controller: _hashtagsScrollController,
            physics:
                AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 15.0),
              height: MediaQuery.of(context).size.height,
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: posts.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 1.0,
                    crossAxisSpacing: 1.0),
                itemBuilder: (_, index) {
                  Post post = posts[index];
                  return post.type == 'video'
                      ? video(post, index)
                      : picture(post, index);
                },
              ),
            ),
          )
        : Center(
            child: Text(
              'No posts for ${widget.hashtag.name} at this moment',
              style: mystyle(13),
            ),
          );
  }

  Widget picture(Post post, int index) {
    return Material(
        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(5.0),
        child: Ink(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(5.0),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(post.postUrl),
                  fit: BoxFit.cover,
                )),
            child: Stack(
              children: [
                Container(
                  color: Colors.black.withOpacity(0.2),
                ),
                InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => HashtagPostsView(
                              hashtag: widget.hashtag,
                              index: index,
                              posts: posts))),
                  borderRadius: BorderRadius.circular(5.0),
                  splashColor: Theme.of(context).primaryColor.withOpacity(0.5),
                ),
                Positioned(
                    bottom: 5,
                    right: 5,
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
              ],
            )));
  }

  Widget video(Post post, int index) {
    return Material(
        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(5.0),
        child: Ink(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(5.0),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(post.previewImage!),
                  fit: BoxFit.cover,
                )),
            child: Stack(
              children: [
                Container(
                  color: Colors.black.withOpacity(0.2),
                ),
                InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => HashtagPostsView(
                              hashtag: widget.hashtag,
                              index: index,
                              posts: posts))),
                  borderRadius: BorderRadius.circular(5.0),
                  splashColor: Theme.of(context).primaryColor.withOpacity(0.5),
                ),
                Positioned(
                    top: 5,
                    left: 5,
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                    )),
                Positioned(
                    bottom: 5,
                    right: 5,
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
              ],
            )));
  }
}
