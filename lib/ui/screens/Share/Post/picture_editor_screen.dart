import 'dart:io';
import 'dart:ui';
import 'dart:async';

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

class PictureEditorScreenState extends State<PictureEditorScreen>
    with TickerProviderStateMixin {
  bool isUploading = false;
  bool isCaption = false;
  bool isHashtags = false;
  String choixGameId = "";
  String choixGameName = "";
  String privacy = "Public";

  TextEditingController _captionController = TextEditingController();
  TextEditingController _hashtagsController = TextEditingController();

  FocusNode _focusNodeCaption, _focusNodeHashtags;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  AnimationController animationController;
  Animation degOneTranslationAnimation, degTwoTranslationAnimation;
  Animation rotationAnimationCircularButton;
  Animation rotationAnimationFlatButton;

  List<String> hashtagsSelected = [];
  List<String> hashtagsListTest = [
    'Test1',
    'Test2',
    'Expérience 1',
    'Expérience 2',
    'Expérience 3',
    'Expérience 4',
    'Expérience 5',
    'Expérience 6',
    'Expérience 7',
    'Expérience 8'
  ];
  List<String> hastagsListNbPostsTest = [
    '2 000',
    '2',
    '30 000',
    '45',
    '45',
    '45',
    '45',
    '45',
    '45',
    '45'
  ];

  String id;
  int postsCount;

  bool expandContainer = false;

  @override
  void initState() {
    super.initState();
    _focusNodeCaption = FocusNode();
    _focusNodeHashtags = FocusNode();

    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 350));
    degOneTranslationAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 1.2), weight: 75.0),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.2, end: 1.0), weight: 25.0),
    ]).animate(animationController);
    degTwoTranslationAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 1.75), weight: 35.0),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.75, end: 1.0), weight: 35.0),
    ]).animate(animationController);
    rotationAnimationCircularButton = Tween<double>(begin: 180.0, end: 0.0)
        .animate(CurvedAnimation(
            parent: animationController, curve: Curves.easeOut));
    rotationAnimationFlatButton = Tween<double>(begin: 360.0, end: 0.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOut));
    animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _captionController.dispose();
    _hashtagsController.dispose();
    _focusNodeCaption.dispose();
    _focusNodeHashtags.dispose();
    animationController.dispose();
    super.dispose();
  }

  double getRadianFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  void logError(String code, String message) =>
      print('Error: $code\nError Message: $message');

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
          .where('uid', isEqualTo: currentUser)
          .get();
      int length = alldocs.docs.length;
      String picture = await uploadPictureToStorage(
          imagePath, "Picture$currentUser-$length", gameName);
      FirebaseFirestore.instance
          .collection('posts')
          .doc("Picture$currentUser-$length")
          .set({
        'uid': currentUser,
        'username': userdoc.data()['pseudo'],
        'profilepicture': userdoc.data()['photoURL'],
        'id': "Picture$currentUser-$length",
        'game': gameName,
        'up': [],
        'down': [],
        'commentcount': 0,
        'caption': _captionController.text,
        'hashtags': hashtagsSelected,
        'pictureUrl': picture,
        'privacy': privacy,
        'viewcount': 0
      });

      if (hashtagsSelected.length != 0) {
        var hashtagdocs =
            await FirebaseFirestore.instance.collection('hashtags').get();
        int hashtagsLength = hashtagdocs.docs.length;

        for (int i = 0; i < hashtagsSelected.length; i++) {
          var docHashtags = await FirebaseFirestore.instance
              .collection('hashtags')
              .where('name', isEqualTo: hashtagsSelected[i])
              .get();
          for (var item in docHashtags.docs) {
            id = item.data()['id'];
            postsCount = item.data()['postsCount'];
          }
          if (docHashtags.docs.isEmpty) {
            FirebaseFirestore.instance
                .collection('hashtags')
                .doc('Hashtag$hashtagsLength')
                .set({
              'id': 'Hashtag$hashtagsLength',
              'name': hashtagsSelected[i],
              'postsCount': 1
            });
            FirebaseFirestore.instance
                .collection('hashtags')
                .doc('Hashtag$hashtagsLength')
                .collection('posts')
                .doc("Picture$currentUser-$length")
                .set({});
          } else {
            FirebaseFirestore.instance
                .collection('hashtags')
                .doc(id)
                .update({'postsCount': postsCount + 1});
            FirebaseFirestore.instance
                .collection('hashtags')
                .doc(id)
                .collection('posts')
                .doc("Picture$currentUser-$length")
                .set({});
          }
          if (hashtagsSelected.length > 1) {
            setState(() {
              hashtagsLength = hashtagsLength + 1;
            });
          }
        }
      }

      Navigator.pushNamedAndRemoveUntil(
          context, NavScreenRoute, (route) => false);
    } catch (e) {
      print(e);
    }
  }

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).canvasColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          message,
          style: mystyle(12),
        )));
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
                    color: Theme.of(context)
                        .scaffoldBackgroundColor
                        .withOpacity(0.7),
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
            : isCaption || isHashtags
                ? Stack(
                    children: [
                      Center(child: Image.file(widget.file)),
                      isCaption ? _caption() : _hashtags(),
                    ],
                  )
                : Stack(
                    children: [
                      Center(child: Image.file(widget.file)),
                      Align(alignment: Alignment.topCenter, child: _topBar()),
                      Positioned(bottom: 20, left: 10, child: _edit()),
                      Positioned(
                        bottom: 20,
                        right: 10,
                        child: _save(),
                      )
                    ],
                  ),
      ),
    );
  }

  Widget _privacy() {
    return GestureDetector(
      onTap: () {
        if (privacy == "Public") {
          setState(() {
            privacy = "Private";
          });
        } else if (privacy == "Private") {
          setState(() {
            privacy = "Public";
          });
        }
      },
      child: Container(
        height: 25,
        width: MediaQuery.of(context).size.width / 4,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.3),
                  Theme.of(context).accentColor.withOpacity(0.3)
                ]),
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(10.0)),
        child: Text(
          privacy,
          style: mystyle(11),
        ),
      ),
    );
  }

  Widget _edit() {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        IgnorePointer(
            child: Container(
          height: 115,
          width: 130,
        )),
        Transform.translate(
          offset: Offset.fromDirection(
              getRadianFromDegree(300), degOneTranslationAnimation.value * 75),
          child: Transform(
              transform: Matrix4.rotationZ(
                  getRadianFromDegree(rotationAnimationCircularButton.value))
                ..scale(degOneTranslationAnimation.value),
              alignment: Alignment.center,
              child: GestureDetector(
                  child: Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Theme.of(context).primaryColor),
                    child: Icon(
                      Icons.closed_caption,
                      size: 25,
                    ),
                  ),
                  onTap: () {
                    animationController.reverse();
                    setState(() {
                      isCaption = !isCaption;
                    });
                  })),
        ),
        Transform.translate(
          offset: Offset.fromDirection(
              getRadianFromDegree(360), degTwoTranslationAnimation.value * 75),
          child: Transform(
              transform: Matrix4.rotationZ(
                  getRadianFromDegree(rotationAnimationCircularButton.value))
                ..scale(degTwoTranslationAnimation.value),
              alignment: Alignment.center,
              child: GestureDetector(
                  child: Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Theme.of(context).accentColor),
                    child: Icon(
                      Icons.tag,
                      size: 25,
                    ),
                  ),
                  onTap: () {
                    animationController.reverse();
                    setState(() {
                      isHashtags = !isHashtags;
                    });
                  })),
        ),
        Transform(
          transform: Matrix4.rotationZ(
              getRadianFromDegree(rotationAnimationFlatButton.value)),
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {
              if (animationController.isCompleted) {
                animationController.reverse();
              } else {
                animationController.forward();
                Timer(Duration(seconds: 6), () {
                  if (animationController.isCompleted) {
                    animationController.reverse();
                    print('Timer over');
                  }
                });
              }
            },
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).accentColor
                      ])),
              child: Icon(Icons.edit),
            ),
          ),
        ),
      ],
    );
  }

  Widget _caption() {
    return Container(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isCaption = !isCaption;
                            _captionController.clear();
                          });
                        },
                        child: Icon(
                          Icons.clear,
                        ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(right: 10.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isCaption = !isCaption;
                            });
                          },
                          child: Icon(Icons.check),
                        ))
                  ],
                ),
              ),
            ),
            Center(
                child: TextField(
              controller: _captionController,
              focusNode: _focusNodeCaption,
              autofocus: true,
              minLines: 1,
              maxLines: 15,
              decoration: InputDecoration(border: OutlineInputBorder()),
            )),
          ],
        ));
  }

  Widget _hashtags() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isHashtags = !isHashtags;
                        _hashtagsController.clear();
                      });
                    },
                    child: Icon(
                      Icons.clear,
                    ),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isHashtags = !isHashtags;
                        });
                      },
                      child: Icon(Icons.check),
                    ))
              ],
            ),
          ),
          TextField(
            controller: _hashtagsController,
            focusNode: _focusNodeHashtags,
            autofocus: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              suffixIcon: InkWell(
                onTap: () {
                  if (!hashtagsSelected
                      .contains(_hashtagsController.text.toLowerCase())) {
                    setState(() {
                      hashtagsSelected.add(_hashtagsController.text);
                    });
                    _hashtagsController.clear();
                  } else {
                    _hashtagsController.clear();
                  }
                },
                child: Icon(Icons.add),
              ),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          hashtagsSelected.length < 1
              ? Container(
                  height: 50,
                  decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).accentColor)),
                  child: Center(
                    child: Text('Pas encore d\'hashtags'),
                  ),
                )
              : Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).accentColor)),
                  child: Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: hashtagsSelected.map((hashtag) {
                          return Chip(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            label: Text('#$hashtag', style: mystyle(11)),
                            onDeleted: () {
                              setState(() {
                                hashtagsSelected.remove(hashtag);
                              });
                            },
                          );
                        }).toList()),
                  )),
          SizedBox(
            height: 10.0,
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: hashtagsListTest.length,
              itemBuilder: (context, index) {
                return hashtagsListTest[index]
                        .toLowerCase()
                        .contains(_hashtagsController.text.toLowerCase())
                    ? ListTile(
                        leading: Container(
                            alignment: Alignment.center,
                            height: 25,
                            width: 25,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Theme.of(context).primaryColor,
                                      Theme.of(context).accentColor
                                    ])),
                            child: Icon(Icons.tag, size: 15)),
                        title: Text(
                          hashtagsListTest[index],
                          style: mystyle(12),
                        ),
                        trailing: Text(
                          '${hastagsListNbPostsTest[index]} publications',
                          style: mystyle(11, Colors.white.withOpacity(0.6)),
                        ),
                        onTap: () {
                          setState(() {
                            if (!hashtagsSelected
                                .contains(hashtagsListTest[index])) {
                              hashtagsSelected.add(hashtagsListTest[index]);
                              _hashtagsController.clear();
                            }
                          });
                        })
                    : null;
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _designBar() {
    return AnimatedContainer(
      height: expandContainer ? 150 : 90,
      width: 45,
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.3),
                Theme.of(context).accentColor.withOpacity(0.3)
              ])),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ListView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: 10.0,
                ),
                GestureDetector(
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
                            statusBarColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            toolbarColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            toolbarWidgetColor: Colors.grey,
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            activeControlsWidgetColor:
                                Theme.of(context).primaryColor));
                    if (cropped != null) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return PictureEditorScreen(
                          file: cropped,
                        );
                      }));
                    } else {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return PictureEditorScreen(
                          file: widget.file,
                        );
                      }));
                    }
                  },
                  child: Icon(
                    Icons.crop,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
                onTap: () {
                  setState(() {
                    expandContainer = !expandContainer;
                  });
                },
                child: Icon(Icons.expand_more)),
          )
        ],
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Container(
                  alignment: Alignment.topLeft,
                  width: 50,
                  height: 50,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.clear,
                      color: Colors.white,
                    ),
                  ),
                )),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 85,
              child: Column(
                children: [
                  _privacy(),
                  SizedBox(
                    height: 10.0,
                  ),
                  _game()
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
                padding: EdgeInsets.only(right: 10.0), child: _designBar()),
          )
        ],
      ),
    );
  }

  Widget _save() {
    return GestureDetector(
        onTap: () {
          if (_captionController.text == null ||
              _captionController.text == "" ||
              choixGameId == null ||
              choixGameId == "" ||
              hashtagsSelected.length == 0) {
            if (_captionController.text == null ||
                _captionController.text == "") {
              showInSnackBar('Write caption');
            }
            if (choixGameId == null || choixGameId == "") {
              showInSnackBar('Choose game');
            }
            if (hashtagsSelected.length == 0) {
              showInSnackBar('Choose hashtags');
            }
          } else {
            uploadPicture(widget.file.path, choixGameId, choixGameName);
          }
        },
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            shape: BoxShape.circle,
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).accentColor
                ]),
          ),
          child: Icon(
            Icons.save,
            color: Colors.white,
          ),
        ));
  }

  Widget _game() {
    return GestureDetector(
      onTap: _chooseGame,
      child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.3),
                    Theme.of(context).accentColor.withOpacity(0.3)
                  ]),
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(
            Icons.videogame_asset,
            color: Colors.white,
          )),
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
