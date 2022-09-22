import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gemu/components/alert_dialog_custom.dart';
import 'package:gemu/components/snack_bar_custom.dart';
import 'package:gemu/constants/constants.dart';
import 'package:gemu/helpers/helpers.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/models/post.dart';
import 'package:gemu/providers/Games/games_discover_provider.dart';
import 'package:gemu/providers/Users/myself_provider.dart';
import 'package:gemu/services/database_service.dart';

class ProfileGameScreen extends ConsumerStatefulWidget {
  final Game game;
  final GlobalKey<NavigatorState> navKey;

  const ProfileGameScreen({Key? key, required this.game, required this.navKey})
      : super(key: key);

  @override
  _ProfileGameScreenState createState() => _ProfileGameScreenState();
}

class _ProfileGameScreenState extends ConsumerState<ProfileGameScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late StreamSubscription gameListener;
  // late TabController _tabController;

  bool _loadingPosts = false;
  bool _isFollowByUser = false;
  bool _setTitleAppBar = false;
  bool _stopReached = false;
  bool _loadingMorePosts = false;

  int followersGame = 0;
  List<Post> posts = [];

  GlobalKey _keyContainer = GlobalKey();
  double heightContainer = 0;

  _getSizeContainer() {
    final RenderBox renderBox =
        _keyContainer.currentContext!.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    heightContainer = size.height;
  }

  getPostsGame() async {
    try {
      posts = await DatabaseService.getPostSpecificGame(widget.game);
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

  loadMorePostsGame() async {
    List<Post> newPosts = [];
    Post lastPost = posts.last;

    try {
      setState(() {
        _loadingMorePosts = true;
      });
      newPosts =
          await DatabaseService.getMorePostsSpecificGame(widget.game, lastPost);
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

  Future alertUnfollowGame(Game game, BuildContext context, WidgetRef ref,
      List<Game> gamesList, bool stopReached) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white24
            : Colors.black54,
        builder: (context) {
          return AlertDialogCustom(context, 'Ne plus suivre',
              'Veux-tu retirer ce jeu de tes jeux suivis?', [
            TextButton(
                onPressed: () async {
                  bool valid = await DatabaseService.unfollowGame(
                      context, game, ref, gamesList, stopReached);
                  if (valid) {
                    setState(() {
                      _isFollowByUser = false;
                    });
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  'Oui',
                  style: TextStyle(color: cGreenConfirm),
                )),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Non',
                  style: TextStyle(color: cRedCancel),
                )),
          ]);
        });
  }

  Future alertFollowGame(Game game, BuildContext context, WidgetRef ref) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white24
            : Colors.black54,
        builder: (context) {
          return AlertDialogCustom(
              context, 'Suivre', 'Veux-tu ajouter ce jeu à tes jeux suivis?', [
            TextButton(
                onPressed: () async {
                  try {
                    bool valid =
                        await DatabaseService.followGame(context, game, ref);
                    if (valid) {
                      setState(() {
                        _isFollowByUser = true;
                      });
                    }
                  } catch (e) {
                    print(e);
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  'Oui',
                  style: TextStyle(color: cGreenConfirm),
                )),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Non',
                  style: TextStyle(color: cRedCancel),
                )),
          ]);
        });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(
          const Duration(milliseconds: 100), () => _getSizeContainer());
    });

    gameListener = FirebaseFirestore.instance
        .collection('games')
        .doc("verified")
        .collection("games_verified")
        .doc(widget.game.name)
        .collection("followers")
        .snapshots()
        .listen((data) {
      setState(() {
        followersGame = data.docs.length;
      });
    });
    getPostsGame();

    List<Game> gamesFollowsByUser = ref.read(myGamesNotifierProvider);
    if (gamesFollowsByUser.any((element) => element.name == widget.game.name)) {
      setState(() {
        _isFollowByUser = true;
      });
    }

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              (_scrollController.position.maxScrollExtent + 10.0) &&
          !_stopReached) {
        loadMorePostsGame();
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

    // _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void deactivate() {
    _scrollController.removeListener(() {
      if (_scrollController.offset >=
              (_scrollController.position.maxScrollExtent + 10.0) &&
          !_stopReached) {
        loadMorePostsGame();
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
    gameListener.cancel();
    _scrollController.dispose();
    // _tabController.dispose();
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
                            widget.game.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          )
                        : const SizedBox(),
                    centerTitle: true,
                    actions: [
                      _isFollowByUser
                          ? IconButton(
                              onPressed: () {
                                alertUnfollowGame(
                                    widget.game,
                                    context,
                                    ref,
                                    ref.read(myGamesNotifierProvider),
                                    ref.read(
                                        stopReachedDiscoverNotifierProvider));
                              },
                              icon: Icon(
                                Icons.favorite,
                                size: 26,
                                color: Theme.of(context).colorScheme.primary,
                              ))
                          : IconButton(
                              onPressed: () {
                                alertFollowGame(widget.game, context, ref);
                              },
                              icon: Icon(
                                Icons.favorite_outline,
                                size: 26,
                              ))
                    ],
                  )),
            ),
            preferredSize: Size(MediaQuery.of(context).size.width, 60)),
        body: Column(
          children: [Expanded(child: bodyView())],
        ));
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
                      "Pas de posts pour ${widget.game.name} actuellement",
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
              child: _itemGame(),
            ),
            const SizedBox(
              width: 15.0,
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.game.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    "${Helpers.numberFormat(followersGame)} followers",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Wrap(
                    children: widget.game.categories.map((categorie) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 6.0, 6.0, 0.0),
                        child: Container(
                          height: 35.0,
                          decoration: BoxDecoration(
                              color: Theme.of(context).shadowColor,
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              categorie,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }

  Widget _itemGame() {
    return Container(
      width: 115,
      height: 165,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary
                    ])),
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.5)
                    ])),
          ),
          Center(
            child: Icon(
              Icons.videogame_asset,
              size: 35,
              color: Colors.white,
            ),
          ),
        ],
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
              arguments: [widget.game.name, widget.navKey, index, posts]),
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
              arguments: [widget.game.name, widget.navKey, index, posts]),
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

  // Widget stickyHeader() {
  //   return Container(
  //     width: MediaQuery.of(context).size.width,
  //     child: ClipRRect(
  //         child: BackdropFilter(
  //             filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
  //             child: tabBarCustom())),
  //   );
  // }

  // Widget tabBarCustom() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
  //     child: TabBar(
  //         controller: _tabController,
  //         isScrollable: true,
  //         indicatorSize: TabBarIndicatorSize.tab,
  //         labelColor: Theme.of(context).colorScheme.primary,
  //         unselectedLabelColor: Colors.grey,
  //         indicator: BoxDecoration(
  //             borderRadius: BorderRadius.circular(10),
  //             color: Theme.of(context).canvasColor,
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Theme.of(context).colorScheme.primary,
  //                 offset: Offset(1.0, 1.0),
  //               ),
  //             ]),
  //         tabs: [
  //           Tab(
  //             text: 'Les plus récents',
  //           ),
  //         ]),
  //   );
  // }

  // Widget tabBarViewCustom() {
  //   return IndexedStack(index: _tabController.index, children: [
  //     Visibility(
  //       child: _loadingPosts
  //           ? posts.length == 0
  //               ? Container(
  //                   height: 100,
  //                   alignment: Alignment.center,
  //                   child: Text(
  //                     "Pas de posts pour ${widget.game.name} actuellement",
  //                     style: Theme.of(context).textTheme.bodyLarge,
  //                     textAlign: TextAlign.center,
  //                   ),
  //                 )
  //               : listPosts()
  //           : Container(
  //               height: 100,
  //               alignment: Alignment.center,
  //               child: SizedBox(
  //                 height: 30.0,
  //                 width: 30.0,
  //                 child: CircularProgressIndicator(
  //                   color: Theme.of(context).colorScheme.primary,
  //                   strokeWidth: 1.0,
  //                 ),
  //               ),
  //             ),
  //       maintainState: true,
  //       visible: _tabController.index == 0,
  //     ),
  //   ]);
  // }
}
