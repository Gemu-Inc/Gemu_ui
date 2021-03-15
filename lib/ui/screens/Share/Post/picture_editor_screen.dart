import 'dart:io';
import 'dart:ui';

import 'package:Gemu/constants/variables.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:Gemu/models/game.dart';
import 'package:Gemu/constants/route_names.dart';

class PictureEditorScreen extends StatefulWidget {
  final File file;

  PictureEditorScreen({this.file});

  @override
  PictureEditorScreenState createState() => PictureEditorScreenState();
}

class PictureEditorScreenState extends State<PictureEditorScreen> {
  bool isUploading = false;
  bool isCaption = false;
  bool isHashtags = false;
  String choixGameId = "";
  String choixGameName = "";

  TextEditingController _captionController = TextEditingController();
  TextEditingController _hashtagsController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  uploadPictureToStorage(String imagePath, String id, String gameName) async {
    UploadTask storageUploadTask = FirebaseStorage.instance
        .ref()
        .child('posts')
        .child(gameName)
        .child('pictures')
        .child(id)
        .putFile(File(imagePath));
    TaskSnapshot storageTaskSnapshot =
        await storageUploadTask.whenComplete(() {});
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  uploadPicture(String imagePath, String gameId, String gameName) async {
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
          .doc(gameId)
          .collection(gameName)
          .where('uid', isEqualTo: currentUser)
          .get();
      int length = alldocs.docs.length;
      String picture = await uploadPictureToStorage(
          imagePath, "Picture$gameName$currentUser-$length", gameName);
      FirebaseFirestore.instance
          .collection('posts')
          .doc(gameId)
          .collection(gameName)
          .doc("Picture$gameName$currentUser-$length")
          .set({
        'uid': currentUser,
        'username': userdoc.data()['pseudo'],
        'profilepicture': userdoc.data()['photoURL'],
        'id': "Picture$gameName$currentUser-$length",
        'game': gameName,
        'up': [],
        'down': [],
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
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
          child: isUploading
              ? Stack(
                  children: [
                    Center(child: Image.file(widget.file)),
                    Center(
                        child: Container(
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
                    )),
                  ],
                )
              : Stack(
                  children: [
                    Center(child: Image.file(widget.file)),
                    Align(
                      alignment: Alignment.topCenter,
                      child: _topBar(),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _designBar(),
                    ),
                    AnimatedPositioned(
                        height: isCaption ? 50 : 25,
                        width: isCaption
                            ? MediaQuery.of(context).size.width / 2
                            : 100,
                        left: isCaption
                            ? MediaQuery.of(context).size.width / 4
                            : 10.0,
                        bottom: isCaption
                            ? MediaQuery.of(context).size.height / 2.0
                            : 50.0,
                        child: _caption(),
                        duration: Duration(milliseconds: 300)),
                    AnimatedPositioned(
                        height: isHashtags ? 50 : 25,
                        width: isHashtags
                            ? MediaQuery.of(context).size.width / 2
                            : 100,
                        left: isHashtags
                            ? MediaQuery.of(context).size.width / 4
                            : 10.0,
                        bottom: isHashtags
                            ? MediaQuery.of(context).size.height / 2.0
                            : 20.0,
                        child: _hashtags(),
                        duration: Duration(milliseconds: 300)),
                  ],
                )),
    );
  }

  Widget _caption() {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(10.0)),
      child: isCaption
          ? Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isCaption = !isCaption;
                      });
                    },
                    child: Icon(Icons.check),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 45,
                    width: MediaQuery.of(context).size.width / 3,
                    child: TextField(
                      controller: _captionController,
                      decoration: InputDecoration(
                        labelText: ' Write caption',
                        labelStyle: mystyle(11, Colors.white),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () => _captionController.clear(),
                    child: Icon(Icons.clear),
                  ),
                )
              ],
            )
          : GestureDetector(
              onTap: () {
                setState(() {
                  isCaption = !isCaption;
                  if (isHashtags == true) {
                    isHashtags = !isHashtags;
                  }
                });
              },
              child: Text(
                'Write caption',
                style: mystyle(11, Colors.white),
              ),
            ),
    );
  }

  Widget _hashtags() {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(10.0)),
      child: isHashtags
          ? Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isHashtags = !isHashtags;
                      });
                    },
                    child: Icon(Icons.check),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 45,
                    width: MediaQuery.of(context).size.width / 3,
                    child: TextField(
                      controller: _hashtagsController,
                      decoration: InputDecoration(
                        labelText: ' Write hashtags',
                        labelStyle: mystyle(11, Colors.white),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () => _hashtagsController.clear(),
                    child: Icon(Icons.clear),
                  ),
                )
              ],
            )
          : GestureDetector(
              onTap: () {
                setState(() {
                  isHashtags = !isHashtags;
                  if (isCaption == true) {
                    isCaption = !isCaption;
                  }
                });
              },
              child: Text(
                'Write hashtags',
                style: mystyle(11, Colors.white),
              ),
            ),
    );
  }

  Widget _designBar() {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      margin: EdgeInsets.only(right: 10.0),
      child: Column(
        children: [
          Expanded(
              child: GestureDetector(
            onTap: () async {
              File cropped = await ImageCropper.cropImage(
                  sourcePath: widget.file.path,
                  aspectRatioPresets: [
                    CropAspectRatioPreset.square,
                    CropAspectRatioPreset.ratio3x2,
                    CropAspectRatioPreset.original,
                    CropAspectRatioPreset.ratio4x3,
                    CropAspectRatioPreset.ratio16x9
                  ],
                  compressQuality: 100,
                  compressFormat: ImageCompressFormat.jpg,
                  maxHeight: 1080,
                  maxWidth: 1080,
                  androidUiSettings: AndroidUiSettings(
                      toolbarTitle: '',
                      initAspectRatio: CropAspectRatioPreset.original,
                      lockAspectRatio: false,
                      statusBarColor: Theme.of(context).scaffoldBackgroundColor,
                      toolbarColor: Theme.of(context).scaffoldBackgroundColor,
                      toolbarWidgetColor: Colors.grey,
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      activeControlsWidgetColor:
                          Theme.of(context).primaryColor));
              if (cropped != null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return PictureEditorScreen(
                    file: cropped,
                  );
                }));
              } else {
                Navigator.pop(context);
              }
            },
            child: Icon(
              Icons.crop,
              color: Colors.white,
            ),
          )),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.clear,
              color: Colors.white,
            ),
          ),
        ),
        GestureDetector(
          onTap: _chooseGame,
          child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(
                Icons.videogame_asset,
                color: Colors.white,
              )),
        ),
        Padding(
          padding: EdgeInsets.only(right: 10.0),
          child: GestureDetector(
            onTap: () {
              if (_captionController.text == null ||
                  _captionController.text == "" ||
                  choixGameId == null ||
                  choixGameId == "") {
                if (_captionController.text == null ||
                    _captionController.text == "") {
                  showInSnackBar('Write caption');
                }
                if (choixGameId == null || choixGameId == "") {
                  showInSnackBar('Choose game');
                }
              } else {
                uploadPicture(widget.file.path, choixGameId, choixGameName);
              }
            },
            child: Icon(
              Icons.save,
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }

  Future<void> _chooseGame() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).canvasColor,
            elevation: 6.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            title: Text('Choose game'),
            content: Builder(
              builder: (context) {
                var height = MediaQuery.of(context).size.height;

                return Container(
                  alignment: Alignment.center,
                  height: height - 400,
                  child: FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser.uid)
                          .get(),
                      builder: (context, snapshotGamesID) {
                        if (!snapshotGamesID.hasData) {
                          return CircularProgressIndicator();
                        }
                        return StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('games')
                              .where(FieldPath.documentId,
                                  whereIn: snapshotGamesID.data['idGames'])
                              .snapshots(),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasData) {
                              return Wrap(
                                children: snapshot.data.docs.map((snapshot) {
                                  Game game = Game.fromMap(
                                      snapshot.data(), snapshot.id);
                                  return Container(
                                      margin: EdgeInsets.only(
                                          bottom: 10.0, top: 10.0),
                                      width: 90,
                                      height: 85,
                                      child: Stack(
                                        children: [
                                          Align(
                                              alignment: Alignment.topCenter,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    choixGameId =
                                                        game.documentId;
                                                    choixGameName = game.name;
                                                  });
                                                  print(choixGameName);
                                                  print(choixGameId);
                                                },
                                                child: Container(
                                                  height: 60,
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
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
                                                          fit: BoxFit.cover,
                                                          image: CachedNetworkImageProvider(
                                                              game.imageUrl))),
                                                ),
                                              )),
                                          Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Text(game.name),
                                          )
                                        ],
                                      ));
                                }).toList(),
                              );
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          },
                        );
                      }),
                );
              },
            ),
            actions: [
              TextButton(
                child: Text(
                  'Cancel',
                  style: mystyle(11, Colors.red),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text(
                  'Ok',
                  style: mystyle(11, Colors.blue),
                ),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }
}
