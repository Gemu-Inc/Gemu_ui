import 'package:Gemu/models/models.dart';
import 'package:Gemu/screensmodels/Games/games_screen_model.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/models/data.dart';
import 'package:stacked/stacked.dart';
import 'package:Gemu/ui/screens/Games/categorie_screen.dart';
import 'package:Gemu/ui/screens/Games/game_focus_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Gemu/models/categorie.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({Key key}) : super(key: key);

  @override
  _GamesScreenState createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  List<Games> triGameName() {
    List<Games> game = panelGames;
    game.sort((a, b) => a.nameGame.compareTo(b.nameGame));
    return game;
  }

  /*List<Categorie> triCategorieName() {
    List<Categorie> categorie = panelCategorie;
    categorie.sort((a, b) => a.name.compareTo(b.name));
    return categorie;
  }

  final List<Categorie> categorie = panelCategorie;*/
  final List<Games> game = panelGames;

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

  Widget get followPanel => Container(
        margin: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
        decoration: BoxDecoration(
            color: Color(0xFF222831),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF121212),
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
                  itemCount: game.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                        //color: Colors.pink,
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
                                      builder: (_) => GameFocusScreen(
                                          imageUrl: game[index].imageUrl)),
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
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: AssetImage(
                                                game[index].imageUrl)))),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Text(
                                '${game[index].nameGame}',
                              ),
                            )
                          ],
                        ));
                  }),
            )
          ],
        ),
      );

  Widget get categoriePanel => Container(
        margin: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 80.0),
        decoration: BoxDecoration(
            color: Color(0xFF222831),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF121212),
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
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('categories')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    return Wrap(
                      direction: Axis.horizontal,
                      spacing: 5.0,
                      children: snapshot.data.docs.map((snapshot) {
                        Categorie categorie =
                            Categorie.fromMap(snapshot.data(), snapshot.id);
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
                                                  Theme.of(context)
                                                      .primaryColor,
                                                  Theme.of(context).accentColor
                                                ]),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    )),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Text('${categorie.name}'),
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
                }),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    Animatable<Color> background = TweenSequence<Color>([
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

    return SingleChildScrollView(
      child: Column(
        children: [
          AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            title: PreferredSize(
                child: GestureDetector(
                  onTap: () => print('Search a game'),
                  child: Container(
                    margin: EdgeInsets.only(left: 10.0, right: 20.0),
                    height: 35,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Color(0xFF222831),
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF121212),
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
                        onTap: () => print('Add a game'),
                        child: Container(
                          margin: EdgeInsets.only(
                              top: 5.0, bottom: 5.0, right: 10.0),
                          height: 55,
                          width: 55,
                          decoration: BoxDecoration(
                              color: background.evaluate(AlwaysStoppedAnimation(
                                  _animationController.value)),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: Color(0xFF000000),
                                    offset: Offset(4.0, 1.0))
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
    );
  }
}
