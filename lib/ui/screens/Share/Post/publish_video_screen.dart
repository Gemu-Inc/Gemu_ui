import 'dart:io';

import 'package:Gemu/constants/route_names.dart';
import 'package:Gemu/constants/variables.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PublishVideoScreen extends StatefulWidget {
  final String videoPath;

  PublishVideoScreen({this.videoPath});

  @override
  PublishVideoScreenState createState() => PublishVideoScreenState();
}

class PublishVideoScreenState extends State<PublishVideoScreen> {
  VideoPlayerController _videoPlayerController;
  FlutterVideoCompress flutterVideoCompress = FlutterVideoCompress();
  TextEditingController _captionController = TextEditingController();

  bool isUploading = false;

  compressVideo() async {
    final compressedVideo = await flutterVideoCompress
        .compressVideo(widget.videoPath, quality: VideoQuality.MediumQuality);
    return File(compressedVideo.path);
  }

  getPreviewImage() async {
    final previewImage =
        await flutterVideoCompress.getThumbnailWithFile(widget.videoPath);
    return previewImage;
  }

  uploadVideoToStorage(String id) async {
    UploadTask storageUploadTask = FirebaseStorage.instance
        .ref()
        .child('posts')
        .child('vidéos')
        .child(id)
        .putFile(await compressVideo());
    TaskSnapshot storageTaskSnapshot =
        await storageUploadTask.whenComplete(() {});
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  uploadImagePreviewToStorage(String id) async {
    UploadTask storageUploadTask = FirebaseStorage.instance
        .ref()
        .child('posts')
        .child('previewImage')
        .child(id)
        .putFile(await getPreviewImage());
    TaskSnapshot storageTaskSnapshot =
        await storageUploadTask.whenComplete(() {});
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  uploadVideo() async {
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
      String video = await uploadVideoToStorage("Video$currentUser-$length");
      String previewImage =
          await uploadImagePreviewToStorage("Video$currentUser-$length");
      FirebaseFirestore.instance
          .collection('posts')
          .doc("Video$currentUser-$length")
          .set({
        'username': userdoc.data()['pseudo'],
        'uid': currentUser,
        'id': "Video$currentUser-$length",
        'likes': [],
        'commentcount': 0,
        'caption': _captionController.text,
        'videoUrl': video,
        'previewImage': previewImage
      });
      Navigator.pushNamedAndRemoveUntil(
          context, NavScreenRoute, (route) => false);
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();

    _videoPlayerController = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        _videoPlayerController.play();
        _videoPlayerController.setVolume(1);
        _videoPlayerController.setLooping(true);
        setState(() {});
      });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: isUploading
          ? Stack(
              children: [
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      height: _videoPlayerController.value.size?.height ?? 0,
                      width: _videoPlayerController.value.size?.width ?? 0,
                      child: VideoPlayer(_videoPlayerController),
                    ),
                  ),
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
                    fit: BoxFit.cover,
                    child: SizedBox(
                      height: _videoPlayerController.value.size?.height ?? 0,
                      width: _videoPlayerController.value.size?.width ?? 0,
                      child: VideoPlayer(_videoPlayerController),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            icon: Icon(Icons.multitrack_audio),
                            onPressed: () =>
                                _videoPlayerController.setVolume(0)),
                        IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () => Navigator.pop(context))
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 5.0),
                        width: MediaQuery.of(context).size.width / 2,
                        height: 50,
                        child: TextField(
                          controller: _captionController,
                          decoration: InputDecoration(
                              labelText: 'Caption',
                              labelStyle: mystyle(15),
                              prefixIcon: Icon(Icons.closed_caption),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          uploadVideo();
                        },
                        child: Container(
                            margin: EdgeInsets.only(bottom: 5.0),
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
                  ),
                )
              ],
            ),
    );
  }
}
