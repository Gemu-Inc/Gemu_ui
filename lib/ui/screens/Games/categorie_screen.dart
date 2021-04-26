import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:Gemu/constants/variables.dart';

import 'game_view.dart';

class CategorieScreen extends StatefulWidget {
  CategorieScreen({Key key, @required this.categorie}) : super(key: key);

  final dynamic categorie;

  @override
  _CategorieScreenState createState() => _CategorieScreenState();
}

class _CategorieScreenState extends State<CategorieScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  bool dataIsThere = false;
  String uid;
  DocumentSnapshot user;
  Future result;
  Stream stream;

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
    _tabController.dispose();
    super.dispose();
  }

  getAllData() async {
    uid = _firebaseAuth.currentUser.uid;
    user = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      dataIsThere = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return dataIsThere
        ? Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: GradientAppBar(
                elevation: 6.0,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).accentColor
                  ],
                ),
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
            body: TabBarView(
              controller: _tabController,
              children: [
                SingleChildScrollView(
                  child: gamesNoDiscover(),
                ),
                SingleChildScrollView(
                  child: gamesFollow(),
                )
              ],
            ))
        : Center(
            child: CircularProgressIndicator(),
          );
  }

  Widget gamesFollow() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('games')
            .where(FieldPath.documentId, whereIn: user.data()['idGames'])
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          print('snapshot: ${snapshot.data.docs.length}');
          if (gameFollow.length != 0) {
            gameFollow.clear();
          }
          for (int i = 0; i < snapshot.data.docs.length; i++) {
            DocumentSnapshot game = snapshot.data.docs[i];
            for (int j = 0;
                j < widget.categorie.data()['idGames'].length;
                j++) {
              if (game.data()['id'] == widget.categorie.data()['idGames'][j]) {
                gameFollow.add(game);
              }
            }
          }
          print(gameFollow.length);
          if (gameFollow.length == 0) {
            return Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 3),
                child: Center(
                  child: Text(
                    'Pas encore de jeu suivis dans cette catégorie',
                    style: mystyle(11),
                  ),
                ));
          }
          return GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, childAspectRatio: 1, crossAxisSpacing: 6),
              itemCount: gameFollow.length,
              itemBuilder: (BuildContext context, int index) {
                DocumentSnapshot game = gameFollow[index];
                return GameView(game: game);
              });
        });
  }

  Widget gamesNoDiscover() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('games')
            .where(FieldPath.documentId, whereNotIn: user.data()['idGames'])
            .snapshots(),
        builder: (context, snapshot) {
          {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            if (gameNoFollow.length != 0) {
              gameNoFollow.clear();
            }
            for (int i = 0; i < snapshot.data.docs.length; i++) {
              DocumentSnapshot game = snapshot.data.docs[i];
              for (int j = 0;
                  j < widget.categorie.data()['idGames'].length;
                  j++) {
                if (game.data()['id'] ==
                    widget.categorie.data()['idGames'][j]) {
                  gameNoFollow.add(game);
                }
              }
            }
            if (gameNoFollow.length == 0) {
              return Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 3),
                  child: Center(
                    child: Text(
                      'Pas encore de jeu dans cette catégorie',
                      style: mystyle(11),
                    ),
                  ));
            }
            return GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 6),
                itemCount: gameNoFollow.length,
                itemBuilder: (BuildContext context, int index) {
                  DocumentSnapshot game = gameNoFollow[index];
                  return GameView(game: game);
                });
          }
        });
  }
}
