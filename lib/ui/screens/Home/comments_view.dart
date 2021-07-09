import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as time;

import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/services/database_service.dart';
import 'profile_view.dart';

class CommentsView extends StatefulWidget {
  final String idPost, idUser;

  CommentsView({required this.idPost, required this.idUser});

  @override
  CommentsViewState createState() => CommentsViewState();
}

class CommentsViewState extends State<CommentsView> {
  late String uid;

  TextEditingController _commentController = TextEditingController();

  FocusNode? _focusNode;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode!.dispose();
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

    DatabaseService.addNotification(
        uid, widget.idUser, "a ajouté un commentaire", "comment");
  }

  upComment(String? id) async {
    DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
        .instance
        .collection('posts')
        .doc(widget.idPost)
        .collection('comments')
        .doc(id)
        .get();

    if (doc.data()!['up'].contains(uid)) {
      FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.idPost)
          .collection('comments')
          .doc(id)
          .update({
        'up': FieldValue.arrayRemove([uid])
      });
    } else {
      if (doc.data()!['down'].contains(uid)) {
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

  downComment(String? id) async {
    DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
        .instance
        .collection('posts')
        .doc(widget.idPost)
        .collection('comments')
        .doc(id)
        .get();

    if (doc.data()!['down'].contains(uid)) {
      FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.idPost)
          .collection('comments')
          .doc(id)
          .update({
        'down': FieldValue.arrayRemove([uid])
      });
    } else {
      if (doc.data()!['up'].contains(uid)) {
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
        backgroundColor: Colors.transparent,
        body: GestureDetector(
          onTap: () {
            if (_focusNode!.hasFocus) {
              _focusNode!.unfocus();
            }
          },
          child: Column(
            children: [
              Container(
                height: 35,
                child: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text("Comments"),
                  centerTitle: true,
                  actions: [
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.clear),
                        )),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(widget.idPost)
                      .collection('comments')
                      .snapshots(),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.data.docs.length == 0) {
                      return Center(
                        child: SingleChildScrollView(
                          child: Text(
                            'No comments',
                            style: mystyle(11, Colors.white60),
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          DocumentSnapshot<Map<String, dynamic>> comment =
                              snapshot.data.docs[index];
                          return ListTile(
                              leading: GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProfileView(
                                              idUser: comment.data()!['uid'],
                                            ))),
                                child: comment.data()!['profilpicture'] == null
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
                                                  comment.data()![
                                                      'profilpicture'])),
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
                                                    idUser:
                                                        comment.data()!['uid'],
                                                  ))),
                                      child: Text(
                                        "${comment.data()!['username']}",
                                        style: mystyle(18, Colors.white60,
                                            FontWeight.w700),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5.0,
                                    ),
                                    Expanded(
                                        child: Text(
                                      "${time.format(comment.data()!['time'].toDate())}",
                                      style: mystyle(9),
                                    )),
                                  ],
                                ),
                              ),
                              subtitle: Container(
                                child: Text(
                                  "${comment.data()!['comment']}",
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        InkWell(
                                            onTap: () => upComment(
                                                comment.data()!['id']),
                                            child: comment
                                                    .data()!['up']
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
                                            onTap: () => downComment(
                                                comment.data()!['id']),
                                            child: comment
                                                    .data()!['down']
                                                    .contains(uid)
                                                ? Icon(
                                                    Icons.arrow_downward,
                                                    size: 25,
                                                    color: Colors.red,
                                                  )
                                                : Icon(
                                                    Icons
                                                        .arrow_downward_outlined,
                                                    size: 25,
                                                    color: Colors.white60,
                                                  )),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 3.0,
                                    ),
                                    Text(
                                        '${(comment.data()!['up'].length.toInt() - comment.data()!['down'].length.toInt())}')
                                  ],
                                ),
                              ));
                        });
                  },
                ),
              ),
              Container(
                height: 45,
                decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                          color: Theme.of(context).canvasColor,
                          blurRadius: 5,
                          spreadRadius: 2)
                    ]),
                child: Row(
                  children: [
                    Expanded(
                        child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: TextFormField(
                        scrollPhysics: AlwaysScrollableScrollPhysics(),
                        focusNode: _focusNode,
                        controller: _commentController,
                        decoration: InputDecoration(
                            hintText: "Type comment", border: InputBorder.none),
                      ),
                    )),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: InkWell(
                          onTap: () {
                            publishComment();
                            if (_focusNode!.hasFocus) {
                              _focusNode!.unfocus();
                            }
                          },
                          child: Text('Publish',
                              style:
                                  mystyle(15, Theme.of(context).primaryColor)),
                        ))
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
