import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemu/components/snack_bar_custom.dart';
import 'package:gemu/constants/constants.dart';
import 'package:gemu/helpers/helpers.dart';
import 'package:gemu/services/database_service.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

import 'package:gemu/components/bouncing_button.dart';
import 'package:gemu/models/hashtag.dart';
import 'package:gemu/models/post.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen>
    with AutomaticKeepAliveClientMixin {
  ScrollController _mainScrollController = ScrollController();
  double positionScroll = 0.0;

//Variables Hashtags
  bool _reloadingExplore = false;
  bool _loadingHashtags = false;
  bool _loadingMoreHashtags = false;
  bool _stopReached = false;

  List<Hashtag> hashtags = [];

//Listener scroll controller
  void scrollListener() {
    if (_mainScrollController.offset <=
            (_mainScrollController.position.minScrollExtent - 50.0) &&
        !_reloadingExplore) {
      reloadHashtags();
    } else if (_mainScrollController.offset >=
            (_mainScrollController.position.maxScrollExtent + 10.0) &&
        !_loadingMoreHashtags &&
        !_stopReached) {
      loadMoreHashtags();
    }
  }

  //Fonctions Hashtags
  getHashtags() async {
    try {
      hashtags = await DatabaseService.getHashtagsExplore();

      setState(() {
        _loadingHashtags = true;
      });
    } catch (e) {
      print(e);
      messageUser(context, "Oups, un problème est survenu");
    }
  }

  loadMoreHashtags() async {
    List<Hashtag> newHashtags = [];
    Hashtag hashtag = hashtags.last;

    setState(() {
      _loadingMoreHashtags = true;
    });

    try {
      newHashtags = await DatabaseService.getMoreHashtagsExplore(hashtag);

      if (newHashtags.length == 0) {
        setState(() {
          _stopReached = true;
        });
      } else {
        hashtags = [...hashtags, ...newHashtags];
      }

      setState(() {
        _loadingMoreHashtags = false;
      });
    } catch (e) {
      print(e);
      messageUser(context, "Oups, un problème est survenu");
    }
  }

  reloadHashtags() async {
    setState(() {
      _reloadingExplore = true;
      _loadingHashtags = false;
      _stopReached = false;
    });

    try {
      hashtags.clear();
      hashtags = await DatabaseService.reloadHashtagsExplore();

      setState(() {
        _reloadingExplore = false;
        _loadingHashtags = true;
      });
    } catch (e) {
      print(e);
      messageUser(context, "Oups, un problème est survenu");
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    getHashtags();

    _mainScrollController.addListener(scrollListener);
  }

  @override
  void deactivate() {
    _mainScrollController.removeListener(scrollListener);
    super.deactivate();
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: Platform.isIOS
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle(
                statusBarColor: Color(0xFF22213C).withOpacity(0.3),
                statusBarIconBrightness: Brightness.light,
                systemNavigationBarColor: Color(0xFF22213C),
                systemNavigationBarIconBrightness: Brightness.light),
        child: SafeArea(
          left: false,
          right: false,
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            controller: _mainScrollController,
            physics:
                AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            shrinkWrap: true,
            children: [
              Container(
                height: _reloadingExplore ? 50.0 : 0.0,
                child: Center(
                  child: SizedBox(
                    height: 30.0,
                    width: 30.0,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                      strokeWidth: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 25.0,
              ),
              Text(
                "Explorer",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(
                height: 15.0,
              ),
              StickyHeader(
                  header: Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      height: 55,
                      alignment: Alignment.center,
                      child: search()),
                  content: hashtagsView())
            ],
          ),
        ),
      ),
    );
  }

  Widget search() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.0),
        child: BouncingButton(
          content: Row(
            children: [
              SizedBox(width: 15.0),
              Icon(Icons.search, size: 26.0),
              SizedBox(
                width: 15.0,
              ),
              Text(
                'Rechercher',
                style: Theme.of(context).textTheme.titleSmall,
              )
            ],
          ),
          height: 45,
          width: MediaQuery.of(context).size.width,
          onPressed: () => navExploreAuthKey!.currentState!.pushNamed(Search),
        ));
  }

  Widget hashtagsView() {
    return _loadingHashtags
        ? hashtags.length != 0
            ? Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Column(
                  children: [
                    ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: hashtags.length,
                        itemBuilder: (BuildContext context, int index) {
                          Hashtag hashtag = hashtags[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 15.0),
                                  child: Container(
                                    width: 100,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () => navExploreAuthKey!
                                              .currentState!
                                              .pushNamed(HashtagProfile,
                                                  arguments: [hashtag]),
                                          child: Container(
                                            height: 55,
                                            width: 55,
                                            decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .secondary
                                                    ]),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Theme.of(context)
                                                          .canvasColor,
                                                      spreadRadius: 6)
                                                ]),
                                            child: Icon(
                                              Icons.tag,
                                              size: 25,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5.0,
                                        ),
                                        Text(hashtag.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall),
                                        Text(
                                          "${Helpers.numberFormat(hashtag.postsCount)} publications",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                          textAlign: TextAlign.center,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child: PostsByHashtags(
                                  hashtag: hashtag,
                                ))
                              ],
                            ),
                          );
                        }),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Container(
                          height: 60,
                          child: _stopReached
                              ? Center(
                                  child: Text(
                                    "C'est tout pour le moment",
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                )
                              : _loadingMoreHashtags
                                  ? Center(
                                      child: SizedBox(
                                        height: 30.0,
                                        width: 30.0,
                                        child: CircularProgressIndicator(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          strokeWidth: 1.5,
                                        ),
                                      ),
                                    )
                                  : SizedBox()),
                    )
                  ],
                ),
              )
            : Container(
                height: 150,
                alignment: Alignment.center,
                child: Text(
                  "Pas encore d'hashtags à explorer",
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              )
        : Container(
            height: 150.0,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: 1.5,
              ),
            ),
          );
  }
}

class PostsByHashtags extends StatefulWidget {
  final Hashtag hashtag;

  PostsByHashtags({required this.hashtag});

  @override
  PostsByHashtagsState createState() => PostsByHashtagsState();
}

class PostsByHashtagsState extends State<PostsByHashtags>
    with AutomaticKeepAliveClientMixin {
  bool _loadingPosts = false;
  bool _loadingMorePosts = false;
  bool _stopReached = false;

  ScrollController _postsScrollController = ScrollController();

  late Hashtag hashtag;
  List<Post> posts = [];

  getPostsHashtag(Hashtag hashtag) async {
    try {
      posts = await DatabaseService.getPostsHashtagExplore(hashtag);

      if (!_loadingPosts && mounted) {
        setState(() {
          _loadingPosts = true;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  loadMorePostsHashtag(Hashtag hashtag) async {
    List<Post> newPosts = [];
    Post lastPost = posts.last;

    setState(() {
      _loadingMorePosts = true;
    });

    try {
      newPosts =
          await DatabaseService.getMorePostsHashtagExplore(hashtag, lastPost);

      if (newPosts.length != 0) {
        posts = [...posts, ...newPosts];
      } else {
        setState(() {
          _stopReached = true;
        });
      }

      setState(() {
        _loadingMorePosts = false;
      });
    } catch (e) {
      print(e);
    }
  }

  void scrollListener() {
    if (posts.length != 0 &&
        _postsScrollController.offset >=
            (_postsScrollController.position.maxScrollExtent + 10.0) &&
        !_loadingMorePosts &&
        !_stopReached) {
      loadMorePostsHashtag(hashtag);
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    hashtag = widget.hashtag;

    getPostsHashtag(hashtag);

    _postsScrollController.addListener(scrollListener);
  }

  @override
  void dispose() {
    posts.clear();
    _postsScrollController.removeListener(scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      height: 170,
      child: _loadingPosts
          ? SingleChildScrollView(
              controller: _postsScrollController,
              physics: AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              scrollDirection: Axis.horizontal,
              reverse: false,
              child: Row(
                children: [
                  ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: posts.length,
                      itemBuilder: (_, index) {
                        Post post = posts[index];
                        return post.type == 'picture'
                            ? picture(hashtag, index, post, posts)
                            : video(hashtag, index, post, posts);
                      }),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0, right: 25.0),
                    child: Container(
                      width: _loadingMorePosts ? 50.0 : 0.0,
                      child: Center(
                        child: SizedBox(
                          height: 30.0,
                          width: 30.0,
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                            strokeWidth: 1.5,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: 1.5,
              ),
            ),
    );
  }

  Widget picture(
    Hashtag hashtag,
    int indexPost,
    Post post,
    List<Post> posts,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Material(
        borderRadius: BorderRadius.circular(5.0),
        child: Ink(
          height: 220,
          width: 110,
          decoration: BoxDecoration(
              color: Theme.of(context).shadowColor,
              borderRadius: BorderRadius.circular(5.0),
              image: DecorationImage(
                  image: CachedNetworkImageProvider(post.previewPictureUrl),
                  fit: BoxFit.cover)),
          child: InkWell(
            borderRadius: BorderRadius.circular(5.0),
            splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            onTap: () => navExploreAuthKey!.currentState!.pushNamed(PostsFeed,
                arguments: [
                  "#${widget.hashtag.name}",
                  navExploreAuthKey!,
                  indexPost,
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
                    padding: const EdgeInsets.only(
                        left: 5.0, right: 5.0, bottom: 5.0),
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
      ),
    );
  }

  Widget video(Hashtag hashtag, int indexPost, Post post, List<Post> posts) {
    return Material(
      borderRadius: BorderRadius.circular(5.0),
      child: Ink(
        height: 220,
        width: 110,
        decoration: BoxDecoration(
            color: Theme.of(context).shadowColor,
            borderRadius: BorderRadius.circular(5.0),
            image: DecorationImage(
                image: CachedNetworkImageProvider(post.previewPictureUrl),
                fit: BoxFit.cover)),
        child: InkWell(
          borderRadius: BorderRadius.circular(5.0),
          splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          onTap: () => navExploreAuthKey!.currentState!.pushNamed(PostsFeed,
              arguments: [
                "#${widget.hashtag.name}",
                navExploreAuthKey!,
                indexPost,
                posts
              ]),
          child: Stack(
            children: [
              Container(
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
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
