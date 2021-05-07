import 'package:Gemu/constants/variables.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentPostBar extends StatefulWidget {
  final String? idPost;
  final FocusNode? focusNode;

  CommentPostBar({required this.idPost, required this.focusNode});

  @override
  CommentPostBarState createState() => CommentPostBarState();
}

class CommentPostBarState extends State<CommentPostBar>
    with SingleTickerProviderStateMixin {
  TextEditingController _commentController = TextEditingController();
  late AnimationController _animationController;

  String? uid;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
    _animationController = _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 5))
          ..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  publishComment() async {
    DocumentSnapshot<Map<String, dynamic>> userdoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    var alldocs = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.idPost)
        .collection('comments')
        .get();
    int length = alldocs.docs.length;

    FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.idPost)
        .collection('comments')
        .doc('Comment$length')
        .set({
      'username': userdoc.data()!['pseudo'],
      'uid': uid,
      'profilpicture': userdoc.data()!['photoURL'],
      'comment': _commentController.text,
      'up': [],
      'down': [],
      'time': DateTime.now(),
      'id': 'Comment$length'
    });
    _commentController.clear();
    DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
        .instance
        .collection('posts')
        .doc(widget.idPost)
        .get();
    FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.idPost)
        .update({'commentcount': doc.data()!['commentcount'] + 1});
  }

  @override
  Widget build(BuildContext context) {
    Animatable<Color?> background = TweenSequence<Color?>([
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Theme.of(context).primaryColor.withOpacity(0.4),
          end: Theme.of(context).accentColor.withOpacity(0.4),
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Theme.of(context).accentColor.withOpacity(0.4),
          end: Theme.of(context).primaryColor.withOpacity(0.4),
        ),
      ),
    ]);

    return SingleChildScrollView(
        child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  decoration: BoxDecoration(
                      color: background.evaluate(
                          AlwaysStoppedAnimation(_animationController.value)),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10))),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: TextField(
                            controller: _commentController,
                            focusNode: widget.focusNode,
                            decoration: InputDecoration(
                                hintText: "Type comment",
                                border: InputBorder.none),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: InkWell(
                          onTap: () {
                            publishComment();
                            if (widget.focusNode!.hasFocus) {
                              widget.focusNode!.unfocus();
                            }
                          },
                          child: Text(
                            'Publish',
                            style: mystyle(15),
                          ),
                        ),
                      )
                    ],
                  ));
            }));
  }
}
