import 'package:Gemu/models/models.dart';
import 'package:Gemu/screensmodels/Games/games_screen_model.dart';
import 'package:Gemu/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/models/data.dart';
import 'package:stacked/stacked.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<GamesScreenModel>.reactive(
      viewModelBuilder: () => GamesScreenModel(),
      builder: (context, model, child) => CustomScrollScreen(
          widgets: [GamesFollowPanel(), GamesCategoriesPanel()]),
    );
  }
}

class GamesFollowPanel extends StatelessWidget {
  const GamesFollowPanel({Key key}) : super(key: key);

  List<Game> triGameName() {
    List<Game> game = panelGames;
    game.sort((a, b) => a.nameGame.compareTo(b.nameGame));
    return game;
  }

  @override
  Widget build(BuildContext context) {
    final List<Game> game = triGameName();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 15.0, left: 15.0),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text('Abonnements',
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  height: 125,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: game.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                            margin: EdgeInsets.all(10.0),
                            width: 100,
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: GestureDetector(
                                    onTap: () =>
                                        print('Page ${game[index].nameGame}'),
                                    child: Container(
                                        margin: EdgeInsets.all(11.0),
                                        height: 70,
                                        width: 70,
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
          )
        ],
      ),
    );
  }
}

class GamesCategoriesPanel extends StatelessWidget {
  const GamesCategoriesPanel({Key key}) : super(key: key);

  List<Categorie> triCategorieName() {
    List<Categorie> categorie = panelCategorie;
    categorie.sort((a, b) => a.name.compareTo(b.name));
    return categorie;
  }

  @override
  Widget build(BuildContext context) {
    final List<Categorie> categorie = triCategorieName();
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                  child: Container(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text('Catégories',
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                    ),
                  )),
              Container(
                margin: EdgeInsets.all(5.0),
                child: Wrap(
                  direction: Axis.horizontal,
                  children: categorie
                      .map((e) => Container(
                          margin: EdgeInsets.all(15.0),
                          width: 100,
                          height: 100,
                          child: Stack(
                            children: [
                              Align(
                                  alignment: Alignment.topCenter,
                                  child: GestureDetector(
                                    onTap: () => print('Catégorie ${e.name}'),
                                    child: Container(
                                      height: 70,
                                      width: 70,
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Theme.of(context).primaryColor,
                                                Theme.of(context).accentColor
                                              ]),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                  )),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Text('${e.name}'),
                              )
                            ],
                          )))
                      .toList(),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
