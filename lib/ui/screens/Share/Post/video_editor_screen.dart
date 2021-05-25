import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
//import 'package:video_editor/video_editor.dart';
import 'package:helpers/helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_compress/video_compress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_player/video_player.dart';

import 'package:Gemu/constants/route_names.dart';
import 'package:Gemu/models/game.dart';
import 'package:Gemu/constants/variables.dart';

import 'crop_screen.dart';

class VideoEditorScreen extends StatefulWidget {
  final File? file;

  VideoEditorScreen({@required this.file});

  @override
  VideoEditorScreenState createState() => VideoEditorScreenState();
}

class VideoEditorScreenState extends State<VideoEditorScreen>
    with TickerProviderStateMixin {
  final double height = 60;

  int? durationVideo;

  bool _exported = false;
  bool isUploading = false;
  bool isCaption = false;
  bool isHashtags = false;
  String _exportText = "";
  String? choixGameName = "";
  String? choixGameId = "";
  String privacy = "Public";

  late VideoPlayerController _videoPlayerController;
  TextEditingController _captionController = TextEditingController();
  TextEditingController _hashtagsController = TextEditingController();
  FocusNode? _focusNodeCaption, _focusNodeHashtags;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late AnimationController animationController;
  late Animation degOneTranslationAnimation, degTwoTranslationAnimation;
  late Animation rotationAnimationCircularButton;
  late Animation rotationAnimationFlatButton;

  List<String> hashtagsSelected = [];
  List _allResults = [];
  List _resultList = [];

  Future? resultLoaded;

  String? id;
  int? postsCount;

  bool extendContainer = false;

  compressVideo(String videoPath) async {
    MediaInfo? compressedVideo = await VideoCompress.compressVideo(videoPath,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true);
    return File(compressedVideo!.path!);
  }

  getPreviewImage(String videoPath) async {
    final previewImagePath = await VideoThumbnail.thumbnailFile(
        video: videoPath, imageFormat: ImageFormat.JPEG, quality: 50);

    /*final lastIndex = previewImagePath?.lastIndexOf(RegExp(r'.jp'));
    final splitted = previewImagePath?.substring(0, lastIndex);
    final outPath = "${splitted}_out${previewImagePath?.substring(lastIndex!)}";
    File? compressImage = await FlutterImageCompress.compressAndGetFile(
        previewImagePath!, outPath);*/
    File? compressImage = File(previewImagePath!);

    return compressImage;
  }

  uploadVideoToStorage(String videoPath, String id, String nameGame) async {
    UploadTask storageUploadTask = FirebaseStorage.instance
        .ref()
        .child('posts')
        .child(nameGame)
        .child('videos')
        .child(id)
        .putFile(await compressVideo(videoPath));
    TaskSnapshot storageTaskSnapshot =
        await storageUploadTask.whenComplete(() {});
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  uploadImagePreviewToStorage(
      String videoPath, String id, String nameGame) async {
    UploadTask storageUploadTask = FirebaseStorage.instance
        .ref()
        .child('posts')
        .child(nameGame)
        .child('previewImage')
        .child(id)
        .putFile(await getPreviewImage(videoPath));
    TaskSnapshot storageTaskSnapshot =
        await storageUploadTask.whenComplete(() {});
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  uploadVideo(String videoPath, String? idGame, String? nameGame) async {
    setState(() {
      isUploading = true;
    });
    try {
      var currentUser = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot<Map<String, dynamic>> userdoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(currentUser)
          .get();
      var alldocs = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: currentUser)
          .get();
      int length = alldocs.docs.length;

      var doc = await FirebaseFirestore.instance
          .collection('posts')
          .doc('Video$currentUser-$length')
          .get();
      if (!doc.exists) {
        String video = await uploadVideoToStorage(
            videoPath, "Video$currentUser-$length", nameGame!);
        String previewImage = await uploadImagePreviewToStorage(
            videoPath, "Video$currentUser-$length", nameGame);
        FirebaseFirestore.instance
            .collection('posts')
            .doc("Video$currentUser-$length")
            .set({
          'uid': currentUser,
          'username': userdoc.data()!['pseudo'],
          'profilpicture': userdoc.data()!['photoURL'],
          'id': "Video$currentUser-$length",
          'game': nameGame,
          'up': [],
          'down': [],
          'commentcount': 0,
          'caption': _captionController.text,
          'hashtags': hashtagsSelected,
          'videoUrl': video,
          'previewImage': previewImage,
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
                  .doc(hashtagsSelected[i])
                  .set({
                'id': hashtagsSelected[i],
                'name': hashtagsSelected[i],
                'postsCount': 1
              });
              FirebaseFirestore.instance
                  .collection('hashtags')
                  .doc(hashtagsSelected[i])
                  .collection('posts')
                  .doc("Video$currentUser-$length")
                  .set({
                'uid': currentUser,
                'username': userdoc.data()!['pseudo'],
                'profilpicture': userdoc.data()!['photoURL'],
                'id': "Video$currentUser-$length",
                'game': nameGame,
                'up': [],
                'down': [],
                'commentcount': 0,
                'caption': _captionController.text,
                'hashtags': hashtagsSelected,
                'videoUrl': video,
                'previewImage': previewImage,
                'privacy': privacy,
                'viewcount': 0
              });
            } else {
              FirebaseFirestore.instance
                  .collection('hashtags')
                  .doc(id)
                  .update({'postsCount': postsCount! + 1});
              FirebaseFirestore.instance
                  .collection('hashtags')
                  .doc(id)
                  .collection('posts')
                  .doc("Video$currentUser-$length")
                  .set({
                'uid': currentUser,
                'username': userdoc.data()!['pseudo'],
                'profilpicture': userdoc.data()!['photoURL'],
                'id': "Video$currentUser-$length",
                'game': nameGame,
                'up': [],
                'down': [],
                'commentcount': 0,
                'caption': _captionController.text,
                'hashtags': hashtagsSelected,
                'videoUrl': video,
                'previewImage': previewImage,
                'privacy': privacy,
                'viewcount': 0
              });
            }
            if (hashtagsSelected.length > 1) {
              setState(() {
                hashtagsLength = hashtagsLength + 1;
              });
            }
          }
        }
      } else {
        setState(() {
          length = length + 1;
        });
        var doc = await FirebaseFirestore.instance
            .collection('posts')
            .doc('Video$currentUser-$length')
            .get();
        if (!doc.exists) {
          String video = await uploadVideoToStorage(
              videoPath, "Video$currentUser-$length", nameGame!);
          String previewImage = await uploadImagePreviewToStorage(
              videoPath, "Video$currentUser-$length", nameGame);
          FirebaseFirestore.instance
              .collection('posts')
              .doc("Video$currentUser-$length")
              .set({
            'uid': currentUser,
            'username': userdoc.data()!['pseudo'],
            'profilpicture': userdoc.data()!['photoURL'],
            'id': "Video$currentUser-$length",
            'game': nameGame,
            'up': [],
            'down': [],
            'commentcount': 0,
            'caption': _captionController.text,
            'hashtags': hashtagsSelected,
            'videoUrl': video,
            'previewImage': previewImage,
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
                    .doc(hashtagsSelected[i])
                    .set({
                  'id': hashtagsSelected[i],
                  'name': hashtagsSelected[i],
                  'postsCount': 1
                });
                FirebaseFirestore.instance
                    .collection('hashtags')
                    .doc(hashtagsSelected[i])
                    .collection('posts')
                    .doc("Video$currentUser-$length")
                    .set({
                  'uid': currentUser,
                  'username': userdoc.data()!['pseudo'],
                  'profilpicture': userdoc.data()!['photoURL'],
                  'id': "Video$currentUser-$length",
                  'game': nameGame,
                  'up': [],
                  'down': [],
                  'commentcount': 0,
                  'caption': _captionController.text,
                  'hashtags': hashtagsSelected,
                  'videoUrl': video,
                  'previewImage': previewImage,
                  'privacy': privacy,
                  'viewcount': 0
                });
              } else {
                FirebaseFirestore.instance
                    .collection('hashtags')
                    .doc(id)
                    .update({'postsCount': postsCount! + 1});
                FirebaseFirestore.instance
                    .collection('hashtags')
                    .doc(id)
                    .collection('posts')
                    .doc("Video$currentUser-$length")
                    .set({
                  'uid': currentUser,
                  'username': userdoc.data()!['pseudo'],
                  'profilpicture': userdoc.data()!['photoURL'],
                  'id': "Video$currentUser-$length",
                  'game': nameGame,
                  'up': [],
                  'down': [],
                  'commentcount': 0,
                  'caption': _captionController.text,
                  'hashtags': hashtagsSelected,
                  'videoUrl': video,
                  'previewImage': previewImage,
                  'privacy': privacy,
                  'viewcount': 0
                });
              }
              if (hashtagsSelected.length > 1) {
                setState(() {
                  hashtagsLength = hashtagsLength + 1;
                });
              }
            }
          }
        }
      }

      Navigator.pushNamedAndRemoveUntil(
          context, NavScreenRoute, (route) => false);
    } catch (e) {
      print(e);
    }
  }

  void _exportVideo() {
    final File file = widget.file!;
    uploadVideo(file.path, choixGameId, choixGameName);
  }

  /*void _openCropScren() {
    context.to(CropScreen(
      videoEditorController: _videoEditorController,
    ));
  }*/

  void showInSnackBar(String message) {
    _scaffoldKey.currentState!.showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).canvasColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          message,
          style: mystyle(12),
        )));
  }

  double getRadianFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.file(widget.file!)
      ..initialize().then((_) {
        setState(() {});
      });

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

    _hashtagsController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    resultLoaded = getHashtagsStreamSnapshots();
  }

  @override
  void dispose() async {
    if (mounted) {
      await _videoPlayerController.dispose();
    }
    _captionController.dispose();
    _hashtagsController.removeListener(_onSearchChanged);
    _hashtagsController.dispose();
    _focusNodeCaption!.dispose();
    _focusNodeHashtags!.dispose();
    animationController.dispose();
    animationController.removeListener(() {
      setState(() {});
    });
    super.dispose();
  }

  _onSearchChanged() {
    searchResultsListHashtags();
  }

  getHashtagsStreamSnapshots() async {
    var data = await FirebaseFirestore.instance.collection('hashtags').get();
    setState(() {
      _allResults = data.docs;
    });
    searchResultsListHashtags();
    return "complete";
  }

  searchResultsListHashtags() {
    var showResults = [];

    if (_hashtagsController.text != "") {
      for (var hashtagSnapshot in _allResults) {
        var name = hashtagSnapshot.data()['name'].toLowerCase();

        if (name.contains(_hashtagsController.text.toLowerCase())) {
          showResults.add(hashtagSnapshot);
        }
      }
    } else {
      showResults = List.from(_allResults);
    }
    setState(() {
      _resultList = showResults;
    });
  }

  @override
  Widget build(BuildContext contex) {
    return SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            key: _scaffoldKey,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: isUploading
                ? AnimatedBuilder(
                    animation: _videoPlayerController,
                    builder: (_, __) {
                      return Stack(
                        children: [
                          AspectRatio(
                            aspectRatio:
                                _videoPlayerController.value.aspectRatio,
                            child: VideoPlayer(_videoPlayerController),
                          ),
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
                      );
                    })
                : AnimatedBuilder(
                    animation: _videoPlayerController,
                    builder: (_, __) {
                      return isCaption || isHashtags
                          ? Stack(
                              children: [
                                Center(
                                  child: AspectRatio(
                                    aspectRatio: _videoPlayerController
                                        .value.aspectRatio,
                                    child: VideoPlayer(_videoPlayerController),
                                  ),
                                ),
                                isCaption ? _caption() : _hashtags()
                              ],
                            )
                          : Stack(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (_videoPlayerController
                                          .value.isPlaying) {
                                        _videoPlayerController.pause();
                                      } else {
                                        _videoPlayerController.play();
                                        _videoPlayerController.setLooping(true);
                                      }
                                    });
                                  },
                                  child: Center(
                                    child: AspectRatio(
                                      aspectRatio: _videoPlayerController
                                          .value.aspectRatio,
                                      child:
                                          VideoPlayer(_videoPlayerController),
                                    ),
                                  ),
                                ),
                                Center(
                                    child: OpacityTransition(
                                        visible: !_videoPlayerController
                                            .value.isPlaying,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _videoPlayerController.play();
                                              _videoPlayerController
                                                  .setLooping(true);
                                            });
                                          },
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                    color: Colors.black),
                                                shape: BoxShape.circle),
                                            child: Icon(
                                              _videoPlayerController
                                                      .value.isPlaying
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ))),
                                Align(
                                    alignment: Alignment.topCenter,
                                    child: _topBar()),
                                Positioned(
                                    bottom: 20, left: 10, child: _edit()),
                                Positioned(
                                    bottom: 20, right: 10, child: _save()),
                                _customSnackBar(),
                              ],
                            );
                    })));
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

  Widget _save() {
    return GestureDetector(
        onTap: () {
          if (_captionController.text == "" ||
              choixGameId == null ||
              choixGameId == "" ||
              /*durationVideo! > 10 ||*/
              hashtagsSelected.length == 0) {
            if (_captionController.text == "") {
              showInSnackBar('Write caption');
            }
            if (choixGameId == null || choixGameId == "") {
              showInSnackBar('Choose game');
            }
            if (hashtagsSelected.length == 0) {
              showInSnackBar('Choose hashtags');
            }
            if (durationVideo! > 10) {
              showInSnackBar('Maximum video seconds: 10');
            }
          } else {
            //print(durationVideo);
            _exportVideo();
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
    ;
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
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .get(),
                      builder: (context, AsyncSnapshot snapshotGamesID) {
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
                                children: snapshot.data!.docs.map((snapshot) {
                                  Game game = Game.fromMap(
                                      snapshot.data() as Map<String, dynamic>,
                                      snapshot.id);
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
                                                              game.imageUrl!))),
                                                ),
                                              )),
                                          Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Text(game.name!),
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

  Widget _privacy() {
    return InkWell(
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
          style: mystyle(11.0),
        ),
      ),
    );
  }

  Widget _designBar() {
    return AnimatedContainer(
        height: extendContainer ? 250 : 100,
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
              child: extendContainer
                  ? ListView(children: [
                      Container(
                        height: 75,
                        decoration: BoxDecoration(
                            border:
                                Border(bottom: BorderSide(color: Colors.grey))),
                        child: ListView(
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                print('Filtres');
                              },
                              child: Icon(Icons.filter),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                print('Musiques');
                              },
                              child: Icon(Icons.music_note),
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: 145,
                        child: ListView(
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                print('Trimmer');
                              },
                              child: Icon(Icons.video_settings),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                                onTap: () {
                                  print('Rotate right');
                                },
                                child: Icon(Icons.rotate_right)),
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                                onTap: () {
                                  print('Rotate left');
                                },
                                child: Icon(Icons.rotate_left)),
                            SizedBox(
                              height: 10.0,
                            ),
                            GestureDetector(
                                onTap: () {
                                  print('Crop');
                                },
                                child: Icon(Icons.crop))
                          ],
                        ),
                      )
                    ])
                  : Container(
                      height: 75,
                      child: ListView(
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              print('Filtres');
                            },
                            child: Icon(Icons.filter_rounded),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              print('Musiques');
                            },
                            child: Icon(Icons.music_note),
                          )
                        ],
                      ),
                    ),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      extendContainer = !extendContainer;
                    });
                  },
                  child: extendContainer
                      ? Icon(Icons.expand_less)
                      : Icon(Icons.expand_more),
                )),
          ],
        ));
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
                      _hashtagsController.clear();
                    });
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
              itemCount: _resultList.length,
              itemBuilder: (context, index) {
                return ListTile(
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
                      _resultList[index].data()['name'],
                      style: mystyle(12),
                    ),
                    trailing: Text(
                      '${_resultList[index].data()['postsCount']} publications',
                      style: mystyle(11, Colors.white.withOpacity(0.6)),
                    ),
                    onTap: () {
                      setState(() {
                        if (!hashtagsSelected
                            .contains(_resultList[index].data()['name'])) {
                          hashtagsSelected
                              .add(_resultList[index].data()['name']);
                          _hashtagsController.clear();
                        }
                      });
                    });
              },
            ),
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
                height: 50,
                width: 50,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.clear,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
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
              padding: EdgeInsets.only(right: 10.0),
              child: _designBar(),
            ),
          )
        ],
      ),
    );
  }

  Widget _customSnackBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SwipeTransition(
        visible: _exported,
        direction: SwipeDirection.fromBottom,
        child: Container(
          height: height,
          width: double.infinity,
          color: Colors.black.withOpacity(0.8),
          child: Center(
            child: TextDesigned(
              _exportText,
              color: Colors.white,
              bold: true,
            ),
          ),
        ),
      ),
    );
  }
}
