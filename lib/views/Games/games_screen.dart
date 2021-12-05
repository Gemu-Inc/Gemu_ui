import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import 'package:flutter/services.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/views/Games/categorie_screen.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/models/categorie.dart';
import 'package:gemu/widgets/alert_dialog_custom.dart';
import 'package:gemu/providers/index_tab_games_home.dart';
import 'package:gemu/views/Autres/game_screen.dart';

import 'add_game_screen.dart';

class GamesScreen extends StatefulWidget {
  final String uid;
  final List<Game> games;
  final IndexGamesHome indexGamesHome;

  const GamesScreen(
      {Key? key,
      required this.uid,
      required this.games,
      required this.indexGamesHome})
      : super(key: key);

  @override
  _Gamesviewstate createState() => _Gamesviewstate();
}

class _Gamesviewstate extends State<GamesScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  ScrollController _mainScrollController = ScrollController();

  bool dataIsThere = false;
  bool loadMoreCategorie = false;
  List<Categorie> categoriesList = [];

  scrollListener() {}

  unfollowGame(Game game) async {
    await widget.indexGamesHome.setIndexNewGame(widget.games.length - 1);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(me!.uid)
        .collection('games')
        .doc(game.name)
        .delete();
  }

  getCategories() async {
    await FirebaseFirestore.instance
        .collection('categories')
        .orderBy('name')
        .get()
        .then((value) {
      for (var item in value.docs) {
        categoriesList.add(Categorie.fromMap(item, item.data()));
      }
    });

    if (!dataIsThere && mounted) {
      setState(() {
        dataIsThere = true;
      });
    }
  }

  loadMoreCategories() async {
    setState(() {
      loadMoreCategorie = true;
    });

    Categorie lastCategorie = categoriesList.last;

    await FirebaseFirestore.instance
        .collection('categories')
        .orderBy('name')
        .startAfterDocument(lastCategorie.snapshot)
        .limit(6)
        .get()
        .then((value) {
      for (var item in value.docs) {
        categoriesList.add(Categorie.fromMap(item, item.data()));
      }
    });

    setState(() {
      loadMoreCategorie = false;
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _mainScrollController.addListener(scrollListener);
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 5))
          ..repeat();

    getCategories();
  }

  @override
  void deactivate() {
    _mainScrollController.removeListener(scrollListener);
    super.deactivate();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _mainScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              Theme.of(context).brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
          systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor),
      child: Scaffold(
        appBar: PreferredSize(
            child: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 6,
              title: Text(
                'Games',
                style: mystyle(20),
              ),
              bottom: PreferredSize(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    child: Container(
                      child: followGames(),
                    ),
                  ),
                  preferredSize: Size.fromHeight(100)),
            ),
            preferredSize:
                Size.fromHeight(MediaQuery.of(context).size.height / 4)),
        body: SingleChildScrollView(
          controller: _mainScrollController,
          scrollDirection: Axis.vertical,
          physics:
              AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            children: [
              SizedBox(
                height: 20.0,
              ),
              StickyHeader(
                  controller: _mainScrollController,
                  header: stickyHeader(),
                  content: categories())
            ],
          ),
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(
              right: 5.0, bottom: (MediaQuery.of(context).size.height / 11)),
          child: addGame(),
        ),
      ),
    );
  }

  Widget stickyHeader() {
    return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.centerLeft,
        child: tabBar());
  }

  Widget followGames() {
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          itemCount: widget.games.length,
          itemBuilder: (BuildContext context, int index) {
            Game game = widget.games[index];
            return Container(
                margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 5.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => GameScreen(game: game)),
                      ),
                      onLongPress: () {
                        alertUnfollowGame(game);
                      },
                      child: Container(
                          margin: EdgeInsets.fromLTRB(11.0, 11.0, 11.0, 11.0),
                          height: 55,
                          width: 55,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.secondary
                                  ]),
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: CachedNetworkImageProvider(
                                      game.imageUrl)))),
                    ),
                    Text(
                      game.name,
                    ),
                  ],
                ));
          }),
    );
  }

  Future alertUnfollowGame(Game game) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialogCustom(context, 'Unfollow game',
              'Êtes-vous sur de vouloir retirer ce jeu de vos abonnements?', [
            TextButton(
                onPressed: () async {
                  await unfollowGame(game);
                  print(widget.games.length);
                  Navigator.pop(context);
                },
                child: Text(
                  'Oui',
                  style: TextStyle(color: Colors.blue[200]),
                )),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Non',
                  style: TextStyle(color: Colors.red[200]),
                )),
          ]);
        });
  }

  Widget tabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      child: Container(
        height: 50,
        width: 90,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).canvasColor,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor,
                offset: Offset(1.0, 1.0),
              ),
            ]),
        child: Text(
          'Categories',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  Widget categories() {
    return dataIsThere
        ? Container(
            padding: EdgeInsets.only(
                top: 10.0,
                bottom: (MediaQuery.of(context).size.height / 11) + 5.0),
            child: Column(
              children: [
                ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: categoriesList.length,
                    itemBuilder: (_, index) {
                      Categorie categorie = categoriesList[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Ink(
                          height: 100,
                          decoration: BoxDecoration(
                              color: Theme.of(context).canvasColor,
                              borderRadius: BorderRadius.circular(5.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).primaryColor,
                                  offset: Offset(1.0, 1.0),
                                )
                              ]),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(5.0),
                            splashColor: Theme.of(context).primaryColor,
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => CategorieScreen(
                                          categorie: categorie,
                                          indexGamesHome: widget.indexGamesHome,
                                        ))),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0),
                                  child: Container(
                                    height: 60,
                                    width: 60,
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
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Icon(Icons.category),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 15.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          categorie.name,
                                          style: mystyle(18),
                                        ),
                                        SizedBox(
                                          height: 2.0,
                                        ),
                                        Text('Games: ${categorie.games}'),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Container(
                    height: 50.0,
                    child: Center(
                      child: Center(
                        child: Text('C\'est tout pour le moment'),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        : Container(
            height: 150,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
                strokeWidth: 1.5,
              ),
            ),
          );
  }

  Widget addGame() {
    Animatable<Color?> background = TweenSequence<Color?>([
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Theme.of(context).colorScheme.primary,
          end: Theme.of(context).colorScheme.secondary,
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Theme.of(context).colorScheme.secondary,
          end: Theme.of(context).colorScheme.primary,
        ),
      ),
    ]);

    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => Container(
              height: 50,
              width: 50,
              child: FloatingActionButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddGameScreen()),
                ),
                elevation: 6,
                splashColor: Theme.of(context).scaffoldBackgroundColor,
                backgroundColor: background.evaluate(
                    AlwaysStoppedAnimation(_animationController.value)),
                child: Icon(
                  Icons.add,
                  size: 30,
                ),
              ),
            ));
  }
}
