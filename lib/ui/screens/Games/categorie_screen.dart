import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:Gemu/constants/variables.dart';

import 'game_view.dart';

class CategorieScreen extends StatefulWidget {
  CategorieScreen({Key? key, required this.categorie}) : super(key: key);

  final dynamic categorie;

  @override
  _CategorieScreenState createState() => _CategorieScreenState();
}

class _CategorieScreenState extends State<CategorieScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  bool dataIsThere = false;
  String? uid;

  List gamesUser = [];
  List gamesCategories = [];
  List gameFollow = [];
  List gameNoFollow = [];

  @override
  void initState() {
    getAllData();
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  getAllData() async {
    uid = _firebaseAuth.currentUser!.uid;

    var myGames = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
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
        .collection('categories')
        .doc(widget.categorie.id)
        .collection('games')
        .get();
    for (var item in gamesCat.docs) {
      var gameCat = await FirebaseFirestore.instance
          .collection('games')
          .doc(item.id)
          .get();
      gamesCategories.add(gameCat);
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

    setState(() {
      dataIsThere = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: PreferredSize(
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).accentColor
                  ])),
              child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      onPressed: () => Navigator.pop(context)),
                  title: Text(widget.categorie.data()['name']),
                  bottom: PreferredSize(
                      child: Container(
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
                                  color: Theme.of(context).canvasColor),
                              tabs: [Text('A découvrir'), Text('Suivis')],
                            ),
                          )),
                      preferredSize: Size.fromHeight(60))),
            ),
            preferredSize: Size.fromHeight(120)),
        body: dataIsThere
            ? TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(
                    child: gamesNoDiscover(),
                  ),
                  SingleChildScrollView(
                    child: gamesFollow(),
                  )
                ],
              )
            : Center(
                child: CircularProgressIndicator(),
              ));
  }

  Widget gamesFollow() {
    return GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, childAspectRatio: 1, crossAxisSpacing: 6),
        itemCount: gameFollow.length,
        itemBuilder: (BuildContext context, int index) {
          DocumentSnapshot? game = gameFollow[index];
          return GameView(
              game: game as DocumentSnapshot<Map<String, dynamic>>?);
        });
  }

  Widget gamesNoDiscover() {
    return GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, childAspectRatio: 1, crossAxisSpacing: 6),
        itemCount: gameNoFollow.length,
        itemBuilder: (BuildContext context, int index) {
          DocumentSnapshot? game = gameNoFollow[index];
          return GameView(
              game: game as DocumentSnapshot<Map<String, dynamic>>?);
        });
  }
}
