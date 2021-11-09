import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/ui/widgets/app_bar_custom.dart';

class PanelSupportScreen extends StatefulWidget {
  @override
  PanelSupportScreenState createState() => PanelSupportScreenState();
}

class PanelSupportScreenState extends State<PanelSupportScreen> {
  validate(String idGame, String imageUrl, List gameCategories) async {
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

    print('success');
  }

  decline(String idGame, String imageUrl, List gameCategories) async {
    await FirebaseStorage.instance.refFromURL(imageUrl).delete();
    await FirebaseFirestore.instance
        .collection('games')
        .doc('not_verified')
        .collection('games_not_verified')
        .doc(idGame)
        .delete();

    print('success');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBarCustom(
        context: context,
        title: 'Panel support',
        actions: [],
      ),
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width / 1.1,
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('games')
                .doc('not_verified')
                .collection('games_not_verified')
                .orderBy('name')
                .snapshots(),
            builder: (_, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                );
              }
              if (snapshot.data.docs.length == 0) {
                return Center(
                  child: Text(
                    'Aucunes demandes récentes',
                    style: mystyle(12),
                  ),
                );
              }
              return ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (_, int index) {
                    Game gameNoVerified = Game.fromMap(
                        snapshot.data.docs[index],
                        snapshot.data.docs[index].data());
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Container(
                        height: MediaQuery.of(context).size.height / 6,
                        decoration: BoxDecoration(
                            color: Theme.of(context).canvasColor,
                            border: Border.all(color: Colors.black),
                            boxShadow: [
                              BoxShadow(
                                  color: Theme.of(context).shadowColor,
                                  blurRadius: 3,
                                  spreadRadius: 3)
                            ]),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5.0),
                                    child: Container(
                                      height: 60,
                                      width: 60,
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black),
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: CachedNetworkImageProvider(
                                                  gameNoVerified.imageUrl))),
                                    )),
                                Expanded(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(left: 5.0, top: 5.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: Text('Name'),
                                        ),
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10.0,
                                                vertical: 10.0),
                                            child: Text(
                                              gameNoVerified.name,
                                              style: mystyle(14),
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: Text('Categories'),
                                        ),
                                        Expanded(
                                          child: ListView.builder(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10.0,
                                                  vertical: 10.0),
                                              scrollDirection: Axis.vertical,
                                              shrinkWrap: true,
                                              itemCount: gameNoVerified
                                                  .categories!.length,
                                              itemBuilder: (_, int index) {
                                                String category = gameNoVerified
                                                    .categories![index];
                                                return Text(
                                                  category,
                                                  style: mystyle(14),
                                                );
                                              }),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )),
                            Container(
                              width: MediaQuery.of(context).size.width / 2.5,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  GestureDetector(
                                    onTap: () => validate(
                                        gameNoVerified.documentId!,
                                        gameNoVerified.imageUrl,
                                        gameNoVerified.categories!),
                                    child: Container(
                                      height: 45,
                                      width: 45,
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black),
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Theme.of(context)
                                                    .primaryColor
                                                    .withOpacity(0.7),
                                                Theme.of(context)
                                                    .accentColor
                                                    .withOpacity(0.7)
                                              ])),
                                      child: Icon(Icons.check),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => decline(
                                        gameNoVerified.documentId!,
                                        gameNoVerified.imageUrl,
                                        gameNoVerified.categories!),
                                    child: Container(
                                      height: 45,
                                      width: 45,
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black),
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Theme.of(context)
                                                    .primaryColor
                                                    .withOpacity(0.7),
                                                Theme.of(context)
                                                    .accentColor
                                                    .withOpacity(0.7)
                                              ])),
                                      child: Icon(Icons.clear),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  });
            },
          ),
        ),
      ),
    );
  }
}
