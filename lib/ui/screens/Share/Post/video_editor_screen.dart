import 'dart:io';

import 'package:Gemu/constants/variables.dart';
import 'package:flutter/material.dart';
import 'package:video_editor/video_editor.dart';
import 'package:helpers/helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'crop_screen.dart';

import 'package:Gemu/constants/route_names.dart';
import 'package:Gemu/models/game.dart';

class VideoEditorScreen extends StatefulWidget {
  final File file;

  VideoEditorScreen({this.file});

  @override
  VideoEditorScreenState createState() => VideoEditorScreenState();
}

class VideoEditorScreenState extends State<VideoEditorScreen> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;

  int durationVideo;

  bool _exported = false;
  bool isUploading = false;
  bool isCaption = false;
  bool isHashtags = false;
  String _exportText = "";
  String choixGameName = "";
  String choixGameId = "";

  FlutterVideoCompress flutterVideoCompress = FlutterVideoCompress();

  VideoEditorController _videoEditorController;
  TextEditingController _captionController = TextEditingController();
  TextEditingController _hashtagsController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  compressVideo(String videoPath) async {
    final compressedVideo = await flutterVideoCompress.compressVideo(videoPath,
        quality: VideoQuality.MediumQuality);
    return File(compressedVideo.path);
  }

  getPreviewImage(String videoPath) async {
    final previewImage =
        await flutterVideoCompress.getThumbnailWithFile(videoPath);

    final lastIndex = previewImage.path.lastIndexOf(RegExp(r'.jp'));
    final splitted = previewImage.path.substring(0, lastIndex);
    final outPath = "${splitted}_out${previewImage.path.substring(lastIndex)}";
    var compressImage = await FlutterImageCompress.compressAndGetFile(
        previewImage.path, outPath);

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

  uploadVideo(String videoPath, String idGame, String nameGame) async {
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
      String video = await uploadVideoToStorage(
          videoPath, "Video$currentUser-$length", nameGame);
      String previewImage = await uploadImagePreviewToStorage(
          videoPath, "Video$currentUser-$length", nameGame);
      FirebaseFirestore.instance
          .collection('posts')
          .doc("Video$currentUser-$length")
          .set({
        'uid': currentUser,
        'username': userdoc.data()['pseudo'],
        'profilpicture': userdoc.data()['photoURL'],
        'id': "Video$currentUser-$length",
        'game': nameGame,
        'up': [],
        'down': [],
        'commentcount': 0,
        'caption': _captionController.text,
        'hashtags': _hashtagsController.text,
        'videoUrl': video,
        'previewImage': previewImage
      });
      Navigator.pushNamedAndRemoveUntil(
          context, NavScreenRoute, (route) => false);
    } catch (e) {
      print(e);
    }
  }

  void _exportVideo() async {
    Misc.delayed(1000, () => _isExporting.value = true);
    final File file = await _videoEditorController.exportVideo(
      customInstruction: "-crf 17",
      preset: VideoExportPreset.medium,
      progressCallback: (statics) {
        if (_videoEditorController.video != null)
          _exportingProgress.value = statics.time /
              _videoEditorController.video.value.duration.inMilliseconds;
      },
    );
    _isExporting.value = false;

    if (file != null) {
      _exportText = "Video success export!";
      uploadVideo(file.path, choixGameId, choixGameName);
    } else {
      _exportText = "Error on export video";
    }

    setState(() => _exported = true);
    Misc.delayed(2000, () => setState(() => _exported = false));
  }

  void _openCropScren() {
    context.to(CropScreen(
      videoEditorController: _videoEditorController,
    ));
  }

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    super.initState();
    _videoEditorController = VideoEditorController.file(widget.file)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() async {
    if (mounted) {
      await _videoEditorController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext contex) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _videoEditorController.initialized
          ? SafeArea(
              child: isUploading
                  ? AnimatedBuilder(
                      animation: _videoEditorController,
                      builder: (_, __) {
                        return Stack(
                          children: [
                            ClipRRect(
                              child: CropGridViewer(
                                controller: _videoEditorController,
                                showGrid: false,
                              ),
                            ),
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
                        );
                      })
                  : AnimatedBuilder(
                      animation: _videoEditorController,
                      builder: (_, __) {
                        return Stack(
                          children: [
                            ClipRRect(
                              child: CropGridViewer(
                                controller: _videoEditorController,
                                showGrid: false,
                              ),
                            ),
                            Center(
                                child: OpacityTransition(
                                    visible: !_videoEditorController.isPlaying,
                                    child: GestureDetector(
                                      onTap: _videoEditorController.video.play,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle),
                                        child: Icon(
                                          Icons.play_arrow,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ))),
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
                                    : 140.0,
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
                                    : 110.0,
                                child: _hashtags(),
                                duration: Duration(milliseconds: 300)),
                            ..._trimSlider(),
                            _customSnackBar(),
                            ValueListenableBuilder(
                              valueListenable: _isExporting,
                              builder: (_, bool export, __) =>
                                  OpacityTransition(
                                visible: export,
                                child: AlertDialog(
                                  title: ValueListenableBuilder(
                                    valueListenable: _exportingProgress,
                                    builder: (_, double value, __) =>
                                        TextDesigned(
                                      "Exporting video ${(value * 100).ceil()}%",
                                      color: Colors.black,
                                      bold: true,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        );
                      }))
          : Center(
              child: CircularProgressIndicator(),
            ),
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

  Widget _designBar() {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      margin: EdgeInsets.only(right: 10.0),
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () =>
                  _videoEditorController.rotate90Degrees(RotateDirection.left),
              child: Icon(
                Icons.rotate_left,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () =>
                  _videoEditorController.rotate90Degrees(RotateDirection.right),
              child: Icon(
                Icons.rotate_right,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
              child: GestureDetector(
            onTap: _openCropScren,
            child: Icon(
              Icons.crop,
              color: Colors.white,
            ),
          )),
        ],
      ),
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
                  choixGameId == "" ||
                  durationVideo > 10) {
                if (_captionController.text == null ||
                    _captionController.text == "") {
                  showInSnackBar('Write caption');
                }
                if (choixGameId == null || choixGameId == "") {
                  showInSnackBar('Choose game');
                }
                if (durationVideo > 10) {
                  showInSnackBar('Maximum video seconds: 10');
                }
              } else {
                print(durationVideo);
                _exportVideo();
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

  List<Widget> _trimSlider() {
    final duration = _videoEditorController.videoDuration.inSeconds;
    final pos = _videoEditorController.trimPosition * duration;
    final start = _videoEditorController.minTrim * duration;
    final end = _videoEditorController.maxTrim * duration;

    durationVideo = end.toInt() - start.toInt();

    String formatter(Duration duration) =>
        duration.inMinutes.remainder(60).toString().padLeft(2, '0') +
        ":" +
        (duration.inSeconds.remainder(60)).toString().padLeft(2, '0');

    return [
      Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: Margin.symmetric(horizontal: height / 4, vertical: 80),
          child: Row(children: [
            TextDesigned(
              formatter(Duration(seconds: pos.toInt())),
              color: Colors.white,
            ),
            Expanded(child: SizedBox()),
            OpacityTransition(
              visible: _videoEditorController.isTrimming,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                TextDesigned(
                  formatter(Duration(seconds: start.toInt())),
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                TextDesigned(
                  formatter(Duration(seconds: end.toInt())),
                  color: Colors.white,
                ),
              ]),
            )
          ]),
        ),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: height,
          margin: Margin.all(height / 4),
          child: TrimSlider(
            controller: _videoEditorController,
            height: height,
          ),
        ),
      ),
    ];
  }
}
