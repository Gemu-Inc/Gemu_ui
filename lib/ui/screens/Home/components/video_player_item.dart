import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;

  VideoPlayerItem({this.videoUrl});

  @override
  VideoPlayerItemState createState() => VideoPlayerItemState();
}

class VideoPlayerItemState extends State<VideoPlayerItem> {
  VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((value) {
        _videoPlayerController.play();
        _videoPlayerController.setVolume(1);
      });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: VideoPlayer(_videoPlayerController),
    );
  }
}
