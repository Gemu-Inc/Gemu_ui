import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:Gemu/constants/route_names.dart';

class EditPrivatePostsVideo extends StatefulWidget {
  final DocumentSnapshot post;

  EditPrivatePostsVideo({this.post});

  @override
  EditPrivatePostsVideoState createState() => EditPrivatePostsVideoState();
}

class EditPrivatePostsVideoState extends State<EditPrivatePostsVideo> {
  uploadVideo() {
    try {
      FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.data()['id'])
          .update({'privacy': 'Public'});
      Navigator.pushNamedAndRemoveUntil(
          context, NavScreenRoute, (route) => false);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
          child: Stack(
        children: [
          Center(child: Image.network(widget.post.data()['previewImage'])),
          Align(
            alignment: Alignment.topCenter,
            child: _topBar(),
          )
        ],
      )),
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
          onTap: () => print('choose game'),
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
            onTap: () => uploadVideo(),
            child: Icon(
              Icons.save,
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }
}
