import 'dart:io';

import 'package:Gemu/constants/variables.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConfirmationScreen extends StatefulWidget {
  final File file;
  final String path;
  final ImageSource imageSource;

  ConfirmationScreen({this.file, this.path, this.imageSource});

  @override
  ConfirmationScreenState createState() => ConfirmationScreenState();
}

class ConfirmationScreenState extends State<ConfirmationScreen> {
  VideoPlayerController videoPlayerController;

  bool isUploading = false;
  TextEditingController captionController = TextEditingController();
  FlutterVideoCompress flutterVideoCompress = FlutterVideoCompress();

  @override
  void initState() {
    super.initState();
    setState(() {
      videoPlayerController = VideoPlayerController.file(widget.file);
    });
    videoPlayerController.initialize();
    videoPlayerController.play();
    videoPlayerController.setVolume(1);
    videoPlayerController.setLooping(true);
    print('video: ${widget.path}');
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    super.dispose();
  }

  compressVideo() async {
    if (widget.imageSource == ImageSource.gallery) {
      return widget.file;
    } else {
      final compressedVideo = await flutterVideoCompress
          .compressVideo(widget.path, quality: VideoQuality.MediumQuality);
      return File(compressedVideo.path);
    }
  }

  getPreviewImage() async {
    final previewImage =
        await flutterVideoCompress.getThumbnailWithFile(widget.path);
    return previewImage;
  }

  uploadVideoToStorage(String id) async {
    UploadTask storageUploadTask = FirebaseStorage.instance
        .ref()
        .child('videos')
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
        .child('images')
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
      var alldocs = await FirebaseFirestore.instance.collection('videos').get();
      int length = alldocs.docs.length;
      print('Nb de videos: $length');
      String video = await uploadVideoToStorage("Video $length");
      String previewImage = await uploadImagePreviewToStorage("Video $length");
      FirebaseFirestore.instance.collection('videos').doc("Video $length").set({
        'username': userdoc.data()['pseudo'],
        'uid': currentUser,
        'id': "Video $length",
        'likes': [],
        'commentcount': 0,
        'caption': captionController.text,
        'videoUrl': video,
        'previewImage': previewImage
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: isUploading == true
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Upload',
                    style: mystyle(25),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  CircularProgressIndicator()
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 1.5,
                    child: VideoPlayer(videoPlayerController),
                  ),
                  SizedBox(height: 20.0),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          margin: EdgeInsets.only(right: 40),
                          child: TextField(
                            controller: captionController,
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Caption',
                                labelStyle: mystyle(20),
                                prefixIcon: Icon(Icons.closed_caption),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20))),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RaisedButton(
                        onPressed: () {
                          setState(() {
                            isUploading = true;
                          });
                          uploadVideo();
                        },
                        color: Colors.lightBlue,
                        child: Text(
                          'Upload',
                          style: mystyle(20),
                        ),
                      ),
                      RaisedButton(
                        onPressed: () => Navigator.pop(context),
                        color: Colors.red,
                        child: Text(
                          'Cancel',
                          style: mystyle(20),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
    );
  }
}
