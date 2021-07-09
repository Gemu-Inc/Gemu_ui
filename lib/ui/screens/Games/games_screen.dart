import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:gemu/ui/screens/Games/categorie_screen.dart';
import 'package:gemu/ui/screens/Games/game_focus_screen.dart';

import 'search_game_screen.dart';
import 'add_game_screen.dart';

class GamesScreen extends StatefulWidget {
  final String? uid;

  const GamesScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _GamesScreenState createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String? uid;
  List categories = [];

  late StreamSubscription streamGamesListener;
  List gamesFollow = [];

  bool dataIsThere = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    uid = _firebaseAuth.currentUser!.uid;

    streamGamesListener = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('games')
        .snapshots()
        .listen((document) {
      print('listener games');
      print(gamesFollow.length);
      if (gamesFollow.length != 0) gamesFollow.clear();
      for (var item in document.docs) {
        gamesFollow.add(item);
      }
    });

    getAllData();

    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 5))
          ..repeat();
  }

  @override
  void dispose() {
    streamGamesListener.cancel();
    gamesFollow.clear();
    _animationController.dispose();
    super.dispose();
  }

  getAllData() async {
    var data = await FirebaseFirestore.instance.collection('categories').get();
    categories = data.docs;

    setState(() {
      dataIsThere = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Animatable<Color?> background = TweenSequence<Color?>([
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Theme.of(context).primaryColor,
          end: Theme.of(context).accentColor,
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Theme.of(context).accentColor,
          end: Theme.of(context).primaryColor,
        ),
      ),
    ]);

    return dataIsThere
        ? SingleChildScrollView(
            child: Column(
              children: [
                AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  automaticallyImplyLeading: false,
                  title: PreferredSize(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SearchGameScreen())),
                        child: Container(
                          margin: EdgeInsets.only(left: 10.0, right: 20.0),
                          height: 35,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Theme.of(context).canvasColor,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).shadowColor,
                                  offset: Offset(-5.0, 5.0),
                                )
                              ]),
                          child: Row(
                            children: [
                              SizedBox(width: 5.0),
                              Icon(
                                Icons.search,
                                size: 20.0,
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                'Rechercher',
                                style: TextStyle(fontSize: 15.0),
                              )
                            ],
                          ),
                        ),
                      ),
                      preferredSize: Size.fromHeight(40)),
                  centerTitle: true,
                  actions: [
                    AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) => GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => AddGameScreen())),
                              child: Container(
                                margin: EdgeInsets.only(
                                    top: 5.0, bottom: 5.0, right: 10.0),
                                height: 55,
                                width: 55,
                                decoration: BoxDecoration(
                                    color: background.evaluate(
                                        AlwaysStoppedAnimation(
                                            _animationController.value)),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Theme.of(context).shadowColor,
                                          offset: Offset(2.0, 0.0))
                                    ]),
                                child: Icon(
                                  Icons.add,
                                  size: 30,
                                ),
                              ),
                            )),
                  ],
                ),
                followPanel,
                categoriePanel
              ],
            ),
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }

  Widget get followPanel => Container(
        margin: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
        decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor,
                offset: Offset(-5.0, 5.0),
              )
            ]),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 15.0, left: 15.0),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text('Games',
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
              ),
            ),
            Container(
                margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                height: 120,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: gamesFollow.length,
                    itemBuilder: (BuildContext context, int index) {
                      DocumentSnapshot<Map<String, dynamic>> game =
                          gamesFollow[index];
                      return Container(
                          margin: EdgeInsets.all(10.0),
                          width: 100,
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            GameFocusScreen(game: game)),
                                  ),
                                  child: Container(
                                      margin: EdgeInsets.fromLTRB(
                                          11.0, 11.0, 11.0, 11.0),
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: CachedNetworkImageProvider(
                                                  game.data()!['imageUrl'])))),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Text(
                                  '${game.data()!['name']}',
                                ),
                              )
                            ],
                          ));
                    }))
          ],
        ),
      );

  Widget get categoriePanel => Container(
        margin: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 80.0),
        decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor,
                offset: Offset(-5.0, 5.0),
              )
            ]),
        child: Column(
          children: [
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                child: Container(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text('Games categories',
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ),
                )),
            GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 6),
                itemCount: categories.length,
                itemBuilder: (BuildContext context, int index) {
                  var categorie = categories[index];
                  return Container(
                      margin: EdgeInsets.only(bottom: 10.0, top: 10.0),
                      width: 90,
                      height: 80,
                      child: Stack(
                        children: [
                          Align(
                              alignment: Alignment.topCenter,
                              child: GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => CategorieScreen(
                                          categorie: categorie)),
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
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Icon(Icons.category),
                                ),
                              )),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(categorie.data()['name']),
                          )
                        ],
                      ));
                }),
          ],
        ),
      );
}
