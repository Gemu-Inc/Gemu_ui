import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/services/database_service.dart';
import 'package:gemu/models/post.dart';
import 'package:gemu/models/commentaire.dart';
import 'package:gemu/models/user.dart';
import 'package:gemu/helpers/helpers.dart';
import 'package:gemu/views/Profil/profil_screen.dart';
import 'package:gemu/widgets/snack_bar_custom.dart';
import 'package:gemu/models/response.dart';

import './response_comment_screen.dart';

class CommentsView extends StatefulWidget {
  final Post post;
  final VideoPlayerController? videoPlayerController;
  final Object tagHeroPost;

  CommentsView(
      {required this.post,
      this.videoPlayerController,
      required this.tagHeroPost});

  @override
  CommentsViewState createState() => CommentsViewState();
}

class CommentsViewState extends State<CommentsView>
    with WidgetsBindingObserver {
  TextEditingController _commentController = TextEditingController();

//Partie commentaires
  bool isCommentsReload = false;
  bool isComment = false;

//Partie réponses
  List<bool> showResponses = [];
  bool isResponseReload = false;

//Variables parties commentaires qui vont être supprimés
  List<String> commentsWillDelete = [];

//Variables parties réponses qui vont être supprimés
  List<String> commentResponsesWillDelete = [];
  List<String> responsesWillDelete = [];

  showKeyboard() {
    setState(() {
      isComment = !isComment;
    });
    FocusScope.of(context).requestFocus(FocusNode());
  }

  hideKeyboard() {
    if (isComment) {
      setState(() {
        isComment = !isComment;
      });
      FocusScope.of(context).requestFocus(FocusNode());
    }
  }

  publishComment() async {
    setState(() {
      isCommentsReload = true;
    });

    int commentCount = 0;
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id)
        .get()
        .then((value) {
      commentCount = value.data()!['commentcount'];
    });

    DocumentSnapshot<Map<String, dynamic>> userdoc =
        await FirebaseFirestore.instance.collection('users').doc(me!.uid).get();

    int date = DateTime.now().millisecondsSinceEpoch.toInt();

    widget.post.reference
        .collection('comments')
        .doc('Comment${userdoc.id}$date')
        .set({
      'uid': userdoc.id,
      'comment': _commentController.text,
      'upcount': 0,
      'downcount': 0,
      'date': date,
      'id': 'Comment${userdoc.id}$date',
      'responsescount': 0
    });
    _commentController.clear();

    await widget.post.reference.update({'commentcount': commentCount + 1});

    DatabaseService.addNotification(
        me!.uid, widget.post.uid, "a ajouté un commentaire", "comment");

    hideKeyboard();

    setState(() {
      isCommentsReload = false;
    });
  }

  deleteComment() async {
    setState(() {
      isCommentsReload = true;
    });

    int commentCount = 0;
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id)
        .get()
        .then((value) {
      commentCount = value.data()!['commentcount'];
    });

    int _commentCount = commentCount;
    for (var i = 0; i < commentsWillDelete.length; i++) {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.id)
          .collection('comments')
          .doc(commentsWillDelete[i])
          .delete();

      _commentCount = _commentCount - 1;
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.id)
          .update({'commentcount': _commentCount});
    }

    setState(() {
      commentsWillDelete.clear();
      isCommentsReload = false;
    });
  }

  deleteResponse() async {
    setState(() {
      isResponseReload = true;
    });

    int responseCount = 0;
    await widget.post.reference
        .collection('comments')
        .doc(commentResponsesWillDelete[0])
        .get()
        .then((value) {
      responseCount = value.data()!['responsescount'];
    });

    int _responseCount = responseCount;
    for (var i = 0; i < responsesWillDelete.length; i++) {
      await widget.post.reference
          .collection('comments')
          .doc(commentResponsesWillDelete[0])
          .collection('responses')
          .doc(responsesWillDelete[i])
          .delete();

      _responseCount = _responseCount - 1;
      await widget.post.reference
          .collection('comments')
          .doc(commentResponsesWillDelete[0])
          .update({'responsescount': _responseCount});
    }

    setState(() {
      commentResponsesWillDelete.clear();
      responsesWillDelete.clear();
      isResponseReload = false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    print('keyboard');
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
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
            commentsWillDelete.length != 0 || responsesWillDelete.length != 0
                ? Stack(
                    children: [
                      post(),
                      commentsWillDelete.length != 0
                          ? Positioned(
                              bottom: 0,
                              child: Container(
                                height: 50.0,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.8),
                                    border: Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(5.0),
                                        topRight: Radius.circular(5.0))),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: Text(
                                          'Delete comment : ${commentsWillDelete.length}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              deleteComment();
                                            },
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.white,
                                            )),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              commentsWillDelete.clear();
                                            });
                                          },
                                          icon: Icon(Icons.clear),
                                          color: Colors.white,
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            )
                          : Positioned(
                              bottom: 0,
                              child: Container(
                                height: 50.0,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.8),
                                    border: Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(5.0),
                                        topRight: Radius.circular(5.0))),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: Text(
                                          'Delete response : ${responsesWillDelete.length}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              deleteResponse();
                                            },
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.white,
                                            )),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              commentResponsesWillDelete
                                                  .clear();
                                              responsesWillDelete.clear();
                                            });
                                          },
                                          icon: Icon(Icons.clear),
                                          color: Colors.white,
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            )
                    ],
                  )
                : post(),
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
          tag: widget.tagHeroPost,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            height: isComment ? 0 : MediaQuery.of(context).size.height / 3,
            child: Stack(
              children: [
                Center(
                  child: widget.post.type == 'picture'
                      ? CachedNetworkImage(imageUrl: widget.post.postUrl)
                      : AspectRatio(
                          aspectRatio:
                              widget.videoPlayerController!.value.aspectRatio,
                          child: VideoPlayer(widget.videoPlayerController!)),
                ),
              ],
            ),
          ),
        ));
  }

  Widget commentaires() {
    return Column(
      children: [
        Container(
          height: 60,
          decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                  top: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      width: 0.1),
                  bottom: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      width: 0.1))),
          alignment: Alignment.center,
          child: Row(
            children: [
              IconButton(
                  onPressed: () {
                    if (isComment) {
                      hideKeyboard();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  icon: Icon(Icons.arrow_back_ios)),
              Text(
                'Commentaires',
                style: Theme.of(context).textTheme.bodySmall,
              )
            ],
          ),
        ),
        Expanded(
            flex: isComment ? 4 : 6,
            child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(widget.post.id)
                      .collection('comments')
                      .orderBy('date', descending: true)
                      .snapshots(),
                  builder: (_, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData || isCommentsReload) {
                      if (showResponses.length != 0) {
                        showResponses.clear();
                      }
                      return Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                          strokeWidth: 1.5,
                        ),
                      );
                    }

                    if (snapshot.data.docs.length == 0) {
                      return Center(
                        child: Text(
                          'No comments',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    }

                    return ListView.builder(
                        physics: AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics()),
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          Commentaire comment = Commentaire.fromMap(
                              snapshot.data.docs[index],
                              snapshot.data.docs[index].data());
                          showResponses.add(false);

                          return Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 5.0),
                              child: GestureDetector(
                                onLongPress: () {
                                  if (commentsWillDelete.contains(comment.id)) {
                                    commentsWillDelete.remove(comment.id);
                                    setState(() {});
                                  } else {
                                    if (me!.uid == comment.uid &&
                                        commentResponsesWillDelete.length ==
                                            0) {
                                      commentsWillDelete.add(comment.id);
                                      setState(() {});
                                      hideKeyboard();
                                    }
                                  }
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: commentsWillDelete
                                                .contains(comment.id)
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Colors.transparent),
                                    child: Column(
                                      children: [
                                        CommentTile(
                                          comment: comment,
                                        ),
                                        if (comment.responsescount != 0)
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                1.5,
                                            alignment: Alignment.topCenter,
                                            child: Column(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      showResponses[index] =
                                                          !showResponses[index];
                                                    });
                                                  },
                                                  child: Container(
                                                      height: 25,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Container(
                                                            height: 1,
                                                            width: 50,
                                                            color: Colors.white,
                                                          ),
                                                          Text(
                                                            showResponses[index]
                                                                ? 'Cacher ${comment.responsescount} réponses'
                                                                : 'Voir ${comment.responsescount} réponses',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodySmall,
                                                          ),
                                                          Container(
                                                            height: 1,
                                                            width: 50,
                                                            color: Colors.white,
                                                          ),
                                                        ],
                                                      )),
                                                ),
                                                if (showResponses[index])
                                                  StreamBuilder(
                                                      stream: comment.reference
                                                          .collection(
                                                              'responses')
                                                          .orderBy('date',
                                                              descending: false)
                                                          .snapshots(),
                                                      builder: (_,
                                                          AsyncSnapshot
                                                              snapshot) {
                                                        if (!snapshot.hasData ||
                                                            (commentResponsesWillDelete
                                                                    .contains(
                                                                        comment
                                                                            .id) &&
                                                                isResponseReload)) {
                                                          return Container(
                                                            height: 30.0,
                                                            width: 30.0,
                                                            child: Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                                strokeWidth:
                                                                    1.5,
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                        return ListView.builder(
                                                            physics:
                                                                NeverScrollableScrollPhysics(),
                                                            shrinkWrap: true,
                                                            itemCount: snapshot
                                                                .data
                                                                .docs
                                                                .length,
                                                            itemBuilder:
                                                                (_, index) {
                                                              Response
                                                                  response =
                                                                  Response.fromMap(
                                                                      snapshot.data
                                                                              .docs[
                                                                          index],
                                                                      snapshot
                                                                          .data
                                                                          .docs[
                                                                              index]
                                                                          .data());

                                                              return Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child:
                                                                    Container(
                                                                        color: responsesWillDelete.contains(response.id)
                                                                            ? Theme.of(context)
                                                                                .primaryColor
                                                                            : Colors
                                                                                .transparent,
                                                                        child:
                                                                            GestureDetector(
                                                                          onLongPress:
                                                                              () {
                                                                            if (responsesWillDelete.contains(response.id)) {
                                                                              responsesWillDelete.remove(response.id);
                                                                              if (responsesWillDelete.length == 0) {
                                                                                commentResponsesWillDelete.clear();
                                                                              }
                                                                              setState(() {});
                                                                            } else {
                                                                              if (response.uid == me!.uid && commentsWillDelete.length == 0 && (commentResponsesWillDelete.contains(comment.id) || commentResponsesWillDelete.length == 0)) {
                                                                                responsesWillDelete.add(response.id);
                                                                                commentResponsesWillDelete.add(comment.id);
                                                                                setState(() {});
                                                                              }
                                                                            }
                                                                          },
                                                                          child:
                                                                              ResponseTile(
                                                                            response:
                                                                                response,
                                                                            comment:
                                                                                comment,
                                                                          ),
                                                                        )),
                                                              );
                                                            });
                                                      })
                                              ],
                                            ),
                                          )
                                      ],
                                    )),
                              ));
                        });
                  },
                ))),
        Expanded(
          child: Container(
            height: 60,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Theme.of(context).shadowColor,
                border: Border(
                    top: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        width: 0.1))),
            alignment: Alignment.center,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.0),
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
                        cursorColor: Theme.of(context).colorScheme.primary,
                        textInputAction: TextInputAction.go,
                        onFieldSubmitted: (value) {
                          value = _commentController.text;
                          if (value.isEmpty) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBarCustom(
                              context: context,
                              error: 'Comment should not be empty',
                            ));
                          } else {
                            publishComment();
                          }
                        },
                        decoration: InputDecoration(
                          hintText: "Ajouter un commentaire...",
                          border: InputBorder.none,
                        ),
                      ),
                    )),
                    IconButton(
                        onPressed: () {
                          if (_commentController.text.isEmpty) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBarCustom(
                              context: context,
                              error: 'Comment should not be empty',
                            ));
                          } else {
                            publishComment();
                          }
                        },
                        icon: Icon(
                          Icons.send_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ))
                  ],
                )),
          ),
        )
      ],
    );
  }
}

class CommentTile extends StatefulWidget {
  final Commentaire comment;

  CommentTile({required this.comment});

  @override
  CommentTileState createState() => CommentTileState();
}

class CommentTileState extends State<CommentTile> {
  late StreamSubscription upListener;
  late StreamSubscription downListener;
  List upper = [];
  List downer = [];

  bool showResponses = false;

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
        me!.uid, widget.comment.uid, "a up votre commentaire", "updown");
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
        me!.uid, widget.comment.uid, "a down votre commentaire", "updown");
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
    upListener.cancel();
    downListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.comment.uid)
            .get(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return SizedBox();
          }
          UserModel userComment =
              UserModel.fromMap(snapshot.data, snapshot.data.data());
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
                child: Container(
                    child: GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              ProfilUser(userPostID: userComment.uid))),
                  child: userComment.imageUrl != null
                      ? Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              color: Theme.of(context).canvasColor,
                              border: Border.all(color: Colors.black),
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                      userComment.imageUrl!),
                                  fit: BoxFit.cover)),
                        )
                      : Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).canvasColor,
                            border: Border.all(color: Colors.black),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.person, color: Colors.black),
                        ),
                )),
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 25.0,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      ProfilUser(userPostID: userComment.uid))),
                          child: Text(
                            userComment.username,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Text('-'),
                        SizedBox(
                          width: 5.0,
                        ),
                        Text(
                          Helpers.datePostView(widget.comment.date),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Text(widget.comment.comment,
                              style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white60
                                      : Colors.black87))),
                      Container(
                        width: 50,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () => upComment(widget.comment),
                                  child: Icon(Icons.arrow_upward,
                                      color: upper.contains(me!.uid)
                                          ? Colors.green[200]
                                          : Colors.grey,
                                      size: 17),
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                GestureDetector(
                                  onTap: () => downComment(widget.comment),
                                  child: Icon(Icons.arrow_downward,
                                      color: downer.contains(me!.uid)
                                          ? Colors.red
                                          : Colors.grey,
                                      size: 17),
                                )
                              ],
                            ),
                            Text(
                              (upper.length - downer.length).toString(),
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  Container(
                    height: 25,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => upComment(widget.comment),
                          child: Text(
                            'Up',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Text('-'),
                        SizedBox(
                          width: 5.0,
                        ),
                        GestureDetector(
                          onTap: () => downComment(widget.comment),
                          child: Text(
                            'Down',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Text('-'),
                        SizedBox(
                          width: 5.0,
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ResponseCommentScreen(
                                      comment: widget.comment,
                                      upper: upper,
                                      downer: downer))),
                          child: Text(
                            'Répondre',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ))
            ],
          );
        });
  }
}
