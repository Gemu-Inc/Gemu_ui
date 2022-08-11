import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemu/components/alert_dialog_custom.dart';
import 'package:gemu/constants/constants.dart';

import 'package:gemu/models/game.dart';
import 'package:gemu/models/post.dart';
import 'package:gemu/providers/Games/games_discover_provider.dart';
import 'package:gemu/providers/Users/myself_provider.dart';
import 'package:gemu/services/database_service.dart';
import 'package:gemu/views/Games/game_focus_screen.dart';

class ProfileGameScreen extends ConsumerStatefulWidget {
  final Game game;

  const ProfileGameScreen({Key? key, required this.game}) : super(key: key);

  @override
  _ProfileGameScreenState createState() => _ProfileGameScreenState();
}

class _ProfileGameScreenState extends ConsumerState<ProfileGameScreen> {
  late ScrollController _scrollController;

  bool _gamePostsIsThere = false;
  bool _isFollowByUser = false;
  bool _setTitleAppBar = false;

  List<Post> posts = [];

  GlobalKey _keyContainer = GlobalKey();
  double heightContainer = 0;

  _getSizeContainer() {
    Future.microtask(() {
      final RenderBox renderBox =
          _keyContainer.currentContext!.findRenderObject() as RenderBox;
      final Size size = renderBox.size;
      heightContainer = size.height;
      print(heightContainer);
    });
  }

  getPostsGame() async {
    await FirebaseFirestore.instance
        .collection('posts')
        .where('gameName', isEqualTo: widget.game.name)
        .orderBy('date', descending: true)
        .limit(20)
        .get()
        .then((post) {
      for (var item in post.docs) {
        posts.add(Post.fromMap(item, item.data()));
      }
    });

    if (!_gamePostsIsThere) {
      setState(() {
        _gamePostsIsThere = true;
      });
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
                  try {
                    await DatabaseService.unfollowGame(
                        context, game, ref, gamesList, stopReached);
                    setState(() {
                      _isFollowByUser = false;
                    });
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
                    await DatabaseService.followGame(context, game, ref);
                    setState(() {
                      _isFollowByUser = true;
                    });
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

    getPostsGame();

    List<Game> gamesFollowsByUser = ref.read(myGamesNotifierProvider);
    if (gamesFollowsByUser.contains(widget.game)) {
      setState(() {
        _isFollowByUser = true;
      });
    }

    _scrollController = ScrollController();
    _scrollController.addListener(() {
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
                        onPressed: () => navHomeAuthKey.currentState!.pop(),
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
        body: bodyView());
  }

  Widget bodyView() {
    return ListView(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      controller: _scrollController,
      children: [
        topBody(),
        const SizedBox(
          height: 25.0,
        ),
        _gamePostsIsThere
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
              )
      ],
    );
  }

  Widget topBody() {
    return Container(
      key: _keyContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
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
                    "24,6 millions followers",
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
    return GridView.builder(
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
        });
  }

  Widget picture(BuildContext context, Post post, int index) {
    return Ink(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          image: DecorationImage(
              image: CachedNetworkImageProvider(post.postUrl),
              fit: BoxFit.cover)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => GameFocusScreen(
                      game: widget.game,
                      index: index,
                      posts: posts,
                    ))),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 5.0, right: 5.0, bottom: 5.0),
                child: Row(
                  children: [
                    post.imageUrl != null
                        ? CircleAvatar(
                            backgroundImage:
                                CachedNetworkImageProvider(post.imageUrl!),
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
                      post.username,
                      style: textStyleCustomRegular(Colors.white, 12),
                    )
                  ],
                ),
              ),
            ),
            Container(
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.0))),
          ],
        ),
      ),
    );
  }

  Widget video(BuildContext context, Post post, int index) {
    return Ink(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          image: DecorationImage(
              image: CachedNetworkImageProvider(post.previewImage!),
              fit: BoxFit.cover)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => GameFocusScreen(
                      game: widget.game,
                      index: index,
                      posts: posts,
                    ))),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0),
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
                    post.imageUrl != null
                        ? CircleAvatar(
                            backgroundImage:
                                CachedNetworkImageProvider(post.imageUrl!),
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
                      post.username,
                      style: textStyleCustomRegular(Colors.white, 12),
                    )
                  ],
                ),
              ),
            ),
            Container(
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.0))),
          ],
        ),
      ),
    );
  }
}
