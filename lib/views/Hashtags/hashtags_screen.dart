import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gemu/components/snack_bar_custom.dart';
import 'package:gemu/constants/constants.dart';
import 'package:gemu/helpers/helpers.dart';
import 'package:gemu/models/post.dart';
import 'package:gemu/models/hashtag.dart';
import 'package:gemu/services/database_service.dart';

class HashtagsScreen extends ConsumerStatefulWidget {
  final Hashtag hashtag;
  final GlobalKey<NavigatorState> navKey;

  const HashtagsScreen({Key? key, required this.hashtag, required this.navKey})
      : super(key: key);

  _HashtagsScreenState createState() => _HashtagsScreenState();
}

class _HashtagsScreenState extends ConsumerState<HashtagsScreen> {
  bool _loadingPosts = false;
  bool _loadingMorePosts = false;
  bool _stopReached = false;
  bool _setTitleAppBar = false;

  late ScrollController _scrollController;

  List<Post> posts = [];

  GlobalKey _keyContainer = GlobalKey();
  double heightContainer = 0;

  _getSizeContainer() {
    final RenderBox renderBox =
        _keyContainer.currentContext!.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    heightContainer = size.height;
  }

  getPostsHahstag() async {
    try {
      posts = await DatabaseService.getPostsSpecificHashtag(widget.hashtag);

      setState(() {
        _loadingPosts = true;
        if (posts.length < 20) {
          _stopReached = true;
        }
      });
    } catch (e) {
      print(e);
      messageUser(context, "Oups, un problème est survenu");
    }
  }

  loadMorePostsHashtag() async {
    List<Post> newPosts = [];
    Post lastPost = posts.last;

    try {
      setState(() {
        _loadingMorePosts = true;
      });

      newPosts = await DatabaseService.getMorePostsSpecificHashtag(
          widget.hashtag, lastPost);

      if (newPosts.length == 0) {
        setState(() {
          _stopReached = true;
        });
      } else {
        posts = [...posts, ...newPosts];
      }
      setState(() {
        _loadingMorePosts = false;
      });
    } catch (e) {
      print(e);
      messageUser(context, "Oups, un problème est survenu");
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(
          const Duration(milliseconds: 100), () => _getSizeContainer());
    });

    getPostsHahstag();

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              (_scrollController.position.maxScrollExtent + 10.0) &&
          !_loadingMorePosts &&
          !_stopReached) {
        loadMorePostsHashtag();
      }

      if (_scrollController.position.pixels >= heightContainer &&
          !_setTitleAppBar) {
        setState(() {
          _setTitleAppBar = true;
        });
      } else if (_scrollController.position.pixels < heightContainer &&
          _setTitleAppBar) {
        setState(() {
          _setTitleAppBar = false;
        });
      }
    });
  }

  @override
  void deactivate() {
    _scrollController.removeListener(() {
      if (_scrollController.offset >=
              (_scrollController.position.maxScrollExtent + 10.0) &&
          !_loadingMorePosts &&
          !_stopReached) {
        loadMorePostsHashtag();
      }

      if (_scrollController.position.pixels >= heightContainer &&
          !_setTitleAppBar) {
        setState(() {
          _setTitleAppBar = true;
        });
      } else if (_scrollController.position.pixels < heightContainer &&
          _setTitleAppBar) {
        setState(() {
          _setTitleAppBar = false;
        });
      }
    });
    super.deactivate();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
          child: ClipRRect(
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: AppBar(
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
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
                      icon: Icon(Icons.arrow_back_ios)),
                  title: _setTitleAppBar
                      ? Text(
                          '#${widget.hashtag.name}',
                          style: Theme.of(context).textTheme.titleLarge,
                        )
                      : const SizedBox(),
                  centerTitle: true,
                )),
          ),
          preferredSize: Size(MediaQuery.of(context).size.width, 60)),
      body: Column(
        children: [Expanded(child: bodyView())],
      ),
    );
  }

  Widget bodyView() {
    return ListView(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(
          parent: const BouncingScrollPhysics()),
      controller: _scrollController,
      children: [
        topBody(),
        _loadingPosts
            ? posts.length == 0
                ? Container(
                    height: 100,
                    alignment: Alignment.center,
                    child: Text(
                      "Pas de posts pour ${widget.hashtag.name} actuellement",
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  )
                : listPosts()
            : Container(
                height: 100,
                alignment: Alignment.center,
                child: SizedBox(
                  height: 30.0,
                  width: 30.0,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                    strokeWidth: 1.0,
                  ),
                ),
              ),
      ],
    );
  }

  Widget topBody() {
    return Container(
      key: _keyContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: _itemHashtag(),
            ),
            const SizedBox(
              width: 15.0,
            ),
            Container(
              height: 80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.hashtag.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    "${Helpers.numberFormat(widget.hashtag.postsCount)} publications",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _itemHashtag() {
    return Container(
      width: 80,
      height: 80,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary
                ]),
            boxShadow: [
              BoxShadow(color: Theme.of(context).canvasColor, spreadRadius: 6)
            ]),
        child: Icon(
          Icons.tag,
          size: 44,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget listPosts() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Column(
        children: [
          GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.6,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6),
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              itemCount: posts.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (_, index) {
                Post post = posts[index];
                return post.type == "picture"
                    ? picture(context, post, index)
                    : video(context, post, index);
              }),
          Container(
              height: 60,
              child: _stopReached
                  ? Center(
                      child: Text(
                        "C'est tout pour le moment",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    )
                  : _loadingMorePosts
                      ? Center(
                          child: SizedBox(
                            height: 30.0,
                            width: 30.0,
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary,
                              strokeWidth: 1.5,
                            ),
                          ),
                        )
                      : SizedBox()),
        ],
      ),
    );
  }

  Widget picture(BuildContext context, Post post, int index) {
    return Material(
      borderRadius: BorderRadius.circular(5.0),
      child: Ink(
        decoration: BoxDecoration(
            color: Theme.of(context).shadowColor,
            borderRadius: BorderRadius.circular(5.0),
            image: DecorationImage(
                image: CachedNetworkImageProvider(post.previewPictureUrl),
                fit: BoxFit.cover)),
        child: InkWell(
          borderRadius: BorderRadius.circular(5.0),
          splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          onTap: () => widget.navKey.currentState!.pushNamed(PostsFeed,
              arguments: [
                "#${widget.hashtag.name}",
                widget.navKey,
                index,
                posts
              ]),
          child: Stack(
            children: [
              Container(
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(5.0))),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 5.0, right: 5.0, bottom: 5.0),
                  child: Row(
                    children: [
                      post.userPost!["imageUrl"] != null
                          ? CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                  post.userPost!["imageUrl"]),
                            )
                          : CircleAvatar(
                              backgroundColor: Theme.of(context).shadowColor,
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                            ),
                      const SizedBox(
                        width: 5.0,
                      ),
                      Text(
                        post.userPost!["username"],
                        style: textStyleCustomRegular(Colors.white, 12),
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget video(BuildContext context, Post post, int index) {
    return Material(
      borderRadius: BorderRadius.circular(5.0),
      child: Ink(
        height: 110,
        decoration: BoxDecoration(
            color: Theme.of(context).shadowColor,
            borderRadius: BorderRadius.circular(5.0),
            image: DecorationImage(
                image: CachedNetworkImageProvider(post.previewPictureUrl),
                fit: BoxFit.cover)),
        child: InkWell(
          borderRadius: BorderRadius.circular(5.0),
          splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          onTap: () => widget.navKey.currentState!.pushNamed(PostsFeed,
              arguments: [
                "#${widget.hashtag.name}",
                widget.navKey,
                index,
                posts
              ]),
          child: Stack(
            children: [
              Container(
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(5.0))),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0),
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 5.0, right: 5.0, bottom: 5.0),
                  child: Row(
                    children: [
                      post.userPost!["imageUrl"] != null
                          ? CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                  post.userPost!["imageUrl"]!),
                            )
                          : CircleAvatar(
                              backgroundColor: Theme.of(context).shadowColor,
                              child: Icon(
                                Icons.person,
                                color: Colors.black,
                              ),
                            ),
                      const SizedBox(
                        width: 5.0,
                      ),
                      Text(
                        post.userPost!["username"],
                        style: textStyleCustomRegular(Colors.white, 12),
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
