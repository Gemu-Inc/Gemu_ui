import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/services/database_service.dart';
import 'package:gemu/models/post.dart';
import 'package:gemu/models/commentaire.dart';
import 'package:gemu/services/date_helper.dart';

class CommentsView extends StatefulWidget {
  final Post post;

  CommentsView({required this.post});

  @override
  CommentsViewState createState() => CommentsViewState();
}

class CommentsViewState extends State<CommentsView>
    with WidgetsBindingObserver {
  TextEditingController _commentController = TextEditingController();

  bool isComment = false;

  hideKeyboard() {
    setState(() {
      isComment = !isComment;
    });
    FocusScope.of(context).requestFocus(FocusNode());
  }

  publishComment(int commentCount) async {
    DocumentSnapshot<Map<String, dynamic>> userdoc =
        await FirebaseFirestore.instance.collection('users').doc(me!.uid).get();

    int date = DateTime.now().millisecondsSinceEpoch.toInt();

    widget.post.reference
        .collection('comments')
        .doc('Comment${userdoc.id}$date')
        .set({
      'username': userdoc.data()!['username'],
      'uid': userdoc.id,
      'profilpicture': userdoc.data()!['imageUrl'],
      'comment': _commentController.text,
      'upcount': 0,
      'downcount': 0,
      'date': date,
      'id': 'Comment${userdoc.id}$date'
    });
    _commentController.clear();

    await widget.post.reference.update({'commentcount': commentCount + 1});

    DatabaseService.addNotification(
        me!.uid, widget.post.uid, "a ajouté un commentaire", "comment");

    hideKeyboard();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    print('keyboard');
    final bottomInset = WidgetsBinding.instance!.window.viewInsets.bottom;
    final newValue = bottomInset > 0.0;
    if (newValue != isComment) {
      setState(() {
        isComment = newValue;
      });
    }
    super.didChangeMetrics();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            post(),
            Expanded(
              child: commentaires(),
            )
          ],
        ),
      ),
    ));
  }

  Widget post() {
    return Container(
        color: Colors.black,
        child: Hero(
          tag: 'post',
          child: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            height: isComment ? 0 : MediaQuery.of(context).size.height / 3,
            child: Stack(
              children: [
                Center(
                  child: Image(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(widget.post.postUrl)),
                ),
              ],
            ),
          ),
        ));
  }

  Widget commentaires() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.post.id)
            .collection('comments')
            .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          return Column(
            children: [
              Container(
                height: 60,
                decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border(
                        top: BorderSide(color: Colors.white, width: 0.1),
                        bottom: BorderSide(color: Colors.white, width: 0.1))),
                alignment: Alignment.center,
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          if (isComment == true) {
                            hideKeyboard();
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        icon: Icon(Icons.arrow_back_ios)),
                    Text(
                      'Commentaires',
                      style: mystyle(14),
                    )
                  ],
                ),
              ),
              Expanded(
                  flex: 5,
                  child: Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: !snapshot.hasData
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).primaryColor,
                              ),
                            )
                          : snapshot.data.docs.length == 0
                              ? Center(
                                  child: Text(
                                    'No comments',
                                    style: mystyle(11, Colors.white60),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: snapshot.data.docs.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    Commentaire comment = Commentaire.fromMap(
                                        snapshot.data.docs[index],
                                        snapshot.data.docs[index].data());
                                    return CommentTile(
                                      post: widget.post,
                                      comment: comment,
                                    );
                                  }))),
              Expanded(
                  child: Container(
                height: 60,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Theme.of(context).shadowColor,
                    border: Border(
                        top: BorderSide(color: Colors.white, width: 0.1))),
                alignment: Alignment.center,
                child: Row(
                  children: [
                    me!.imageUrl == null
                        ? Container(
                            margin: EdgeInsets.all(3.0),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white60,
                              shape: BoxShape.circle,
                              border: Border.all(color: Color(0xFF222831)),
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
                              border: Border.all(color: Color(0xFF222831)),
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: CachedNetworkImageProvider(
                                      me!.imageUrl!)),
                            )),
                    Expanded(
                        child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: TextFormField(
                        scrollPhysics: AlwaysScrollableScrollPhysics(),
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: "Ajouter un commentaire...",
                          border: InputBorder.none,
                        ),
                      ),
                    )),
                    TextButton(
                        onPressed: () {
                          publishComment(snapshot.data.docs.length);
                        },
                        child: Text('Publish',
                            style: mystyle(15, Theme.of(context).primaryColor)))
                  ],
                ),
              ))
            ],
          );
        });
  }
}

class CommentTile extends StatefulWidget {
  final Commentaire comment;
  final Post post;

  CommentTile({required this.post, required this.comment});

  @override
  CommentTileState createState() => CommentTileState();
}

class CommentTileState extends State<CommentTile> {
  late StreamSubscription upListener;
  late StreamSubscription downListener;
  List upper = [];
  List downer = [];

  upComment(Commentaire comment) {
    comment.reference.collection('up').doc(me!.uid).get().then((upper) {
      if (!upper.exists) {
        upper.reference.set({});
        comment.reference.update({'upcount': comment.upcount + 1});
      }

      comment.reference.collection('down').doc(me!.uid).get().then((downer) {
        if (downer.exists) {
          downer.reference.delete();
          comment.reference.update({'downcount': comment.downcount - 1});
        }
      });
    });

    DatabaseService.addNotification(
        me!.uid, widget.post.uid, "a up votre commentaire", "updown");
  }

  downComment(Commentaire comment) {
    comment.reference.collection('down').doc(me!.uid).get().then((downer) {
      if (!downer.exists) {
        downer.reference.set({});
        comment.reference.update({'downcount': comment.downcount + 1});
      }
    });

    comment.reference.collection('up').doc(me!.uid).get().then((upper) {
      if (upper.exists) {
        upper.reference.delete();
        comment.reference.update({'upcount': comment.upcount - 1});
      }
    });

    DatabaseService.addNotification(
        me!.uid, widget.post.uid, "a down votre commentaire", "updown");
  }

  @override
  void initState() {
    super.initState();
    upListener =
        widget.comment.reference.collection('up').snapshots().listen((data) {
      if (upper.length != 0) {
        upper.clear();
      }
      for (var item in data.docs) {
        setState(() {
          upper.add(item.id);
        });
      }
    });
    downListener =
        widget.comment.reference.collection('down').snapshots().listen((data) {
      if (downer.length != 0) {
        downer.clear();
      }
      for (var item in data.docs) {
        setState(() {
          downer.add(item.id);
        });
      }
    });
  }

  @override
  void dispose() {
    upper.clear();
    downer.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
      child: Container(
          child: Column(
        children: [
          Container(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {},
                  child: widget.comment.profilPicture == null
                      ? Container(
                          margin: EdgeInsets.all(3.0),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).canvasColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black),
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
                            border: Border.all(color: Colors.black),
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: CachedNetworkImageProvider(
                                    widget.comment.profilPicture!)),
                          )),
                ),
                SizedBox(
                  width: 5.0,
                ),
                InkWell(
                  onTap: () {},
                  child: Text(
                    "${widget.comment.username}",
                    style: mystyle(12, Colors.white, FontWeight.w700),
                  ),
                ),
                SizedBox(
                  width: 2.5,
                ),
                Text(
                  '.',
                  style: mystyle(11),
                ),
                SizedBox(width: 2.5),
                Expanded(
                    child: Text(
                  DateHelper().datePostView(widget.comment.date),
                  style: mystyle(9),
                ))
              ],
            ),
          ),
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.only(left: 50.0),
                  child: Container(
                    alignment: Alignment.topLeft,
                    child: Text("${widget.comment.comment}",
                        style: TextStyle(color: Colors.white60)),
                  ),
                )),
                Container(
                  width: 50,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                              onTap: () => upComment(widget.comment),
                              child:
                                  (upper.length != 0 && upper.contains(me!.uid))
                                      ? Icon(
                                          Icons.arrow_upward,
                                          size: 20,
                                          color: Colors.green,
                                        )
                                      : Icon(
                                          Icons.arrow_upward_outlined,
                                          size: 20,
                                          color: Colors.white60,
                                        )),
                          InkWell(
                              onTap: () => downComment(widget.comment),
                              child: (downer.length != 0 &&
                                      downer.contains(me!.uid))
                                  ? Icon(
                                      Icons.arrow_downward,
                                      size: 20,
                                      color: Colors.red,
                                    )
                                  : Icon(
                                      Icons.arrow_downward_outlined,
                                      size: 20,
                                      color: Colors.white60,
                                    )),
                        ],
                      ),
                      SizedBox(
                        height: 3.0,
                      ),
                      Text(
                        '${(widget.comment.upcount - widget.comment.downcount)}',
                        style: mystyle(11, Colors.white),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      )),
    );
  }
}
