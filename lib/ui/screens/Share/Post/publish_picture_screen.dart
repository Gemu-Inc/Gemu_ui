import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:Gemu/constants/variables.dart';
import 'package:Gemu/constants/route_names.dart';

class PublishPictureScreen extends StatefulWidget {
  final String imagePath;

  PublishPictureScreen({this.imagePath});

  @override
  PublishPictureScreenState createState() => PublishPictureScreenState();
}

class PublishPictureScreenState extends State<PublishPictureScreen> {
  TextEditingController _captionController = TextEditingController();
  bool isUploading = false;

  uploadPictureToStorage(String id) async {
    UploadTask storageUploadTask = FirebaseStorage.instance
        .ref()
        .child('posts')
        .child('pictures')
        .child(id)
        .putFile(File(widget.imagePath));
    TaskSnapshot storageTaskSnapshot =
        await storageUploadTask.whenComplete(() {});
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  uploadPicture() async {
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
      String picture =
          await uploadPictureToStorage("Picture$currentUser-$length");
      FirebaseFirestore.instance
          .collection('posts')
          .doc("Picture$currentUser-$length")
          .set({
        'username': userdoc.data()['pseudo'],
        'uid': currentUser,
        'id': "Picture$currentUser-$length",
        'likes': [],
        'commentcount': 0,
        'caption': _captionController.text,
        'pictureUrl': picture,
      });
      Navigator.pushNamedAndRemoveUntil(
          context, NavScreenRoute, (route) => false);
    } catch (e) {
      print(e);
    }
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
                      child: Image.file(File(widget.imagePath))),
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
                      child: Image.file(File(widget.imagePath))),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () => Navigator.pop(context))),
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
                          uploadPicture();
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
