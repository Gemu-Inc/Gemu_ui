import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_compress/video_compress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_player/video_player.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:timeago/timeago.dart' as time;

import 'package:Gemu/constants/route_names.dart';
import 'package:Gemu/constants/variables.dart';
import 'package:Gemu/ui/screens/Navigation/nav_screen.dart';

class VideoScreen extends StatefulWidget {
  final File file;
  final bool public;
  final String nameGame, imageGame;
  final String caption;
  final List<String> hashtags;
  final List followsGames;
  VideoScreen(
      {required this.file,
      required this.public,
      required this.nameGame,
      required this.imageGame,
      required this.caption,
      required this.hashtags,
      required this.followsGames});
  @override
  VideoScreenState createState() => VideoScreenState();
}

class VideoScreenState extends State<VideoScreen>
    with TickerProviderStateMixin {
  final double height = 60;

  int? durationVideo;

  bool isUploading = false;
  bool isCaption = false;
  bool isHashtags = false;
  bool isGame = false;

  late VideoPlayerController _videoPlayerController;
  late TextEditingController _captionController;
  late TextEditingController _hashtagsController;
  late FocusNode _focusNodeCaption, _focusNodeHashtags;

  late String saveCaption;
  late bool public;
  late String gameName, gameImage;

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
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        quality: 50,
        timeMs: 1000);

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

  uploadVideo(String videoPath, String nameGame) async {
    setState(() {
      isUploading = true;
    });
    try {
      String privacy;
      if (public == true) {
        privacy = 'Public';
      } else {
        privacy = 'Private';
      }

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
            videoPath, "Video$currentUser-$length", nameGame);
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
          'viewcount': 0,
          'time': DateTime.now()
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
                'viewcount': 0,
                'time': DateTime.now()
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
                'viewcount': 0,
                'time': DateTime.now()
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
              videoPath, "Video$currentUser-$length", nameGame);
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
            'viewcount': 0,
            'time': DateTime.now()
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
                  'viewcount': 0,
                  'time': DateTime.now()
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
                  'viewcount': 0,
                  'time': DateTime.now()
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

  void showInSnackBar(String message) {
    ScaffoldMessenger(
        child: SnackBar(
            backgroundColor: Theme.of(context).canvasColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
    _videoPlayerController = VideoPlayerController.file(widget.file);
    _videoPlayerController.initialize();
    _videoPlayerController.setLooping(true);
    _videoPlayerController.play();

    saveCaption = widget.caption;
    _captionController = TextEditingController(text: saveCaption);
    _hashtagsController = TextEditingController();
    _focusNodeCaption = FocusNode();
    _focusNodeHashtags = FocusNode();

    gameName = widget.nameGame;
    gameImage = widget.imageGame;
    hashtagsSelected = widget.hashtags;

    public = widget.public;

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
    _focusNodeCaption.dispose();
    _focusNodeHashtags.dispose();
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
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: isUploading || isCaption || isHashtags || isGame
                ? AnimatedBuilder(
                    animation: _videoPlayerController,
                    builder: (_, __) {
                      return Stack(
                        children: [
                          Center(
                              child: AspectRatio(
                            aspectRatio:
                                _videoPlayerController.value.aspectRatio,
                            child: VideoPlayer(_videoPlayerController),
                          )),
                          isUploading
                              ? Center(
                                  child: Container(
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor
                                      .withOpacity(0.7),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                ))
                              : SizedBox(),
                        ],
                      );
                    })
                : AnimatedBuilder(
                    animation: _videoPlayerController,
                    builder: (_, __) {
                      return Stack(
                        children: [
                          Center(
                            child: AspectRatio(
                              aspectRatio:
                                  _videoPlayerController.value.aspectRatio,
                              child: VideoPlayer(_videoPlayerController),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 10.0, top: 10.0),
                              child: IconButton(
                                  onPressed: () async {
                                    await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            backgroundColor: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            title: Text('Abandon'),
                                            content: Text(
                                                'Voulez-vous abandonner la création de ce post?'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pushAndRemoveUntil(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                NavScreen()),
                                                        (route) => false);
                                                  },
                                                  child: Text('Oui')),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(
                                                    context,
                                                  ).pop(false);
                                                },
                                                child: Text(
                                                  'Non',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              )
                                            ],
                                          );
                                        });
                                  },
                                  icon: Icon(Icons.clear)),
                            ),
                          ),
                          Positioned(
                              right: 10.0, top: 10.0, child: _designBar()),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding:
                                  EdgeInsets.only(right: 10.0, bottom: 10.0),
                              child: _save(),
                            ),
                          ),
                          //_customSnackBar(),
                        ],
                      );
                    })));
  }

  Widget _save() {
    return GestureDetector(
        onTap: () {
          File file = widget.file;
          uploadVideo(file.path, gameName);
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
                  Theme.of(context).primaryColor.withOpacity(0.7),
                  Theme.of(context).accentColor.withOpacity(0.7)
                ]),
          ),
          child: Icon(
            Icons.save,
            color: Colors.white,
          ),
        ));
  }

  Widget _designBar() {
    return AnimatedContainer(
        height: extendContainer ? 385 : 165,
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
                        height: 150,
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
                                setState(() {
                                  public = !public;
                                });
                              },
                              child: Icon(
                                public ? Icons.lock_open : Icons.lock_outline,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isGame = !isGame;
                                });
                                _game();
                              },
                              child: Icon(
                                Icons.videogame_asset,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isCaption = !isCaption;
                                });
                                _caption();
                              },
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isHashtags = !isHashtags;
                                });
                                _hashtags();
                              },
                              child: Icon(
                                Icons.tag,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: 220,
                        child: ListView(
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: 10.0,
                            ),
                            GestureDetector(
                              onTap: () {
                                print('Filtres');
                              },
                              child: Icon(
                                Icons.filter,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                print('Musiques');
                              },
                              child: Icon(
                                Icons.music_note,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            GestureDetector(
                              onTap: () {
                                print('Trimmer');
                              },
                              child: Icon(
                                Icons.video_settings,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                                onTap: () {
                                  print('Rotate right');
                                },
                                child: Icon(
                                  Icons.rotate_right,
                                  color: Colors.white,
                                )),
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                                onTap: () {
                                  print('Rotate left');
                                },
                                child: Icon(
                                  Icons.rotate_left,
                                  color: Colors.white,
                                )),
                            SizedBox(
                              height: 10.0,
                            ),
                            GestureDetector(
                                onTap: () {
                                  print('Crop');
                                },
                                child: Icon(
                                  Icons.crop,
                                  color: Colors.white,
                                ))
                          ],
                        ),
                      )
                    ])
                  : Container(
                      child: ListView(
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                public = !public;
                              });
                            },
                            child: Icon(
                              public ? Icons.lock_open : Icons.lock_outline,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isGame = !isGame;
                              });
                              _game();
                            },
                            child: Icon(
                              Icons.videogame_asset,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isCaption = !isCaption;
                              });
                              _caption();
                            },
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isHashtags = !isHashtags;
                              });
                              _hashtags();
                            },
                            child: Icon(
                              Icons.tag,
                              color: Colors.white,
                            ),
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
                      ? Icon(
                          Icons.expand_less,
                          color: Colors.white,
                        )
                      : Icon(
                          Icons.expand_more,
                          color: Colors.white,
                        ),
                )),
          ],
        ));
  }

  _game() {
    return showMaterialModalBottomSheet(
        context: context,
        enableDrag: false,
        backgroundColor:
            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
        builder: (context) {
          return GestureDetector(
            onTap: () {
              if (_focusNodeCaption.hasFocus) {
                _focusNodeCaption.unfocus();
              }
            },
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20.0,
                  ),
                  Container(
                      alignment: Alignment.centerLeft,
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      child: IconButton(
                          onPressed: () {
                            setState(() {
                              isGame = !isGame;
                            });
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.clear))),
                  SizedBox(
                    height: 20.0,
                  ),
                  Container(
                      height: 100.0,
                      width: MediaQuery.of(context).size.width,
                      child: gameName == 'No game'
                          ? Column(
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      borderRadius: BorderRadius.circular(5.0)),
                                  child: Icon(Icons.videogame_asset),
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                                Text(gameName)
                              ],
                            )
                          : Column(
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      borderRadius: BorderRadius.circular(5.0),
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: CachedNetworkImageProvider(
                                              gameImage))),
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                                Text(gameName)
                              ],
                            )),
                  SizedBox(
                    height: 20.0,
                  ),
                  Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: widget.followsGames.length,
                          itemBuilder: (_, int index) {
                            DocumentSnapshot<Map<String, dynamic>>
                                _documentSnapshot = widget.followsGames[index];
                            return ListTile(
                              onTap: () {
                                setState(() {
                                  gameName = _documentSnapshot.data()!['name'];
                                  gameImage =
                                      _documentSnapshot.data()!['imageUrl'];
                                  isGame = !isGame;
                                });
                                Navigator.pop(context);
                              },
                              leading: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.circular(5.0),
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: CachedNetworkImageProvider(
                                            _documentSnapshot
                                                .data()!['imageUrl']))),
                              ),
                              title: Text(_documentSnapshot.data()!['name']),
                            );
                          }))
                ],
              ),
            ),
          );
        });
  }

  _caption() {
    return showMaterialModalBottomSheet(
        context: context,
        enableDrag: false,
        backgroundColor:
            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
        builder: (context) {
          return GestureDetector(
            onTap: () {
              if (_focusNodeCaption.hasFocus) {
                _focusNodeCaption.unfocus();
              }
            },
            child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                              onPressed: () {
                                _captionController.clear();
                                _captionController.text = saveCaption;
                                setState(() {
                                  isCaption = !isCaption;
                                });
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.clear)),
                          IconButton(
                              onPressed: () {
                                saveCaption = _captionController.text;
                                setState(() {
                                  isCaption = !isCaption;
                                });
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.check))
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height / 3,
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: TextField(
                          controller: _captionController,
                          focusNode: _focusNodeCaption,
                          autofocus: true,
                          minLines: 1,
                          maxLines: 15,
                          decoration: InputDecoration(
                              labelText: 'Write caption',
                              labelStyle: TextStyle(
                                  color: Theme.of(context).accentColor),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).accentColor))),
                        ),
                      ),
                    )
                  ],
                )),
          );
        });
  }

  _hashtags() {
    return showMaterialModalBottomSheet(
        context: context,
        enableDrag: false,
        backgroundColor:
            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            return GestureDetector(
              onTap: () {
                if (_focusNodeHashtags.hasFocus) {
                  _focusNodeHashtags.unfocus();
                }
              },
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            isHashtags = !isHashtags;
                          });
                          _hashtagsController.clear();

                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.clear),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    TextField(
                      controller: _hashtagsController,
                      focusNode: _focusNodeHashtags,
                      autofocus: false,
                      decoration: InputDecoration(
                        labelText: 'Write hashtag',
                        labelStyle:
                            TextStyle(color: Theme.of(context).accentColor),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).accentColor)),
                        contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        suffixIcon: InkWell(
                          onTap: () {
                            if (!hashtagsSelected.contains(
                                _hashtagsController.text.toLowerCase())) {
                              setModalState(() {
                                hashtagsSelected.add(_hashtagsController.text);
                              });
                              _hashtagsController.clear();
                            } else {
                              _hashtagsController.clear();
                            }
                          },
                          child: Icon(
                            Icons.add,
                            color: Theme.of(context).accentColor,
                          ),
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
                                border: Border.all(
                                    color: Theme.of(context).accentColor)),
                            child: Center(
                              child: Text('Pas encore d\'hashtags'),
                            ),
                          )
                        : Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Theme.of(context).accentColor)),
                            child: Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Wrap(
                                  spacing: 5,
                                  runSpacing: 5,
                                  children: hashtagsSelected.map((hashtag) {
                                    return Chip(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      label:
                                          Text('#$hashtag', style: mystyle(11)),
                                      onDeleted: () {
                                        setModalState(() {
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
                                style:
                                    mystyle(11, Colors.white.withOpacity(0.6)),
                              ),
                              onTap: () {
                                setModalState(() {
                                  if (!hashtagsSelected.contains(
                                      _resultList[index].data()['name'])) {
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
              ),
            );
          });
        });
  }
}
