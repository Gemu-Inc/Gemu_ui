import 'package:flutter/material.dart';
import 'package:helpers/helpers.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:gemu/models/post.dart';

class VideoItem extends StatefulWidget {
  final String idUser;
  final Post post;
  final bool showProgressBar;

  VideoItem({
    required this.idUser,
    required this.post,
    this.showProgressBar = true,
  });

  late _VideoItemState state;

  @override
  State<StatefulWidget> createState() {
    state = _VideoItemState();
    return state;
  }

  updateUrl(String url) {
    state.setUrl(url);
  }
}

class _VideoItemState extends State<VideoItem> with TickerProviderStateMixin {
  late VideoPlayerController _videoPlayerController;
  late AnimationController _upController, _downController;
  late Animation _upAnimation, _downAnimation;
  late VoidCallback listener;
  bool _videoReady = false;
  bool _showSeekBar = true;

  _VideoItemState() {
    listener = () {
      if (mounted) {
        setState(() {});
      }
    };
  }

  updateView() async {
    widget.post.reference.update({'viewcount': widget.post.viewcount + 1});

    widget.post.reference
        .collection('viewers')
        .doc(widget.idUser)
        .get()
        .then((viewer) {
      if (!viewer.exists) {
        viewer.reference.set({});
      }
    });
  }

  upPost() async {
    widget.post.reference
        .collection('up')
        .doc(widget.idUser)
        .get()
        .then((uper) {
      if (!uper.exists) {
        uper.reference.set({});
        widget.post.reference.update({'upcount': widget.post.upcount + 1});
      }
    });

    widget.post.reference
        .collection('down')
        .doc(widget.idUser)
        .get()
        .then((downer) {
      if (downer.exists) {
        downer.reference.delete();
        widget.post.reference.update({'downcount': widget.post.downcount - 1});
      }
    });
  }

  downPost() async {
    widget.post.reference
        .collection('down')
        .doc(widget.idUser)
        .get()
        .then((downer) {
      if (!downer.exists) {
        downer.reference.set({});
        widget.post.reference.update({'downcount': widget.post.downcount + 1});
      }
    });

    widget.post.reference
        .collection('up')
        .doc(widget.idUser)
        .get()
        .then((upper) {
      if (upper.exists) {
        upper.reference.delete();
        widget.post.reference.update({'upcount': widget.post.upcount - 1});
      }
    });
  }

  @override
  void initState() {
    super.initState();

    if (widget.post.uid != widget.idUser) {
      updateView();
    }

    _videoPlayerController = VideoPlayerController.network(widget.post.postUrl,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true))
      ..initialize().then((_) {
        _videoPlayerController.setLooping(true);
        _videoPlayerController.play();
        if (mounted) {
          setState(() {
            _videoReady = true;
          });
        }
      });
    _videoPlayerController.addListener(listener);

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
  void deactivate() {
    _videoPlayerController.removeListener(listener);
    _upController.removeListener(() {});
    _downController.removeListener(() {});
    super.deactivate();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _upController.dispose();
    _downController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        setState(() {
          _showSeekBar = !_showSeekBar;
        });
      },
      onTap: () {
        setState(() {
          if (_videoPlayerController.value.isPlaying) {
            _videoPlayerController.pause();
          } else {
            _videoPlayerController.play();
          }
        });
      },
      child: Container(
        color: Colors.black,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Center(
              child: _videoReady
                  ? AspectRatio(
                      aspectRatio: _videoPlayerController.value.aspectRatio,
                      child: VideoPlayer(_videoPlayerController),
                    )
                  : Image(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(
                          widget.post.previewImage!)),
            ),
            getPlayController(),
            Column(
              children: [
                Expanded(child: Container(
                  child: GestureDetector(
                    onDoubleTap: () {
                      if (widget.post.uid != widget.idUser) {
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
                        if (widget.post.uid != widget.idUser) {
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
      ),
    );
  }

  getPlayController() {
    return Offstage(
      offstage: !_showSeekBar,
      child: Stack(
        children: <Widget>[
          Center(
            child: OpacityTransition(
              duration: Duration(milliseconds: 500),
              visible: !_videoPlayerController.value.isPlaying,
              child: Icon(
                _videoPlayerController.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                size: 55,
              ),
            ),
          ),
          getProgressContent(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Center(
                child: _videoPlayerController.value.isBuffering
                    ? CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      )
                    : null),
          )
        ],
      ),
    );
  }

  Widget getProgressContent() {
    return (widget.showProgressBar
        ? Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 10.0,
              child: Offstage(
                offstage: !widget.showProgressBar,
                child: VideoProgressIndicator(
                  _videoPlayerController,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                      playedColor: Theme.of(context).primaryColor,
                      backgroundColor: Colors.grey),
                ),
              ),
            ),
          )
        : Container());
  }

  void setUrl(String url) {
    if (mounted) {
      print('updateUrl');
      _videoPlayerController.removeListener(listener);
      _videoPlayerController.pause();

      _videoPlayerController = VideoPlayerController.network(url)
        ..initialize().then((_) {
          setState(() {});
          if (_videoPlayerController.value.duration ==
              _videoPlayerController.value.position) {
            _videoPlayerController.seekTo(Duration(seconds: 0));
            setState(() {});
          }
        });
      _videoPlayerController.addListener(listener);
    }
  }
}
