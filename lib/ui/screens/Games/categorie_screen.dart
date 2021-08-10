import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/ui/screens/Games/game_focus_screen.dart';
import 'package:gemu/models/categorie.dart';

class CategorieScreen extends StatefulWidget {
  final Categorie categorie;

  CategorieScreen({Key? key, required this.categorie}) : super(key: key);

  @override
  _CategorieScreenState createState() => _CategorieScreenState();
}

class _CategorieScreenState extends State<CategorieScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;

  bool dataIsThere = false;

  List gamesUser = [];
  List gamesCategories = [];
  List gameFollow = [];
  List gameNoFollow = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    getAllData();
    _tabController = TabController(length: 2, vsync: this);
    _searchController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
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
          .doc(item.id)
          .get();
      gamesUser.add(myGame);
    }

    var gamesCat = await FirebaseFirestore.instance
        .collection('games')
        .where('categories', arrayContains: widget.categorie.name)
        .get();
    for (var item in gamesCat.docs) {
      if (item.data()['verified'] == true) {
        gamesCategories.add(item);
      }
    }

    for (var i = 0; i < gamesUser.length; i++) {
      for (var j = 0; j < gamesCategories.length; j++) {
        if (gamesUser[i].id == gamesCategories[j].id) {
          gameFollow.add(gamesUser[i]);
        }
      }
    }

    for (var i = 0; i < gamesCategories.length; i++) {
      gameNoFollow.add(gamesCategories[i]);
    }

    for (var i = 0; i < gamesUser.length; i++) {
      for (var j = 0; j < gameNoFollow.length; j++) {
        if (gameNoFollow[j].id == gamesUser[i].id) {
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
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
                  Theme.of(context).primaryColor,
                  Theme.of(context).accentColor
                ])),
          ),
          bottom: PreferredSize(
              child: Column(
                children: [
                  search(),
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
                                  offset: Offset(-2.5, 2.5),
                                )
                              ]),
                          tabs: [Text('A découvrir'), Text('Suivis')],
                        ),
                      ))
                ],
              ),
              preferredSize: Size.fromHeight(100))),
      body: dataIsThere
          ? TabBarView(
              controller: _tabController,
              children: [
                gameNoFollow.length == 0
                    ? Center(
                        child: Text(
                          'Plus d\'autres jeux à découvrir dans cette catégorie pour le moment',
                          textAlign: TextAlign.center,
                          style: mystyle(12),
                        ),
                      )
                    : gamesNoDiscover(),
                gameFollow.length == 0
                    ? Center(
                        child: Text(
                          'Pas encore de jeux suivis dans cette catégorie',
                          textAlign: TextAlign.center,
                          style: mystyle(12),
                        ),
                      )
                    : gamesFollow(),
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
            cursorColor: Theme.of(context).accentColor,
            decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).canvasColor,
                hintText: 'Recherche un jeu',
                hintStyle: mystyle(12),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).accentColor)),
                prefixIcon: Icon(
                  Icons.search,
                  size: 20,
                ),
                suffixIcon: IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 20,
                    ),
                    onPressed: () => _searchController.clear()))),
      ),
    );
  }

  Widget gamesFollow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6),
          itemCount: gameFollow.length,
          itemBuilder: (BuildContext context, int index) {
            Game game =
                Game.fromMap(gameFollow[index], gameFollow[index].data());
            return GameView(game: game);
          }),
    );
  }

  Widget gamesNoDiscover() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6),
          itemCount: gameNoFollow.length,
          itemBuilder: (BuildContext context, int index) {
            Game game =
                Game.fromMap(gameNoFollow[index], gameNoFollow[index].data());
            return GameView(game: game);
          }),
    );
  }
}

class GameView extends StatefulWidget {
  final Game game;

  GameView({required this.game});

  @override
  GameViewState createState() => GameViewState();
}

class GameViewState extends State<GameView> {
  bool dataIsThere = false;
  bool isFollow = false;

  @override
  void initState() {
    super.initState();
    getAllData();
  }

  getAllData() async {
    List games = [];
    var doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(me!.uid)
        .collection('games')
        .get();
    for (var item in doc.docs) {
      games.add(item.id);
    }
    if (games.contains(widget.game.documentId)) {
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

  follow() async {
    List games = [];
    var doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(me!.uid)
        .collection('games')
        .get();
    for (var item in doc.docs) {
      games.add(item.id);
    }
    if (games.contains(widget.game.documentId)) {
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
                                builder: (_) =>
                                    GameFocusScreen(game: widget.game)),
                          ),
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Theme.of(context).primaryColor,
                                      Theme.of(context).accentColor
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
    return GestureDetector(
        onTap: () => follow(),
        child: Container(
            height: 25,
            width: 25,
            decoration: BoxDecoration(
                color: isFollow ? Colors.green[400] : Colors.red[400],
                shape: BoxShape.circle,
                border: Border.all(color: Color(0xFF222831))),
            child: isFollow
                ? Icon(
                    Icons.check,
                    size: 20,
                  )
                : Icon(
                    Icons.add,
                    size: 20,
                  )));
  }
}
