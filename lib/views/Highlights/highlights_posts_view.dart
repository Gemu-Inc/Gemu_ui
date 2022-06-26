import 'package:flutter/material.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/models/hashtag.dart';
import 'package:gemu/models/post.dart';
import 'package:gemu/components/post_tile.dart';

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
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
              elevation: 0,
              leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context)),
              title: Text(
                '#${widget.hashtag.name}',
                style: Theme.of(context).textTheme.bodySmall,
              )),
          body: PageView.builder(
              physics: AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              scrollDirection: Axis.vertical,
              controller: _pageController,
              itemCount: widget.posts.length,
              itemBuilder: (BuildContext context, int index) {
                Post post = widget.posts[index];
                return PostTile(
                  idUserActual: me!.uid,
                  post: post,
                  positionDescriptionBar: 5.0,
                  positionActionsBar: 5.0,
                  isGameBar: true,
                  isFollowingsSection: false,
                );
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
          backgroundColor: Colors.black,
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
                  color: Colors.white,
                )),
            title: Text(
              'Discover',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          body: PageView.builder(
              physics: AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              scrollDirection: Axis.vertical,
              controller: _pageController,
              itemCount: widget.posts.length,
              itemBuilder: (_, index) {
                Post post = widget.posts[index];
                return PostTile(
                  idUserActual: me!.uid,
                  post: post,
                  positionDescriptionBar: 5.0,
                  positionActionsBar: 5.0,
                  isGameBar: true,
                  isFollowingsSection: false,
                );
              }),
        ));
  }
}
