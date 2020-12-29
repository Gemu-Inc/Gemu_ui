import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:Gemu/screensmodels/Share/create_post_model.dart';
import 'package:Gemu/models/data.dart';
import 'package:Gemu/models/game_model.dart';
import 'package:Gemu/models/categorie_post_model.dart';

class CreatePostScreen extends StatefulWidget {
  CreatePostScreen({Key key}) : super(key: key);

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  List<Game> games = panelGames;
  List<CategoriePost> sections = categoriePosts;
  final contentController = TextEditingController();
  String selected_game;
  String selected_section;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CreatePostModel>.reactive(
        viewModelBuilder: () => CreatePostModel(),
        builder: (context, model, child) => Scaffold(
              appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                      icon: Icon(
                        Icons.clear,
                        size: 30,
                      ),
                      onPressed: () => Navigator.pop(context)),
                  title: Text('Create post'),
                  centerTitle: true),
              body: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Container(
                            color: Colors.black,
                            child: ExpansionTile(
                              title: selected_game == null
                                  ? Text('Game')
                                  : Text(selected_game),
                              children: games.map((Game game) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 10.0),
                                  child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selected_game = game.nameGame;
                                        });
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding:
                                                EdgeInsets.only(left: 15.0),
                                            child: Text('${game.nameGame}'),
                                          ),
                                          Icon(
                                            Icons.clear,
                                            color: Colors.red,
                                            size: 15,
                                          )
                                        ],
                                      )),
                                );
                              }).toList(),
                            )),
                      ),
                      SliverPadding(
                          padding: EdgeInsets.symmetric(vertical: 20.0)),
                      SliverToBoxAdapter(
                          child: Container(
                              color: Colors.black,
                              child: ExpansionTile(
                                title: selected_section == null
                                    ? Text('Section')
                                    : Text(selected_section),
                                children: sections.map((CategoriePost section) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 10.0),
                                    child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selected_section = section.name;
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(left: 15.0),
                                              child: Text('${section.name}'),
                                            ),
                                            Icon(
                                              Icons.clear,
                                              color: Colors.red,
                                              size: 15,
                                            )
                                          ],
                                        )),
                                  );
                                }).toList(),
                              ))),
                      SliverPadding(
                          padding: EdgeInsets.symmetric(vertical: 20.0)),
                      SliverToBoxAdapter(
                        child: Container(
                          color: Colors.black,
                          child: TextField(
                            controller: contentController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                          padding: EdgeInsets.symmetric(vertical: 20.0)),
                      SliverToBoxAdapter(
                          child: GestureDetector(
                              onTap: () => model.selectImage(),
                              child: model.selectedImage == null
                                  ? Container(
                                      height: 250,
                                      decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      alignment: Alignment.center,
                                      child: Container(
                                        height: 50,
                                        child: Stack(
                                          children: [
                                            Align(
                                              alignment: Alignment.topCenter,
                                              child: Icon(
                                                Icons.image,
                                                size: 30.0,
                                              ),
                                            ),
                                            Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Text(
                                                  'Tap to add an image',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ))
                                          ],
                                        ),
                                      ))
                                  : Container(
                                      height: 250,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Image.file(model.selectedImage,
                                          fit: BoxFit.cover),
                                    )))
                    ],
                  )),
              floatingActionButton: FloatingActionButton(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme.of(context).primaryColor,
                                  Theme.of(context).accentColor
                                ])),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.add,
                          size: 25,
                        ),
                      )
                    ],
                  ),
                  onPressed: () => model.addPost(
                      game: selected_game,
                      section: selected_section,
                      content: contentController.text)),
            ));
  }
}
