import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gemu/models/user.dart';

import 'package:http/http.dart' as http;

import 'package:gemu/constants/constants.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/components/app_bar_custom.dart';

class PanelSupportScreen extends StatefulWidget {
  @override
  PanelSupportviewstate createState() => PanelSupportviewstate();
}

class PanelSupportviewstate extends State<PanelSupportScreen> {
  late ScrollController _scrollController;

  Map<UserModel, Game> demandesNewGames = {};
  bool dataIsThere = false;

  getDemandesNewGames() async {
    List<Game> games = [];
    List<UserModel> users = [];

    await FirebaseFirestore.instance
        .collection('games')
        .doc('not_verified')
        .collection('games_not_verified')
        .get()
        .then((value) {
      for (var item in value.docs) {
        games.add(Game.fromMap(item, item.data()));
      }
    });

    for (var i = 0; i < games.length; i++) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(games[i].idDemandeur)
          .get()
          .then((value) => users.add(UserModel.fromMap(value, value.data()!)));
    }

    for (var i = 0; i < users.length; i++) {
      demandesNewGames[users[i]] = games[i];
    }

    setState(() {
      dataIsThere = true;
    });
  }

  validate(String idGame, String imageUrl, List gameCategories,
      UserModel user) async {
    await FirebaseFirestore.instance
        .collection('games')
        .doc('not_verified')
        .collection('games_not_verified')
        .doc(idGame)
        .delete();

    await FirebaseFirestore.instance
        .collection('games')
        .doc('verified')
        .collection('games_verified')
        .doc(idGame)
        .set({
      'categories': gameCategories,
      'id': idGame,
      'imageUrl': imageUrl,
      'name': idGame
    });

    var url = Uri.parse(
        'https://us-central1-gemu-app.cloudfunctions.net/sendMailAcceptRequestNewGame?dest=${user.uid}');
    var res = await http.get(url);
    print(res.body);

    print('success');
  }

  decline(String idGame, String imageUrl, List gameCategories,
      UserModel user) async {
    await FirebaseStorage.instance.refFromURL(imageUrl).delete();
    await FirebaseFirestore.instance
        .collection('games')
        .doc('not_verified')
        .collection('games_not_verified')
        .doc(idGame)
        .delete();

    var url = Uri.parse(
        'https://us-central1-gemu-app.cloudfunctions.net/sendMailRefuseRequestNewGame?dest=${user.uid}');
    var res = await http.get(url);
    print(res.body);

    print('success');
  }

  @override
  void initState() {
    super.initState();
    getDemandesNewGames();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBarCustom(
          context: context,
          title: 'Panel support',
          actions: [],
        ),
        body: dataIsThere
            ? demandesNewGames.length == 0
                ? Center(
                    child: Text(
                    'Pas encore de demandes',
                  ))
                : Container(
                    height: MediaQuery.of(context).size.height,
                    child: ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 25.0),
                        controller: _scrollController,
                        physics: AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics()),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: demandesNewGames.length,
                        itemBuilder: (_, int index) {
                          UserModel user =
                              demandesNewGames.keys.elementAt(index);
                          return demandeGame(user, demandesNewGames[user]!);
                        }),
                  )
            : Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  strokeWidth: 1.5,
                ),
              ));
  }

  Widget demandeGame(UserModel user, Game gameNoVerified) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
      child: Container(
        height: 250,
        decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            border: Border.all(color: Colors.black),
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).colorScheme.primary,
                  blurRadius: 3,
                  spreadRadius: 3)
            ]),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Container(
                  height: 70,
                  alignment: Alignment.center,
                  child: ListTile(
                    leading: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: CachedNetworkImageProvider(user.imageUrl!),
                              fit: BoxFit.cover)),
                    ),
                    title: Text(user.username),
                    subtitle: Text(
                      'a fait une demande pour ajouter un jeu',
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(10.0),
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: CachedNetworkImageProvider(
                                      gameNoVerified.imageUrl))),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text('Name'),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                gameNoVerified.name,
                              )
                            ],
                          ),
                        ),
                        Expanded(
                            child: Column(
                          children: [
                            Text('Categories'),
                            const SizedBox(
                              height: 5.0,
                            ),
                            ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: gameNoVerified.categories!.length,
                                itemBuilder: (_, int index) {
                                  String category =
                                      gameNoVerified.categories![index];
                                  return Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      category,
                                    ),
                                  );
                                })
                          ],
                        ))
                      ]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: SizedBox(
                  height: 70,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            ElevatedButton(
                                onPressed: () => validate(
                                    gameNoVerified.documentId!,
                                    gameNoVerified.imageUrl,
                                    gameNoVerified.categories!,
                                    user),
                                style: ElevatedButton.styleFrom(
                                    elevation: 6,
                                    primary: Colors.green[200],
                                    shape: CircleBorder(
                                        side: BorderSide(color: Colors.black))),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.black,
                                )),
                            const SizedBox(
                              width: 100.0,
                            ),
                            Text(
                              'Accepter',
                            )
                          ],
                        ),
                        Column(
                          children: [
                            ElevatedButton(
                                onPressed: () => decline(
                                    gameNoVerified.documentId!,
                                    gameNoVerified.imageUrl,
                                    gameNoVerified.categories!,
                                    user),
                                style: ElevatedButton.styleFrom(
                                    elevation: 6,
                                    primary: Colors.red,
                                    shape: CircleBorder(
                                        side: BorderSide(color: Colors.black))),
                                child: Icon(
                                  Icons.clear,
                                  color: Colors.black,
                                )),
                            Text(
                              'Refuser',
                            )
                          ],
                        )
                      ]),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
