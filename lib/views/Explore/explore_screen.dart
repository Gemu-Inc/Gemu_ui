import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemu/constants/constants.dart';
import 'package:gemu/helpers/helpers.dart';
import 'package:gemu/providers/Users/myself_provider.dart';
import 'package:gemu/views/Posts/posts_feed_screen.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

import 'package:gemu/components/bouncing_button.dart';
import 'package:gemu/models/hashtag.dart';
import 'package:gemu/models/post.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/views/Hashtags/hashtags_screen.dart';

import 'search_screen.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen>
    with AutomaticKeepAliveClientMixin {
  ScrollController _mainScrollController = ScrollController();
  double positionScroll = 0.0;

  List<Game> gamesList = [];

//Variables Hashtags
  bool dataHashtagsIsThere = false;
  bool isLoadingMoreHashtags = false;
  bool isReloadHashtags = false;
  bool isResultHashtags = false;

  List<Hashtag> hashtags = [];
  List<Hashtag> newHashtags = [];

//Variables Discover
  bool dataDiscoverIsThere = false;
  bool isLoadingMoreDiscover = false;
  bool isReloadDiscover = false;
  bool isResultsDiscover = false;

  List discoverGames = [];
  List<Post> posts = [];
  List<Post> newPosts = [];

//Listener scroll controller
  void scrollListener() {
    if (_mainScrollController.offset <=
            (_mainScrollController.position.minScrollExtent - 50.0) &&
        !isReloadHashtags) {
      reloadHashtags();
    } else if (_mainScrollController.offset >=
            (_mainScrollController.position.maxScrollExtent + 50.0) &&
        !isLoadingMoreHashtags) {
      loadMoreHashtags();
    }
  }

  //Fonctions Hashtags
  getHashtags() async {
    await FirebaseFirestore.instance
        .collection('hashtags')
        .orderBy('postsCount', descending: true)
        .limit(12)
        .get()
        .then((data) {
      for (var item in data.docs) {
        hashtags.add(Hashtag.fromMap(item, item.data()));
      }
    });

    if (!dataHashtagsIsThere) {
      setState(() {
        dataHashtagsIsThere = true;
      });
    }
  }

  loadMoreHashtags() async {
    setState(() {
      if (newHashtags.length != 0) {
        newHashtags.clear();
      }
      if (isResultHashtags) {
        isResultHashtags = false;
      }
      isLoadingMoreHashtags = true;
    });

    Hashtag hashtag = hashtags.last;
    bool add;

    await FirebaseFirestore.instance
        .collection('hashtags')
        .orderBy('postsCount', descending: true)
        .startAfterDocument(hashtag.snapshot!)
        .limit(12)
        .get()
        .then((data) {
      for (var item in data.docs) {
        newHashtags.add(Hashtag.fromMap(item, item.data()));
      }
    });

    for (var i = 0; i < newHashtags.length; i++) {
      if (hashtags.any((element) => element.name == newHashtags[i].name)) {
        add = false;
      } else {
        add = true;
      }
      if (add) {
        hashtags.add(newHashtags[i]);
      }
    }

    setState(() {
      isLoadingMoreHashtags = false;
      if (newHashtags.length == 0) {
        isResultHashtags = true;
      }
    });
  }

  reloadHashtags() async {
    setState(() {
      if (isReloadHashtags) {
        isResultHashtags = false;
      }
      isReloadHashtags = true;
    });

    await Future.delayed(Duration(seconds: 1));

    hashtags.clear();

    await FirebaseFirestore.instance
        .collection('hashtags')
        .orderBy('postsCount', descending: true)
        .limit(12)
        .get()
        .then((data) {
      for (var item in data.docs) {
        hashtags.add(Hashtag.fromMap(item, item.data()));
      }
    });

    print('${hashtags.length}');

    setState(() {
      isReloadHashtags = false;
      dataHashtagsIsThere = false;
    });

    setState(() {
      dataHashtagsIsThere = true;
    });
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
    gamesList = ref.watch(myGamesNotifierProvider);

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
                height: isReloadHashtags ? 50.0 : 0.0,
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
                      height: 75,
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
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SearchScreen()));
          },
        ));
  }

  Widget hashtagsView() {
    return dataHashtagsIsThere
        ? hashtags.length != 0
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  children: [
                    ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: hashtags.length,
                        itemBuilder: (BuildContext context, int index) {
                          Hashtag hashtag = hashtags[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
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
                                          onTap: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      HashtagsScreen(
                                                          hashtag: hashtag))),
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
                                                      spreadRadius: 3)
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
                      child: Stack(
                        children: [
                          Container(
                            height: isLoadingMoreHashtags ? 50.0 : 0.0,
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
                          Container(
                            height: isResultHashtags ? 50.0 : 0.0,
                            child: Center(
                              child: Text('C\'est tout pour le moment'),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )
            : Container(
                height: 110,
                child: Text(
                  'Pas encore d\'hashtags',
                  style: Theme.of(context).textTheme.bodySmall,
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
  bool dataIsThere = false;
  bool isLoadingMorePosts = false;

  ScrollController _postsScrollController = ScrollController();

  late Hashtag hashtag;
  late Post lastPost;
  List<Post> posts = [];
  List<Post> newPosts = [];

  getPostsHashtag(Hashtag hahstag) async {
    try {
      QuerySnapshot<Map<String, dynamic>> data = await hashtag.reference!
          .collection('posts')
          .orderBy('date', descending: true)
          .limit(3)
          .get();

      for (var item in data.docs) {
        DocumentSnapshot<Map<String, dynamic>> dataPost =
            await FirebaseFirestore.instance
                .collection('posts')
                .doc(item.id)
                .get();
        DocumentSnapshot<Map<String, dynamic>> dataUser =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(dataPost.data()!['uid'])
                .get();
        DocumentSnapshot<Map<String, dynamic>> dataGame =
            await FirebaseFirestore.instance
                .collection("games")
                .doc("verified")
                .collection("games_verified")
                .doc(dataPost.data()!["idGame"])
                .get();
        posts.add(Post.fromMap(
            dataPost, dataPost.data()!, dataUser.data()!, dataGame.data()!));
      }

      lastPost = posts.last;

      if (!dataIsThere && mounted) {
        setState(() {
          dataIsThere = true;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  loadMorePostsHashtag(Hashtag hashtag) async {
    bool add;

    if (newPosts.length != 0) {
      newPosts.clear();
    }
    setState(() {
      isLoadingMorePosts = true;
    });

    QuerySnapshot<Map<String, dynamic>> data = await hashtag.reference!
        .collection('posts')
        .orderBy('date', descending: true)
        .startAfterDocument(lastPost.snapshot!)
        .limit(3)
        .get();

    for (var item in data.docs) {
      DocumentSnapshot<Map<String, dynamic>> dataPost = await FirebaseFirestore
          .instance
          .collection('posts')
          .doc(item.id)
          .get();
      DocumentSnapshot<Map<String, dynamic>> dataUser = await FirebaseFirestore
          .instance
          .collection("users")
          .doc(dataPost.data()!["uid"])
          .get();
      DocumentSnapshot<Map<String, dynamic>> dataGame = await FirebaseFirestore
          .instance
          .collection("games")
          .doc("verified")
          .collection("games_verified")
          .doc(dataPost.data()!["idGame"])
          .get();
      newPosts.add(Post.fromMap(
          dataPost, dataPost.data()!, dataUser.data()!, dataGame.data()!));
    }

    if (newPosts.length != 0) {
      print(newPosts.length);
      lastPost = newPosts.last;
    }

    for (var i = 0; i < newPosts.length; i++) {
      if (posts.any((element) => element.id == newPosts[i].id)) {
        add = false;
      } else {
        add = true;
      }

      if (add) {
        posts.add(newPosts[i]);
      }
    }

    setState(() {
      isLoadingMorePosts = false;
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    hashtag = widget.hashtag;

    getPostsHashtag(hashtag);

    _postsScrollController.addListener(() {
      if (_postsScrollController.offset >=
              _postsScrollController.position.maxScrollExtent &&
          !_postsScrollController.position.outOfRange &&
          !isLoadingMorePosts) {
        loadMorePostsHashtag(hashtag);
      }
    });
  }

  @override
  void dispose() {
    posts.clear();
    _postsScrollController.removeListener(() {
      if (_postsScrollController.offset >=
              _postsScrollController.position.maxScrollExtent &&
          !_postsScrollController.position.outOfRange &&
          !isLoadingMorePosts) {
        loadMorePostsHashtag(hashtag);
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      height: 170,
      child: dataIsThere
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
                    padding: EdgeInsets.only(left: 10.0, right: 50.0),
                    child: Container(
                      width: isLoadingMorePosts ? 50.0 : 0.0,
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
      padding: EdgeInsets.all(2.5),
      child: Material(
        borderRadius: BorderRadius.circular(5.0),
        color: Theme.of(context).canvasColor,
        child: Ink(
          height: 220,
          width: 110,
          decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.circular(5.0),
              image: DecorationImage(
                  image: CachedNetworkImageProvider(post.postUrl),
                  fit: BoxFit.cover)),
          child: Stack(
            children: [
              Container(color: Colors.black.withOpacity(0.2)),
              InkWell(
                borderRadius: BorderRadius.circular(5.0),
                splashColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.5),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PostsFeedScreen(
                            title: "#${widget.hashtag.name}",
                            navKey: navExploreAuthKey!,
                            index: indexPost,
                            posts: posts))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget video(Hashtag hashtag, int indexPost, Post post, List<Post> posts) {
    return Padding(
      padding: EdgeInsets.all(2.5),
      child: Material(
        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(5.0),
        child: Ink(
          width: 110,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              image: DecorationImage(
                  image: CachedNetworkImageProvider(post.previewPictureUrl),
                  fit: BoxFit.cover)),
          child: Stack(
            children: [
              Container(
                color: Colors.black.withOpacity(0.2),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(5.0),
                splashColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.5),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PostsFeedScreen(
                            title: "#${widget.hashtag.name}",
                            navKey: navExploreAuthKey!,
                            index: indexPost,
                            posts: posts))),
              ),
              Positioned(
                top: 5.0,
                left: 5.0,
                child: Icon(Icons.play_arrow, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
