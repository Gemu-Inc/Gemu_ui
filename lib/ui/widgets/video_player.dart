import 'package:flutter/material.dart';
import 'dart:async';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  VideoPlayerScreen({Key key, @required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController controller;
  Future<void> futureController;

  @override
  void initState() {
    controller = VideoPlayerController.network(widget.videoUrl);
    futureController = controller.initialize();
    controller.setLooping(true);
    controller.setVolume(25.0);
    controller.play();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
        color: Colors.transparent,
        elevation: 0.0,
        onPressed: () {
          setState(() {
            if (controller.value.isPlaying) {
              controller.pause();
            } else {
              controller.play();
            }
          });
        },
        child: Stack(
          children: [
            FutureBuilder(
              future: futureController,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
            Center(
                child: Icon(controller.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow))
          ],
        ));
  }
}
