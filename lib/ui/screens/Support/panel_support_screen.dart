import 'package:Gemu/constants/variables.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PanelSupportScreen extends StatefulWidget {
  @override
  PanelSupportScreenState createState() => PanelSupportScreenState();
}

class PanelSupportScreenState extends State<PanelSupportScreen> {
  validate(String idGame) async {
    await FirebaseFirestore.instance
        .collection('games')
        .doc(idGame)
        .update({'verified': true});

    print('success');
  }

  decline(String idGame, String imageUrl, List gameCategories) async {
    await FirebaseStorage.instance.refFromURL(imageUrl).delete();

    for (var i = 0; i < gameCategories.length; i++) {
      var data = await FirebaseFirestore.instance
          .collection('categories')
          .where('name', isEqualTo: gameCategories[i])
          .get();

      for (var item in data.docs) {
        await FirebaseFirestore.instance
            .collection('categories')
            .doc(item.id)
            .collection('games')
            .doc(idGame)
            .delete();
      }
    }
    await FirebaseFirestore.instance.collection('games').doc(idGame).delete();

    print('success');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 6,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).accentColor
              ])),
        ),
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios)),
        title: Text(
          'Panel support',
          style: mystyle(15),
        ),
      ),
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width / 1.1,
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('games')
                .where('verified', isEqualTo: false)
                .orderBy('name')
                .snapshots(),
            builder: (_, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.data.docs.length == 0) {
                return Center(
                  child: Text(
                    'Pas de demande d\'ajout de jeu',
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
                    DocumentSnapshot<Map<String, dynamic>> gameNoVerified =
                        snapshot.data.docs[index];
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
                                                  gameNoVerified
                                                      .data()!['imageUrl']))),
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
                                              gameNoVerified.data()!['name'],
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
                                                  .data()!['categories']
                                                  .length,
                                              itemBuilder: (_, int index) {
                                                String category = gameNoVerified
                                                        .data()!['categories']
                                                    [index];
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
                                    onTap: () => validate(gameNoVerified.id),
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
                                        gameNoVerified.id,
                                        gameNoVerified.data()!['imageUrl'],
                                        gameNoVerified.data()!['categories']),
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
