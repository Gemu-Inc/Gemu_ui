import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemu/components/post_tile.dart';
import 'package:gemu/constants/constants.dart';
import 'package:gemu/models/post.dart';

class PostsFeedScreen extends ConsumerStatefulWidget {
  final String title;
  final GlobalKey<NavigatorState> navKey;
  final int index;
  final List<Post> posts;

  const PostsFeedScreen(
      {Key? key,
      required this.title,
      required this.navKey,
      required this.index,
      required this.posts})
      : super(key: key);

  @override
  _PostsFeedScreenState createState() => _PostsFeedScreenState();
}

class _PostsFeedScreenState extends ConsumerState<PostsFeedScreen> {
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: Platform.isIOS
            ? Theme.of(context).brightness == Brightness.dark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness:
                    Theme.of(context).brightness == Brightness.dark
                        ? Brightness.light
                        : Brightness.dark,
                systemNavigationBarColor:
                    Theme.of(context).scaffoldBackgroundColor,
                systemNavigationBarIconBrightness:
                    Theme.of(context).brightness == Brightness.dark
                        ? Brightness.light
                        : Brightness.dark),
        leading: IconButton(
            onPressed: () => widget.navKey.currentState!.pop(),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: PageView.builder(
          scrollDirection: Axis.vertical,
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
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
    );
  }
}
