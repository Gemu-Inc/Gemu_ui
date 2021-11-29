import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/models/post.dart';
import 'package:gemu/ui/views/Autres/post_tile.dart';

class GameFocusScreen extends StatefulWidget {
  final Game game;
  final int index;
  final List<Post> posts;

  const GameFocusScreen(
      {Key? key, required this.game, required this.index, required this.posts})
      : super(key: key);

  @override
  _GameFocusviewstate createState() => _GameFocusviewstate();
}

class _GameFocusviewstate extends State<GameFocusScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black),
      child: SafeArea(
        left: false,
        right: false,
        bottom: false,
        child: Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                )),
            title: Text(
              widget.game.name,
              style: mystyle(16, Colors.white),
            ),
          ),
          body: PageView.builder(
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
        ),
      ),
    );
  }
}
