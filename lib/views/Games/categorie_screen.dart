import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:algolia/algolia.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/models/categorie.dart';
import 'package:gemu/providers/index_games_provider.dart';
import 'package:gemu/services/algolia_service.dart';
import 'package:gemu/views/Autres/game_screen.dart';

class CategorieScreen extends StatefulWidget {
  final Categorie categorie;
  final int indexGamesHome;

  CategorieScreen(
      {Key? key, required this.categorie, required this.indexGamesHome})
      : super(key: key);

  @override
  _Categorieviewstate createState() => _Categorieviewstate();
}

class _Categorieviewstate extends State<CategorieScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  bool dataIsThere = false;

  late TabController _tabController;

  List<Game> gamesUser = [];
  List<Game> gamesCategories = [];
  List<Game> gameFollow = [];
  List<Game> gameNoFollow = [];

  late TextEditingController _searchController;
  late FocusNode _keyboardFocusNode;
  bool _searching = false;

  Algolia algolia = AlgoliaService.algolia;
  List<AlgoliaObjectSnapshot> _games = [];

  ScrollController gamesFollowScrollController = ScrollController();
  ScrollController gamesNoDiscoverScrollController = ScrollController();
  ScrollController gamesSearchScrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    getAllData();
    _tabController = TabController(length: 2, vsync: this);
    _searchController = TextEditingController();
    _keyboardFocusNode = FocusNode();

    gamesFollowScrollController.addListener(() {});
    gamesNoDiscoverScrollController.addListener(() {});
    gamesSearchScrollController.addListener(() {});
    super.initState();
  }

  @override
  void deactivate() {
    gamesFollowScrollController.removeListener(() {});
    gamesNoDiscoverScrollController.removeListener(() {});
    gamesSearchScrollController.removeListener(() {});
    super.deactivate();
  }

  @override
  void dispose() {
    gamesFollowScrollController.dispose();
    _keyboardFocusNode.dispose();
    _searchController.clear();
    _tabController.dispose();
    super.dispose();
  }

  getAllData() async {
    var myGames = await FirebaseFirestore.instance
        .collection('users')
        .doc(me!.uid)
        .collection('games')
        .get();
    for (var item in myGames.docs) {
      var myGame = await FirebaseFirestore.instance
          .collection('games')
          .doc('verified')
          .collection('games_verified')
          .doc(item.id)
          .get();
      gamesUser.add(Game.fromMap(myGame, myGame.data()!));
    }

    var gamesCat = await FirebaseFirestore.instance
        .collection('games')
        .doc('verified')
        .collection('games_verified')
        .where('categories', arrayContains: widget.categorie.name)
        .get();
    for (var item in gamesCat.docs) {
      gamesCategories.add(Game.fromMap(item, item.data()));
    }

    for (var i = 0; i < gamesUser.length; i++) {
      for (var j = 0; j < gamesCategories.length; j++) {
        if (gamesUser[i].documentId == gamesCategories[j].documentId) {
          gameFollow.add(gamesUser[i]);
        }
      }
    }

    for (var i = 0; i < gamesCategories.length; i++) {
      gameNoFollow.add(gamesCategories[i]);
    }

    for (var i = 0; i < gamesUser.length; i++) {
      for (var j = 0; j < gameNoFollow.length; j++) {
        if (gameNoFollow[j].documentId == gamesUser[i].documentId) {
          gameNoFollow.remove(gameNoFollow[j]);
        }
      }
    }

    if (mounted) {
      setState(() {
        dataIsThere = true;
      });
    }
  }

  _searchGames() async {
    if (_games.length != 0) {
      _games.clear();
    }

    setState(() {
      _searching = true;
    });

    AlgoliaQuery query = algolia.instance
        .index("games")
        .query(_searchController.text)
        .facetFilter('categories:${widget.categorie.name}');

    _games = (await query.getObjects()).hits;

    print(_games.length);

    setState(() {
      _searching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context)),
          title: Text(widget.categorie.name),
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary
                ])),
          ),
          bottom: PreferredSize(
              child: Column(
                children: [
                  search(),
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                      height: 60.0,
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: TabBar(
                          controller: _tabController,
                          labelColor: Theme.of(context).primaryColor,
                          unselectedLabelColor: Colors.grey,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Theme.of(context).canvasColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).shadowColor,
                                )
                              ]),
                          tabs: [Text('A découvrir'), Text('Suivis')],
                        ),
                      ))
                ],
              ),
              preferredSize: Size.fromHeight(120))),
      body: dataIsThere
          ? TabBarView(
              controller: _tabController,
              children: [
                _searching
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              height: 15.0,
                              width: 15.0,
                              child: CircularProgressIndicator(
                                color: Theme.of(context).primaryColor,
                              )),
                          SizedBox(
                            width: 5.0,
                          ),
                          Text(
                            'Recherche un jeu',
                            style: mystyle(11),
                          )
                        ],
                      )
                    : _searchController.text.isEmpty
                        ? gameNoFollow.length == 0
                            ? Center(
                                child: Text(
                                  'Plus d\'autres jeux à découvrir dans cette catégorie pour le moment',
                                  textAlign: TextAlign.center,
                                  style: mystyle(12),
                                ),
                              )
                            : gamesNoDiscover()
                        : _games.length == 0
                            ? Center(
                                child: Text(
                                  'No results found',
                                  style: mystyle(12),
                                ),
                              )
                            : gamesSearch(_games),
                _searching
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              height: 15.0,
                              width: 15.0,
                              child: CircularProgressIndicator(
                                color: Theme.of(context).primaryColor,
                              )),
                          SizedBox(
                            width: 5.0,
                          ),
                          Text(
                            'Recherche un jeu',
                            style: mystyle(11),
                          )
                        ],
                      )
                    : _searchController.text.isEmpty
                        ? gameFollow.length == 0
                            ? Center(
                                child: Text(
                                  'Pas encore de jeux suivis dans cette catégorie',
                                  textAlign: TextAlign.center,
                                  style: mystyle(12),
                                ),
                              )
                            : gamesFollow()
                        : _games.length == 0
                            ? Center(
                                child: Text(
                                  'No results found',
                                  style: mystyle(12),
                                ),
                              )
                            : gamesSearch(_games),
              ],
            )
          : Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
    );
  }

  Widget search() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
        height: 45,
        width: MediaQuery.of(context).size.width / 1.2,
        child: TextField(
            controller: _searchController,
            focusNode: _keyboardFocusNode,
            cursorColor: Theme.of(context).primaryColor,
            textInputAction: TextInputAction.search,
            onTap: () {
              setState(() {
                FocusScope.of(context).requestFocus(_keyboardFocusNode);
              });
            },
            onChanged: (value) {
              _searchGames();
            },
            decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).canvasColor,
                hintText: 'Recherche un jeu "${widget.categorie.name}"',
                hintStyle: mystyle(12),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, width: 1.5),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 20,
                  color: _keyboardFocusNode.hasFocus
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                suffixIcon: _searchController.text.isEmpty
                    ? SizedBox()
                    : IconButton(
                        icon: Icon(
                          Icons.clear,
                          size: 20,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        }))),
      ),
    );
  }

  Widget gamesFollow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GridView.builder(
          controller: gamesFollowScrollController,
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          physics:
              AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6),
          itemCount: gameFollow.length,
          itemBuilder: (BuildContext context, int index) {
            Game game = gameFollow[index];
            return GameView(
              key: ValueKey(game.name),
              game: game,
              indexGamesHome: widget.indexGamesHome,
            );
          }),
    );
  }

  Widget gamesNoDiscover() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GridView.builder(
          controller: gamesNoDiscoverScrollController,
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          physics:
              AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6),
          itemCount: gameNoFollow.length,
          itemBuilder: (BuildContext context, int index) {
            Game game = gameNoFollow[index];
            return GameView(
              key: ValueKey(game.name),
              game: game,
              indexGamesHome: widget.indexGamesHome,
            );
          }),
    );
  }

  Widget gamesSearch(List<AlgoliaObjectSnapshot> games) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GridView.builder(
          controller: gamesSearchScrollController,
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          physics:
              AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6),
          itemCount: games.length,
          itemBuilder: (_, index) {
            Game game = Game.fromMapAlgolia(games[index], games[index].data);
            return GameView(
                key: ValueKey(game.name),
                game: game,
                indexGamesHome: widget.indexGamesHome);
          }),
    );
  }
}

class GameView extends StatefulWidget {
  final Game game;
  final int indexGamesHome;

  const GameView({Key? key, required this.game, required this.indexGamesHome})
      : super(key: key);

  @override
  GameViewState createState() => GameViewState();
}

class GameViewState extends State<GameView> {
  bool dataIsThere = false;
  bool isFollow = false;

  List<Game> games = [];

  @override
  void initState() {
    super.initState();
    getGames();
  }

  getGames() async {
    if (!dataIsThere) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(me!.uid)
          .collection('games')
          .get()
          .then((value) {
        for (var item in value.docs) {
          games.add(Game.fromMap(item, item.data()));
        }
      });

      if (games.any((element) => element.name == widget.game.name)) {
        setState(() {
          isFollow = true;
        });
      } else {
        setState(() {
          isFollow = false;
        });
      }

      setState(() {
        dataIsThere = true;
      });
    }
  }

  follow(WidgetRef ref) async {
    if (games.any((element) => element.name == widget.game.name)) {
      ref
          .read(indexGamesNotifierProvider.notifier)
          .updateIndexNewGame(games.length - 1);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(me!.uid)
          .collection('games')
          .doc(widget.game.documentId)
          .delete();
      setState(() {
        isFollow = false;
      });
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(me!.uid)
          .collection('games')
          .doc(widget.game.documentId)
          .set({'name': widget.game.name, 'imageUrl': widget.game.imageUrl});
      setState(() {
        isFollow = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return dataIsThere
        ? Container(
            child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Container(
                  height: 70,
                  width: 70,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => GameScreen(game: widget.game)),
                          ),
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Theme.of(context).colorScheme.primary,
                                      Theme.of(context).colorScheme.secondary
                                    ]),
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider(
                                        widget.game.imageUrl))),
                          ),
                        ),
                      ),
                      Positioned(bottom: 0, right: 0, child: followGame()),
                    ],
                  ),
                ),
              ),
              Text(
                widget.game.name,
                textAlign: TextAlign.center,
              ),
            ],
          ))
        : Center(
            child: CircularProgressIndicator(),
          );
  }

  Widget followGame() {
    return Consumer(builder: (_, ref, child) {
      return GestureDetector(
          //key: widget.key,
          onTap: () {
            follow(ref);
          },
          child: Container(
              height: 25,
              width: 25,
              decoration: BoxDecoration(
                  color: isFollow ? Colors.green[400] : Colors.red[400],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black)),
              child: isFollow
                  ? Icon(
                      Icons.check,
                      size: 20,
                      color: Colors.black,
                    )
                  : Icon(
                      Icons.add,
                      size: 20,
                      color: Colors.black,
                    )));
    });
  }
}
