import "dart:io" show Platform;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemu/providers/Users/myself_provider.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

import 'package:gemu/components/bouncing_button.dart';
import 'package:gemu/models/hashtag.dart';
import 'package:gemu/models/post.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/views/Post/Hashtags/hashtags_screen.dart';

import 'search_screen.dart';
import 'highlights_posts_view.dart';

class HighlightsScreen extends ConsumerStatefulWidget {
  const HighlightsScreen({Key? key}) : super(key: key);

  Highlightsviewstate createState() => Highlightsviewstate();
}

class Highlightsviewstate extends ConsumerState<HighlightsScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late TabController _tabController;
  int currentTabIndex = 0;

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

//Listener tab controller
  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        currentTabIndex = _tabController.index;
        print(currentTabIndex);
      });

      if (positionScroll != 0.0) {
        _mainScrollController.jumpTo(0.0);
      }
    }
  }

//Listener scroll controller
  void scrollListener() {
    positionScroll = _mainScrollController.position.pixels;

    if (currentTabIndex == 0 &&
        _mainScrollController.offset <=
            (_mainScrollController.position.minScrollExtent - 50.0) &&
        !isReloadHashtags) {
      print('en haut hashtags');
      reloadHashtags();
    } else if (currentTabIndex == 0 &&
        _mainScrollController.offset >=
            (_mainScrollController.position.maxScrollExtent + 50) &&
        !isLoadingMoreHashtags) {
      print('en bas hashtags');
      loadMoreHashtags();
    }

    if (currentTabIndex == 1 &&
        _mainScrollController.offset <=
            (_mainScrollController.position.minScrollExtent - 50.0) &&
        !isReloadDiscover) {
      print('en haut discover');
      reloadDiscoverWithoutGamesUser();
    } else if (currentTabIndex == 1 &&
        _mainScrollController.offset >=
            (_mainScrollController.position.maxScrollExtent + 50.0) &&
        !isLoadingMoreDiscover) {
      print('en bas discover');
      loadMoreDiscoverWithoutGamesUser();
    }
  }

  //Fonctions Hashtags

  getHashtags() async {
    await FirebaseFirestore.instance
        .collection('hashtags')
        .orderBy('postsCount', descending: true)
        .limit(3)
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

    await Future.delayed(Duration(seconds: 2));

    await FirebaseFirestore.instance
        .collection('hashtags')
        .orderBy('postsCount', descending: true)
        .startAfterDocument(hashtag.snapshot!)
        .limit(3)
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
        .limit(3)
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

    await Future.delayed(Duration(seconds: 1));

    setState(() {
      dataHashtagsIsThere = true;
    });
  }

  //Fonctions Discover

  getDiscoverWithoutGamesUser() async {
    //Charge tous les jeux qui ne suit pas l'utilisateur
    await FirebaseFirestore.instance
        .collection('games')
        .doc('verified')
        .collection('games_verified')
        .get()
        .then((value) {
      for (var item in value.docs) {
        discoverGames.add(Game.fromMap(item, item.data()));
      }
    });

    for (var i = 0; i < gamesList.length; i++) {
      for (var j = 0; j < discoverGames.length; j++) {
        if (discoverGames[j].name == gamesList[i].name) {
          discoverGames.remove(discoverGames[j]);
        }
      }
    }

    for (var i = 0; i < discoverGames.length; i++) {
      await FirebaseFirestore.instance
          .collection('games')
          .doc('verified')
          .collection('games_verified')
          .doc(discoverGames[i].name)
          .collection('posts')
          .orderBy('date', descending: true)
          .limit(3)
          .get()
          .then((value) async {
        print('value: ${value.docs.length}');
        if (value.docs.length != 0) {
          for (var item in value.docs) {
            print(item.id);
            await FirebaseFirestore.instance
                .collection('posts')
                .doc(item.id)
                .get()
                .then((value) {
              posts.add(Post.fromMap(value, value.data()!));
            });
          }
        }
      });
    }

    posts.sort((a, b) => b.date.compareTo(a.date));

    if (!dataDiscoverIsThere && mounted) {
      setState(() {
        dataDiscoverIsThere = true;
      });
    }
  }

  loadMoreDiscoverWithoutGamesUser() async {
    bool add;

    if (newPosts.length != 0) {
      newPosts.clear();
    }

    setState(() {
      isLoadingMoreDiscover = true;
      if (isResultsDiscover) {
        isResultsDiscover = false;
      }
    });

    for (var i = 0; i < discoverGames.length; i++) {
      List<Post> postsGame = [];
      Post lastPost;

      for (var j = 0; j < posts.length; j++) {
        if (posts[j].gameName == discoverGames[i].name) {
          postsGame.add(posts[j]);
        }
      }

      if (postsGame.length != 0) {
        lastPost = postsGame.last;

        await FirebaseFirestore.instance
            .collection('games')
            .doc('verified')
            .collection('games_verified')
            .doc(discoverGames[i].name)
            .collection('posts')
            .orderBy('date', descending: true)
            .startAfterDocument(lastPost.snapshot!)
            .limit(3)
            .get()
            .then((value) async {
          for (var item in value.docs) {
            await FirebaseFirestore.instance
                .collection('posts')
                .doc(item.id)
                .get()
                .then((value) {
              newPosts.add(Post.fromMap(value, value.data()!));
            });
          }
        });
      }
    }

    newPosts.sort((a, b) => b.date.compareTo(a.date));

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
      isLoadingMoreDiscover = false;
      if (newPosts.length == 0) {
        isResultsDiscover = true;
      }
    });
  }

  reloadDiscoverWithoutGamesUser() async {
    setState(() {
      isReloadDiscover = true;
      if (isResultsDiscover) {
        isResultsDiscover = false;
      }
    });

    await Future.delayed(Duration(seconds: 1));

    discoverGames.clear();
    posts.clear();

    await FirebaseFirestore.instance
        .collection('games')
        .doc('verified')
        .collection('games_verified')
        .get()
        .then((value) {
      for (var item in value.docs) {
        discoverGames.add(Game.fromMap(item, item.data()));
      }
    });

    for (var i = 0; i < gamesList.length; i++) {
      for (var j = 0; j < discoverGames.length; j++) {
        if (discoverGames[j].name == gamesList[i].name) {
          discoverGames.remove(discoverGames[j]);
        }
      }
    }

    for (var i = 0; i < discoverGames.length; i++) {
      await FirebaseFirestore.instance
          .collection('games')
          .doc('verified')
          .collection('games_verified')
          .doc(discoverGames[i].name)
          .collection('posts')
          .orderBy('date', descending: true)
          .limit(3)
          .get()
          .then((value) async {
        print('value: ${value.docs.length}');
        if (value.docs.length != 0) {
          for (var item in value.docs) {
            print(item.id);
            await FirebaseFirestore.instance
                .collection('posts')
                .doc(item.id)
                .get()
                .then((value) {
              posts.add(Post.fromMap(value, value.data()!));
            });
          }
        }
      });
    }

    posts.sort((a, b) => b.date.compareTo(a.date));

    setState(() {
      isReloadDiscover = false;
      dataDiscoverIsThere = false;
    });

    await Future.delayed(Duration(seconds: 1));

    setState(() {
      dataDiscoverIsThere = true;
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _mainScrollController.addListener(scrollListener);

    _tabController =
        TabController(initialIndex: currentTabIndex, length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);

    getHashtags();
    //getDiscoverWithoutGamesUser();
  }

  @override
  void deactivate() {
    _mainScrollController.removeListener(scrollListener);
    _tabController.removeListener(_onTabChanged);
    super.deactivate();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mainScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    gamesList = ref.watch(myGamesNotifierProvider);
    return Scaffold(
      appBar: PreferredSize(
          child: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 6,
            systemOverlayStyle: Platform.isIOS
                ? Theme.of(context).brightness == Brightness.dark
                    ? SystemUiOverlayStyle.light
                    : SystemUiOverlayStyle.dark
                : SystemUiOverlayStyle(
                    statusBarColor: Theme.of(context)
                        .scaffoldBackgroundColor
                        .withOpacity(0.5),
                    statusBarIconBrightness:
                        Theme.of(context).brightness == Brightness.dark
                            ? Brightness.light
                            : Brightness.dark),
            title: Text(
              'Highlights',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            bottom: PreferredSize(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  child: Container(
                    child: search(),
                  ),
                ),
                preferredSize: Size.fromHeight(100)),
          ),
          preferredSize:
              Size.fromHeight(MediaQuery.of(context).size.height / 6)),
      body: ListView(
        controller: _mainScrollController,
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        shrinkWrap: true,
        children: [
          currentTabIndex == 0
              ? Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Container(
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
                )
              : Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Container(
                    height: isReloadDiscover ? 50.0 : 0.0,
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
                ),
          StickyHeader(
              controller: _mainScrollController,
              header: stickyHeader(),
              content: tabBarView())
        ],
      ),
    );
  }

  Widget search() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: BouncingButton(
          content: Row(
            children: [
              SizedBox(width: 15.0),
              Icon(Icons.search,
                  size: 23.0,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black),
              SizedBox(
                width: 15.0,
              ),
              Text(
                'Recherche user, game, hashtag',
                style: Theme.of(context).textTheme.bodySmall,
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

  Widget stickyHeader() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      width: MediaQuery.of(context).size.width,
      child: tabBar(),
    );
  }

  Widget tabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      child: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).canvasColor,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary,
                  offset: Offset(1.0, 1.0),
                ),
              ]),
          tabs: [
            Tab(
              text: 'Hashtags',
            ),
            Tab(
              text: 'Discover',
            )
          ]),
    );
  }

  Widget tabBarView() {
    return IndexedStack(index: currentTabIndex, children: [
      Visibility(
        child: hashtagsView(),
        maintainState: true,
        visible: currentTabIndex == 0,
      ),
      Visibility(
        child: discoverView(),
        maintainState: true,
        visible: currentTabIndex == 1,
      ),
    ]);
  }

  Widget hashtagsView() {
    return dataHashtagsIsThere
        ? hashtags.length != 0
            ? Container(
                padding: EdgeInsets.only(
                    top: 10.0,
                    bottom: (MediaQuery.of(context).size.height / 11) + 10.0),
                child: Column(
                  children: [
                    ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: hashtags.length,
                        itemBuilder: (BuildContext context, int index) {
                          Hashtag hashtag = hashtags[index];
                          return Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 4,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) => HashtagsScreen(
                                                    hashtag: hashtag))),
                                        child: Container(
                                          height: 50,
                                          width: 50,
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
                                          child: Icon(Icons.tag),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 2.0,
                                      ),
                                      Text(hashtag.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall),
                                      Text(
                                          '${hashtag.postsCount.toString()} publications',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall)
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                  child: PostsByHashtags(
                                hashtag: hashtag,
                              ))
                            ],
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
                height: MediaQuery.of(context).size.height / 1.5,
                width: MediaQuery.of(context).size.width,
                child: Center(
                    child: Text(
                  'Pas encore d\'hashtags',
                  style: Theme.of(context).textTheme.bodySmall,
                )),
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

  Widget discoverView() {
    return dataDiscoverIsThere
        ? posts.length != 0
            ? Container(
                padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0,
                    (MediaQuery.of(context).size.height / 11) + 5.0),
                child: Column(
                  children: [
                    GridView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 1.0,
                            crossAxisSpacing: 1.0),
                        itemCount: posts.length,
                        itemBuilder: (_, index) {
                          Post post = posts[index];
                          return post.type == 'picture'
                              ? picture(post, index)
                              : video(post, index);
                        }),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Stack(children: [
                        Container(
                          height: isLoadingMoreDiscover ? 50.0 : 0.0,
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
                          height: isResultsDiscover ? 50.0 : 0.0,
                          child: Center(
                            child: Text('C\'est tout pour le moment'),
                          ),
                        )
                      ]),
                    )
                  ],
                ),
              )
            : Container(
                height: MediaQuery.of(context).size.height / 1.5,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Text(
                    'Pas encore de posts pour cette section',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              )
        : Container(
            height: 150,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: 1.5,
              ),
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
                  fit: BoxFit.cover)),
          child: Stack(
            children: [
              Container(color: Colors.black.withOpacity(0.2)),
              InkWell(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            DiscoverPostsView(indexPost: index, posts: posts))),
                borderRadius: BorderRadius.circular(5.0),
                splashColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              Positioned(
                bottom: 5.0,
                right: 5.0,
                child: Column(
                  children: [
                    Icon(Icons.remove_red_eye, color: Colors.white),
                    Text(post.viewcount.toString(),
                        style: Theme.of(context).textTheme.bodySmall)
                  ],
                ),
              )
            ],
          )),
    );
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
                  fit: BoxFit.cover)),
          child: Stack(
            children: [
              Container(color: Colors.black.withOpacity(0.2)),
              InkWell(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            DiscoverPostsView(indexPost: index, posts: posts))),
                borderRadius: BorderRadius.circular(5.0),
                splashColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              Positioned(
                top: 5.0,
                left: 5.0,
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
              Positioned(
                bottom: 5.0,
                right: 5.0,
                child: Column(
                  children: [
                    Icon(Icons.remove_red_eye, color: Colors.white),
                    Text(post.viewcount.toString(),
                        style: Theme.of(context).textTheme.bodySmall)
                  ],
                ),
              )
            ],
          )),
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
    await hashtag.reference!
        .collection('posts')
        .orderBy('date', descending: true)
        .limit(3)
        .get()
        .then((data) async {
      for (var item in data.docs) {
        try {
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(item.id)
              .get()
              .then((value) => posts.add(Post.fromMap(value, value.data()!)));
        } catch (e) {
          print(e);
        }
      }
    });

    lastPost = posts.last;

    if (!dataIsThere && mounted) {
      setState(() {
        dataIsThere = true;
      });
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

    await hashtag.reference!
        .collection('posts')
        .orderBy('date', descending: true)
        .startAfterDocument(lastPost.snapshot!)
        .limit(3)
        .get()
        .then((data) async {
      for (var item in data.docs) {
        try {
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(item.id)
              .get()
              .then(
                  (value) => newPosts.add(Post.fromMap(value, value.data()!)));
        } catch (e) {
          print(e);
        }
      }
    });

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
      height: 125,
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
          width: 110,
          decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              border: Border.all(color: Colors.black),
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
                        builder: (context) => HashtagPostsView(
                              hashtag: hashtag,
                              index: indexPost,
                              posts: posts,
                            ))),
              ),
              Positioned(
                  bottom: 5.0,
                  right: 5.0,
                  child: Column(
                    children: [
                      Icon(Icons.remove_red_eye, color: Colors.white),
                      Text(
                        post.viewcount.toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    ],
                  ))
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
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(5.0),
              image: DecorationImage(
                  image: CachedNetworkImageProvider(post.previewImage!),
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
                        builder: (context) => HashtagPostsView(
                              hashtag: hashtag,
                              index: indexPost,
                              posts: posts,
                            ))),
              ),
              Positioned(
                top: 5.0,
                left: 5.0,
                child: Icon(Icons.play_arrow, color: Colors.white),
              ),
              Positioned(
                  bottom: 5.0,
                  right: 5.0,
                  child: Column(
                    children: [
                      Icon(Icons.remove_red_eye, color: Colors.white),
                      Text(
                        post.viewcount.toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
