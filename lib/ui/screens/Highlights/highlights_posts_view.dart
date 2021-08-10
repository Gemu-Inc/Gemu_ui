import 'package:flutter/material.dart';

import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/models/hashtag.dart';
import 'package:gemu/models/post.dart';
import 'package:gemu/ui/widgets/post_tile.dart';

class HashtagPostsView extends StatefulWidget {
  final Hashtag hashtag;
  final int index;
  final List<Post> posts;

  HashtagPostsView(
      {required this.hashtag, required this.index, required this.posts});

  @override
  HashtagPostsViewState createState() => HashtagPostsViewState();
}

class HashtagPostsViewState extends State<HashtagPostsView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        left: false,
        right: false,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 30,
                  ),
                  onPressed: () => Navigator.pop(context)),
              title: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '#${widget.hashtag.name}',
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        '${widget.hashtag.postsCount.toString()} publications',
                        style: mystyle(11),
                      ),
                    )
                  ],
                ),
              )),
          body: PageView.builder(
              scrollDirection: Axis.vertical,
              controller: _pageController,
              itemCount: widget.posts.length,
              itemBuilder: (BuildContext context, int index) {
                Post post = widget.posts[index];
                return PostTile(idUserActual: me!.uid, post: post);
              }),
        ));
  }
}

class DiscoverPostsView extends StatefulWidget {
  final int indexPost;
  final List<Post> posts;

  DiscoverPostsView({required this.indexPost, required this.posts});

  @override
  DiscoverPostsViewState createState() => DiscoverPostsViewState();
}

class DiscoverPostsViewState extends State<DiscoverPostsView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.indexPost);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        left: false,
        right: false,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 30,
                )),
            title: Text(
              'Discover',
            ),
          ),
          body: PageView.builder(
              scrollDirection: Axis.vertical,
              controller: _pageController,
              itemCount: widget.posts.length,
              itemBuilder: (_, index) {
                Post post = widget.posts[index];
                return PostTile(idUserActual: me!.uid, post: post);
              }),
        ));
  }
}
