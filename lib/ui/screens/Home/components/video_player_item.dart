import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:helpers/helpers.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VideoPlayerItem extends StatefulWidget {
  final String? idUser, idPost, videoUrl;

  VideoPlayerItem({this.idUser, this.idPost, this.videoUrl});

  @override
  VideoPlayerItemState createState() => VideoPlayerItemState();
}

class VideoPlayerItemState extends State<VideoPlayerItem>
    with TickerProviderStateMixin {
  late VideoPlayerController _videoPlayerController;

  String? uid;

  late AnimationController _upController, _downController;
  late Animation _upAnimation, _downAnimation;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;

    updateView();

    _videoPlayerController = VideoPlayerController.network(widget.videoUrl!);
    _videoPlayerController.initialize();
    _videoPlayerController.setLooping(true);
    _videoPlayerController.play();

    _upController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _upAnimation = CurvedAnimation(parent: _upController, curve: Curves.easeIn);

    _upController.addListener(() {
      if (_upController.isCompleted) {
        _upController.reverse();
      }
    });

    _downController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _downAnimation =
        CurvedAnimation(parent: _downController, curve: Curves.easeIn);

    _downController.addListener(() {
      if (_downController.isCompleted) {
        _downController.reverse();
      }
    });
  }

  @override
  void dispose() async {
    if (mounted) {
      await _videoPlayerController.dispose();
    }
    _upController.dispose();
    _downController.dispose();
    super.dispose();
  }

  updateView() async {
    DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
        .instance
        .collection('posts')
        .doc(widget.idPost)
        .get();

    if (doc.exists) {
      if (doc.data()!['uid'] != uid) {
        FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.idPost)
            .update({'viewcount': doc.data()!['viewcount'] + 1});
      }

      var view = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.idPost)
          .collection('viewers')
          .doc(uid)
          .get();
      if (!view.exists) {
        FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.idPost)
            .collection('viewers')
            .doc(uid)
            .set({});
      }
    }
  }

  upPost() async {
    DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
        .instance
        .collection('posts')
        .doc(widget.idPost)
        .get();

    if (!doc.data()!['up'].contains(uid)) {
      if (doc.data()!['down'].contains(uid)) {
        FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.idPost)
            .update({
          'down': FieldValue.arrayRemove([uid])
        });
      }
      FirebaseFirestore.instance.collection('posts').doc(widget.idPost).update({
        'up': FieldValue.arrayUnion([uid])
      });
    }
  }

  downPost() async {
    DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
        .instance
        .collection('posts')
        .doc(widget.idPost)
        .get();

    if (!doc.data()!['down'].contains(uid)) {
      if (doc.data()!['up'].contains(uid)) {
        FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.idPost)
            .update({
          'up': FieldValue.arrayRemove([uid])
        });
      }
      FirebaseFirestore.instance.collection('posts').doc(widget.idPost).update({
        'down': FieldValue.arrayUnion([uid])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _videoPlayerController,
      builder: (_, __) {
        return GestureDetector(
          onTap: () {
            setState(() {
              if (_videoPlayerController.value.isPlaying) {
                _videoPlayerController.pause();
              } else {
                _videoPlayerController.play();
              }
            });
          },
          child: Stack(
            children: [
              Container(
                  color: Colors.black,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _videoPlayerController.value.aspectRatio,
                      child: VideoPlayer(_videoPlayerController),
                    ),
                  )),
              Center(
                  child: OpacityTransition(
                visible: !_videoPlayerController.value.isPlaying,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: Icon(
                    _videoPlayerController.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.black,
                  ),
                ),
              )),
              Column(
                children: [
                  Expanded(child: Container(
                    child: GestureDetector(
                      onDoubleTap: () {
                        if (uid != widget.idUser) {
                          _upController.forward();
                          upPost();
                        }
                      },
                    ),
                  )),
                  Expanded(
                    child: Container(
                      child: GestureDetector(
                        onDoubleTap: () {
                          if (uid != widget.idUser) {
                            _downController.forward();
                            downPost();
                          }
                        },
                      ),
                    ),
                  )
                ],
              ),
              Center(
                child: FadeTransition(
                  opacity: _upAnimation as Animation<double>,
                  child: Icon(
                    Icons.arrow_upward,
                    color: Colors.green,
                    size: 80,
                  ),
                ),
              ),
              Center(
                child: FadeTransition(
                  opacity: _downAnimation as Animation<double>,
                  child: Icon(
                    Icons.arrow_downward,
                    color: Colors.red,
                    size: 80,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
