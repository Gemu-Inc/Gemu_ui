import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PictureItem extends StatefulWidget {
  final String idPost, pictureUrl;

  PictureItem({this.idPost, this.pictureUrl});

  @override
  PictureItemState createState() => PictureItemState();
}

class PictureItemState extends State<PictureItem>
    with TickerProviderStateMixin {
  String uid;

  AnimationController _upController, _downController;
  Animation _upAnimation, _downAnimation;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser.uid;

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
  void dispose() {
    _upController.dispose();
    super.dispose();
  }

  upPost() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.idPost)
        .get();

    if (!doc.data()['up'].contains(uid)) {
      if (doc.data()['down'].contains(uid)) {
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
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.idPost)
        .get();

    if (!doc.data()['down'].contains(uid)) {
      if (doc.data()['up'].contains(uid)) {
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
    return SafeArea(
        child: Stack(
      children: [
        Container(
          color: Colors.black,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: Image.network(widget.pictureUrl),
          ),
        ),
        Column(
          children: [
            Expanded(child: Container(
              child: GestureDetector(
                onDoubleTap: () {
                  _upController.forward();
                  upPost();
                },
              ),
            )),
            Expanded(
              child: Container(
                child: GestureDetector(
                  onDoubleTap: () {
                    _downController.forward();
                    downPost();
                  },
                ),
              ),
            )
          ],
        ),
        Center(
          child: FadeTransition(
            opacity: _upAnimation,
            child: Icon(
              Icons.arrow_upward,
              color: Colors.green,
              size: 80,
            ),
          ),
        ),
        Center(
          child: FadeTransition(
            opacity: _downAnimation,
            child: Icon(
              Icons.arrow_downward,
              color: Colors.red,
              size: 80,
            ),
          ),
        )
      ],
    ));
  }
}
