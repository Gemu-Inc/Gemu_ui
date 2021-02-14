import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:Gemu/ui/widgets/follow_game_button.dart';
import 'package:Gemu/ui/widgets/unfollow_game_button.dart';
import 'package:Gemu/models/categorie.dart';
import 'package:Gemu/models/game.dart';
import 'package:Gemu/ui/screens/Games/game_focus_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Gemu/models/user.dart';

class CategorieScreen extends StatefulWidget {
  CategorieScreen({Key key, @required this.categorie}) : super(key: key);

  final Categorie categorie;

  @override
  _CategorieScreenState createState() => _CategorieScreenState();
}

class _CategorieScreenState extends State<CategorieScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget get gamesFollow => FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(_firebaseAuth.currentUser.uid)
            .get(),
        builder: (context, snapshotUser) {
          if (snapshotUser.hasData) {
            return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('games')
                    .where(FieldPath.documentId,
                        whereIn: widget.categorie.idGames)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    return Wrap(
                      direction: Axis.horizontal,
                      children: snapshot.data.docs.map((snapshot) {
                        Game game = Game.fromMap(snapshot.data(), snapshot.id);
                        for (var i = 0;
                            i < snapshotUser.data['idGames'].length;
                            i++) {
                          if (game.documentId ==
                              snapshotUser.data['idGames'][i]) {
                            return Container(
                                margin:
                                    EdgeInsets.only(bottom: 10.0, top: 10.0),
                                width: 90,
                                height: 85,
                                child: Stack(
                                  children: [
                                    Align(
                                        alignment: Alignment.topCenter,
                                        child: GestureDetector(
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) => GameFocusScreen(
                                                    imageUrl: game.imageUrl)),
                                          ),
                                          child: Container(
                                            height: 60,
                                            width: 60,
                                            decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      Theme.of(context)
                                                          .primaryColor,
                                                      Theme.of(context)
                                                          .accentColor
                                                    ]),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image:
                                                        CachedNetworkImageProvider(
                                                            game.imageUrl))),
                                          ),
                                        )),
                                    Positioned(
                                        bottom: 20,
                                        right: 10,
                                        child: GestureDetector(
                                          onTap: () => print('appuie'),
                                          child: UnfollowGameButton(
                                            game: game,
                                          ),
                                        )),
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Text(game.name),
                                    )
                                  ],
                                ));
                          }
                        }
                        return SizedBox();
                      }).toList(),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                });
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      );

  Widget get gamesNoDiscover => FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(_firebaseAuth.currentUser.uid)
            .get(),
        builder: (context, snapshotUser) {
          if (snapshotUser.hasData) {
            return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('games')
                    .where(FieldPath.documentId,
                        whereIn: widget.categorie.idGames)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    return Wrap(
                      direction: Axis.horizontal,
                      children: snapshot.data.docs.map((snapshot) {
                        Game game = Game.fromMap(snapshot.data(), snapshot.id);
                        for (var i = 0;
                            i < snapshotUser.data['idGames'].length;
                            i++) {
                          if (game.documentId ==
                              snapshotUser.data['idGames'][i]) {
                            return SizedBox();
                          }
                        }
                        return Container(
                            margin: EdgeInsets.only(bottom: 10.0, top: 10.0),
                            width: 90,
                            height: 85,
                            child: Stack(
                              children: [
                                Align(
                                    alignment: Alignment.topCenter,
                                    child: GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => GameFocusScreen(
                                                imageUrl: game.imageUrl)),
                                      ),
                                      child: Container(
                                        height: 60,
                                        width: 60,
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Theme.of(context)
                                                      .primaryColor,
                                                  Theme.of(context).accentColor
                                                ]),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image:
                                                    CachedNetworkImageProvider(
                                                        game.imageUrl))),
                                      ),
                                    )),
                                Positioned(
                                  bottom: 20,
                                  right: 10,
                                  child: FollowGameButton(
                                    game: game,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Text(game.name),
                                )
                              ],
                            ));
                      }).toList(),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                });
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            title: Text(widget.categorie.name),
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
              child: gamesNoDiscover,
            ),
            SingleChildScrollView(
              child: gamesFollow,
            )
          ],
        ));
  }
}
