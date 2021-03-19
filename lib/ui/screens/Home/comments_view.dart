import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as time;

import 'package:Gemu/constants/variables.dart';
import 'profile_view.dart';

class CommentsView extends StatefulWidget {
  final String idPost;

  CommentsView({this.idPost});

  @override
  CommentsViewState createState() => CommentsViewState();
}

class CommentsViewState extends State<CommentsView> {
  String uid;

  TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser.uid;
  }

  publishComment() async {
    DocumentSnapshot userdoc =
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
      'username': userdoc.data()['pseudo'],
      'uid': uid,
      'profilpicture': userdoc.data()['photoURL'],
      'comment': _commentController.text,
      'up': [],
      'down': [],
      'time': DateTime.now(),
      'id': 'Comment$length'
    });
    _commentController.clear();
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.idPost)
        .get();
    FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.idPost)
        .update({'commentcount': doc.data()['commentcount'] + 1});
  }

  upComment(String id) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.idPost)
        .collection('comments')
        .doc(id)
        .get();

    if (doc.data()['up'].contains(uid)) {
      FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.idPost)
          .collection('comments')
          .doc(id)
          .update({
        'up': FieldValue.arrayRemove([uid])
      });
    } else {
      if (doc.data()['down'].contains(uid)) {
        FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.idPost)
            .collection('comments')
            .doc(id)
            .update({
          'down': FieldValue.arrayRemove([uid])
        });
      }
      FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.idPost)
          .collection('comments')
          .doc(id)
          .update({
        'up': FieldValue.arrayUnion([uid])
      });
    }
  }

  downComment(String id) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.idPost)
        .collection('comments')
        .doc(id)
        .get();

    if (doc.data()['down'].contains(uid)) {
      FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.idPost)
          .collection('comments')
          .doc(id)
          .update({
        'down': FieldValue.arrayRemove([uid])
      });
    } else {
      if (doc.data()['up'].contains(uid)) {
        FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.idPost)
            .collection('comments')
            .doc(id)
            .update({
          'up': FieldValue.arrayRemove([uid])
        });
      }
      FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.idPost)
          .collection('comments')
          .doc(id)
          .update({
        'down': FieldValue.arrayUnion([uid])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Comments',
          style: mystyle(15),
        ),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.clear),
          )
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(widget.idPost)
                    .collection('comments')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.data.docs.length == 0) {
                    return Center(
                      child: Text(
                        'No comments',
                        style: mystyle(11, Colors.white60),
                      ),
                    );
                  }
                  return ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        DocumentSnapshot comment = snapshot.data.docs[index];
                        return ListTile(
                            leading: GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProfileView(
                                            idUser: comment.data()['uid'],
                                          ))),
                              child: comment.data()['profilpicture'] == null
                                  ? Container(
                                      margin: EdgeInsets.all(3.0),
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white60,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Color(0xFF222831)),
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        size: 23,
                                        color: Colors.black,
                                      ))
                                  : Container(
                                      margin: EdgeInsets.all(3.0),
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white60,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Color(0xFF222831)),
                                        image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: CachedNetworkImageProvider(
                                                comment
                                                    .data()['profilpicture'])),
                                      )),
                            ),
                            title: Container(
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ProfileView(
                                                  idUser: comment.data()['uid'],
                                                ))),
                                    child: Text(
                                      "${comment.data()['username']}",
                                      style: mystyle(
                                          18, Colors.white60, FontWeight.w700),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5.0,
                                  ),
                                  Text(
                                      "${time.format(comment.data()['time'].toDate())}"),
                                ],
                              ),
                            ),
                            subtitle: Container(
                              child: Text(
                                "${comment.data()['comment']}",
                                style: mystyle(
                                    11, Colors.white60, FontWeight.w700),
                              ),
                            ),
                            trailing: Container(
                              height: 50,
                              width: 70,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InkWell(
                                          onTap: () =>
                                              upComment(comment.data()['id']),
                                          child: comment
                                                  .data()['up']
                                                  .contains(uid)
                                              ? Icon(
                                                  Icons.arrow_upward,
                                                  size: 25,
                                                  color: Colors.green,
                                                )
                                              : Icon(
                                                  Icons.arrow_upward_outlined,
                                                  size: 25,
                                                  color: Colors.white60,
                                                )),
                                      InkWell(
                                          onTap: () =>
                                              downComment(comment.data()['id']),
                                          child: comment
                                                  .data()['down']
                                                  .contains(uid)
                                              ? Icon(
                                                  Icons.arrow_downward,
                                                  size: 25,
                                                  color: Colors.red,
                                                )
                                              : Icon(
                                                  Icons.arrow_downward_outlined,
                                                  size: 25,
                                                  color: Colors.white60,
                                                )),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 3.0,
                                  ),
                                  Text(
                                      '${(comment.data()['up'].length.toInt() - comment.data()['down'].length.toInt())}')
                                ],
                              ),
                            ));
                      });
                },
              ),
            ),
            Divider(),
            ListTile(
              title: TextFormField(
                scrollPhysics: AlwaysScrollableScrollPhysics(),
                controller: _commentController,
                decoration: InputDecoration(
                    labelText: 'Comment',
                    labelStyle: mystyle(20, Colors.white60, FontWeight.w700),
                    suffixIcon: InkWell(
                      onTap: () => _commentController.clear(),
                      child: Icon(Icons.clear),
                    ),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white60)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white60))),
              ),
              trailing: OutlineButton(
                onPressed: () => publishComment(),
                borderSide: BorderSide.none,
                child: Text(
                  'Publish',
                  style: mystyle(16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
