import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/ui/screens/Games/categorie_screen.dart';
import 'package:gemu/ui/screens/Games/game_focus_screen.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/models/categorie.dart';
import 'package:gemu/ui/widgets/alert_dialog_custom.dart';
import 'package:gemu/ui/providers/index_tab_games_home.dart';

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
  _GamesScreenState createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  unfollowGame(Game game) async {
    await widget.indexGamesHome.setIndexNewGame(widget.games.length - 1);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(me!.uid)
        .collection('games')
        .doc(game.name)
        .delete();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 5))
          ..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
        child: FutureBuilder(
            future: FirebaseFirestore.instance.collection('categories').get(),
            builder: (context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                );
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: AppBar(
                      automaticallyImplyLeading: false,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      title: Text(
                        'Games',
                        style: mystyle(20),
                      ),
                      actions: [
                        addGame(),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  followGames(),
                  SizedBox(
                    height: 5.0,
                  ),
                  Expanded(
                    child: SingleChildScrollView(child: categories(snapshot)),
                  )
                ],
              );
            }));
  }

  Widget addGame() {
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) => GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => AddGameScreen())),
                  child: Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                      color: background.evaluate(
                          AlwaysStoppedAnimation(_animationController.value)),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add,
                      size: 30,
                    ),
                  ),
                )),
        SizedBox(
          height: 5.0,
        ),
        Text(
          'Add new game',
          style: mystyle(9),
        )
      ],
    );
  }

  Widget followGames() {
    return Container(
        height: 160,
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.all(1.0),
        decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor,
                offset: Offset(0.0, 5.0),
              )
            ]),
        child: Column(
          children: [
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
                child: Container(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text('Suivis', style: mystyle(16)),
                  ),
                )),
            Container(
              height: 120,
              child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
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
                                    builder: (_) =>
                                        GameFocusScreen(game: game)),
                              ),
                              onLongPress: () {
                                alertUnfollowGame(game);
                              },
                              child: Container(
                                  margin: EdgeInsets.fromLTRB(
                                      11.0, 11.0, 11.0, 11.0),
                                  height: 55,
                                  width: 55,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Theme.of(context).primaryColor,
                                            Theme.of(context).accentColor
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
            ),
          ],
        ));
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

  Widget categories(AsyncSnapshot snapshot) {
    return Container(
      margin: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 25.0),
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
                  child: Text('Categories', style: mystyle(16)),
                ),
              )),
          GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, childAspectRatio: 1, crossAxisSpacing: 6),
              itemCount: snapshot.data.docs.length,
              itemBuilder: (BuildContext context, int index) {
                Categorie categorie = Categorie.fromMap(
                    snapshot.data.docs[index],
                    snapshot.data.docs[index].data());
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
                                          categorie: categorie,
                                          indexGamesHome: widget.indexGamesHome,
                                        )),
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
                          child: Text(categorie.name),
                        )
                      ],
                    ));
              }),
        ],
      ),
    );
  }
}
