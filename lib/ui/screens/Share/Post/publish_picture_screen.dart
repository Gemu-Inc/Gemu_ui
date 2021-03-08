import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:Gemu/constants/variables.dart';
import 'package:Gemu/constants/route_names.dart';
import 'package:Gemu/models/game.dart';

class PublishPictureScreen extends StatefulWidget {
  final String imagePath;

  PublishPictureScreen({this.imagePath});

  @override
  PublishPictureScreenState createState() => PublishPictureScreenState();
}

class PublishPictureScreenState extends State<PublishPictureScreen>
    with TickerProviderStateMixin {
  TextEditingController _captionController = TextEditingController();

  bool isUploading = false;
  String choixGameName, choixGameId;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  AnimationController _animationCaptionController, _animationGameController;
  Animation _animationCaption, _animationGame;

  uploadPictureToStorage(String id, String gameName) async {
    UploadTask storageUploadTask = FirebaseStorage.instance
        .ref()
        .child('posts')
        .child(gameName)
        .child('pictures')
        .child(id)
        .putFile(File(widget.imagePath));
    TaskSnapshot storageTaskSnapshot =
        await storageUploadTask.whenComplete(() {});
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  uploadPicture(String gameId, String gameName) async {
    setState(() {
      isUploading = true;
    });
    try {
      var currentUser = FirebaseAuth.instance.currentUser.uid;
      DocumentSnapshot userdoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser)
          .get();
      var alldocs = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: currentUser)
          .get();
      int length = alldocs.docs.length;
      String picture =
          await uploadPictureToStorage("Picture$currentUser-$length", gameName);
      FirebaseFirestore.instance
          .collection('posts')
          .doc(gameId)
          .collection(gameName)
          .doc("Picture$currentUser-$length")
          .set({
        'username': userdoc.data()['pseudo'],
        'uid': currentUser,
        'id': "Picture$currentUser-$length",
        'game': gameName,
        'likes': [],
        'commentcount': 0,
        'caption': _captionController.text,
        'pictureUrl': picture,
      });
      Navigator.pushNamedAndRemoveUntil(
          context, NavScreenRoute, (route) => false);
    } catch (e) {
      print(e);
    }
  }

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    super.initState();
    _animationCaptionController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animationGameController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    _animationCaption = CurvedAnimation(
        parent: _animationCaptionController, curve: Curves.easeInCubic);
    _animationGame = CurvedAnimation(
        parent: _animationGameController, curve: Curves.easeInCubic);
  }

  @override
  void dispose() {
    _animationCaptionController.dispose();
    _animationGameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: isUploading
          ? Stack(
              children: [
                SizedBox.expand(
                  child: FittedBox(
                      fit: BoxFit.contain,
                      child: Image.file(File(widget.imagePath))),
                ),
                Container(
                  color: Colors.grey.withOpacity(0.5),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Uploading..',
                          style: mystyle(18),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        CircularProgressIndicator()
                      ],
                    ),
                  ),
                )
              ],
            )
          : Stack(
              children: [
                SizedBox.expand(
                  child: FittedBox(
                      fit: BoxFit.contain,
                      child: GestureDetector(
                          onTap: () {
                            if (_animationCaptionController.isCompleted) {
                              _animationCaptionController.reverse();
                            }
                            if (_animationGameController.isCompleted) {
                              _animationGameController.reverse();
                            }
                          },
                          child: Image.file(
                            File(widget.imagePath),
                          ))),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () => Navigator.pop(context))),
                ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 75),
                      child: SizeTransition(
                        sizeFactor: _animationCaption,
                        child: ClipRect(
                          child: Container(
                            color: Theme.of(context).canvasColor,
                            child: TextField(
                              controller: _captionController,
                              decoration: InputDecoration(
                                labelText: ' Caption ...',
                                labelStyle: mystyle(15),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 75),
                    child: SizeTransition(
                      sizeFactor: _animationGame,
                      child: ClipRect(
                          child: Container(
                              height: 125,
                              color: Theme.of(context).canvasColor,
                              child: FutureBuilder(
                                  future: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(_firebaseAuth.currentUser.uid)
                                      .get(),
                                  builder: (context, snapshotGamesID) {
                                    if (!snapshotGamesID.hasData) {
                                      return CircularProgressIndicator();
                                    }
                                    return StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection('games')
                                          .where(FieldPath.documentId,
                                              whereIn: snapshotGamesID
                                                  .data['idGames'])
                                          .snapshots(),
                                      builder: (context,
                                          AsyncSnapshot<QuerySnapshot>
                                              snapshot) {
                                        if (snapshot.hasData) {
                                          return ListView(
                                            scrollDirection: Axis.horizontal,
                                            children: snapshot.data.docs
                                                .map((snapshot) {
                                              Game game = Game.fromMap(
                                                  snapshot.data(), snapshot.id);
                                              return Container(
                                                  margin: EdgeInsets.all(10.0),
                                                  width: 100,
                                                  child: Stack(
                                                    children: [
                                                      Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              choixGameId = game
                                                                  .documentId;
                                                              choixGameName =
                                                                  game.name;
                                                            });
                                                            _animationGameController
                                                                .reverse();
                                                            print(choixGameId);
                                                            print(
                                                                choixGameName);
                                                          },
                                                          child: Container(
                                                              margin:
                                                                  EdgeInsets.fromLTRB(
                                                                      11.0,
                                                                      11.0,
                                                                      11.0,
                                                                      11.0),
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
                                                                      BorderRadius.circular(
                                                                          10),
                                                                  image: DecorationImage(
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      image: CachedNetworkImageProvider(game.imageUrl)))),
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment: Alignment
                                                            .bottomCenter,
                                                        child: Text(
                                                          '${game.name}',
                                                        ),
                                                      )
                                                    ],
                                                  ));
                                            }).toList(),
                                          );
                                        } else {
                                          return Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                      },
                                    );
                                  }))),
                    ),
                  ),
                ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (_animationCaptionController.isCompleted) {
                              _animationCaptionController.reverse();
                            } else {
                              if (_animationGameController.isCompleted) {
                                _animationGameController.reverse();
                              }
                              _animationCaptionController.forward();
                            }
                          },
                          child: Container(
                              margin: EdgeInsets.only(bottom: 5.0, left: 5.0),
                              width: MediaQuery.of(context).size.width / 6,
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white60)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(Icons.closed_caption),
                                  Text(
                                    '...',
                                    style: mystyle(15, Colors.white60),
                                  )
                                ],
                              )),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (_animationGameController.isCompleted) {
                              _animationGameController.reverse();
                            } else {
                              if (_animationCaptionController.isCompleted) {
                                _animationCaptionController.reverse();
                              }
                              _animationGameController.forward();
                            }
                          },
                          child: Container(
                              margin: EdgeInsets.only(bottom: 5.0, left: 5.0),
                              width: MediaQuery.of(context).size.width / 6,
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white60)),
                              alignment: Alignment.center,
                              child: Text(
                                'Game',
                                style: mystyle(15, Colors.white60),
                              )),
                        ),
                        InkWell(
                          onTap: () {
                            if ((_captionController.text == null ||
                                    _captionController.text == '') ||
                                (choixGameName == null ||
                                    choixGameName == '')) {
                              print(_captionController.text);
                              print(choixGameId);
                              print(choixGameName);

                              showInSnackBar('Caption or Game is null');
                            } else {
                              if (_animationCaptionController.isCompleted) {
                                _animationCaptionController.reverse();
                              }
                              if (_animationGameController.isCompleted) {
                                _animationGameController.reverse();
                              }
                              print(_captionController.text);
                              print(choixGameName);
                              uploadPicture(choixGameId, choixGameName);
                            }
                          },
                          child: Container(
                              margin: EdgeInsets.only(bottom: 5.0, right: 5.0),
                              height: 40,
                              width: 60,
                              decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(5.0)),
                              child: Icon(Icons.send)),
                        )
                      ],
                    ))
              ],
            ),
    );
  }
}
