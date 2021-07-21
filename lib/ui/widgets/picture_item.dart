import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marquee/marquee.dart';

import 'package:gemu/models/post.dart';
import 'package:gemu/models/user.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/services/database_service.dart';
import 'package:gemu/ui/widgets/comments_view.dart';
import 'package:gemu/services/date_helper.dart';
import 'package:gemu/ui/widgets/expandable_text.dart';

class PictureItem extends StatefulWidget {
  final String idUser;
  final Post post;
  final bool isHome;

  PictureItem({required this.idUser, required this.post, this.isHome = false});

  @override
  PictureItemState createState() => PictureItemState();
}

class PictureItemState extends State<PictureItem>
    with TickerProviderStateMixin {
  static const double ActionWidgetSize = 60.0;
  static const double ActionIconSize = 35.0;
  static const double ShareActionIconSize = 25.0;
  static const double ProfileImageSize = 50.0;
  static const double PlusIconSize = 20.0;

  late Post post;
  late StreamSubscription postListener;

  late AnimationController _upController, _downController;
  late Animation _upAnimation, _downAnimation;

  late UserModel userPost;
  Game? gamePost;

  bool isFollowing = false;

  List up = [];
  List down = [];

  late String hashtags;
  late String descriptionFinal;

  @override
  void initState() {
    super.initState();

    post = widget.post;
    postListener = FirebaseFirestore.instance
        .collection('posts')
        .doc(post.id)
        .snapshots()
        .listen((data) {
      print('post listen');
      setState(() {
        post = Post.fromMap(data, data.data()!);
      });
    });

    if (post.uid != widget.idUser) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(post.uid)
          .get()
          .then((data) {
        userPost = UserModel.fromMap(data, data.data()!);
      });
      userPost.ref
          .collection('followers')
          .doc(widget.idUser)
          .get()
          .then((follower) {
        if (!follower.exists) {
          setState(() {
            isFollowing = false;
          });
        } else {
          setState(() {
            isFollowing = true;
          });
        }
      });
      updateView();
      post.reference.collection('up').get().then((upper) {
        for (var item in upper.docs) {
          up.add(item);
        }
        post.reference.collection('down').get().then((downer) {
          for (var item in downer.docs) {
            down.add(item);
          }
        });
      });
    } else {
      userPost = me!;
      setState(() {
        isFollowing = true;
      });
    }

    hashtags = concatList(post.hashtags);
    descriptionFinal = concatDescriptionHastags(post.description, hashtags);

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
    _downController.dispose();
    postListener.cancel();
    print('fin du post');
    super.dispose();
  }

  String concatList(List hashtags) {
    StringBuffer concat = StringBuffer();
    hashtags.forEach((item) {
      concat.write(' #$item');
    });
    String concatString = concat.toString();
    return concatString;
  }

  String concatDescriptionHastags(String description, String hashtags) {
    String concatString = description + '\n\n' + hashtags;
    return concatString;
  }

  updateView() async {
    post.reference.update({'viewcount': post.viewcount + 1});

    post.reference
        .collection('viewers')
        .doc(widget.idUser)
        .get()
        .then((viewer) {
      if (!viewer.exists) {
        viewer.reference.set({});
      }
    });
  }

  upPost() async {
    post.reference.collection('up').doc(widget.idUser).get().then((uper) {
      if (!uper.exists) {
        uper.reference.set({});
        post.reference.update({'upcount': post.upcount + 1});
      }
    });

    post.reference.collection('down').doc(widget.idUser).get().then((downer) {
      if (downer.exists) {
        downer.reference.delete();
        post.reference.update({'downcount': post.downcount - 1});
      }
    });

    DatabaseService.addNotification(
        widget.idUser, userPost.uid, "a up votre post", "updown");
  }

  downPost() async {
    post.reference.collection('down').doc(widget.idUser).get().then((downer) {
      if (!downer.exists) {
        downer.reference.set({});
        post.reference.update({'downcount': post.downcount + 1});
      }
    });

    post.reference.collection('up').doc(widget.idUser).get().then((upper) {
      if (upper.exists) {
        upper.reference.delete();
        post.reference.update({'upcount': post.upcount - 1});
      }
    });

    DatabaseService.addNotification(
        widget.idUser, userPost.uid, "a down votre post", "updown");
  }

  followUser() async {
    userPost.ref.collection('followers').doc(widget.idUser).get().then((user) {
      if (!user.exists) {
        user.reference.set({});
        FirebaseFirestore.instance
            .collection('users')
            .doc(widget.idUser)
            .collection('following')
            .doc(userPost.uid)
            .set({});
        DatabaseService.addNotification(
            widget.idUser, userPost.uid, "a commencé à vous suivre", "follow");

        setState(() {
          isFollowing = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int points = (post.upcount - post.downcount);
    return Hero(
      tag: 'post',
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            Center(
              child: Image(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(post.postUrl)),
            ),
            Container(
              color: Colors.black.withOpacity(0.2),
            ),
            Positioned(
                bottom: 0,
                child: Container(
                  height: MediaQuery.of(context).size.height / 1.5,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Expanded(
                          child: Row(
                        children: [
                          Expanded(child: description()),
                          actionsBar(points)
                        ],
                      )),
                      gameBar()
                    ],
                  ),
                )),
            Column(
              children: [
                Expanded(child: Container(
                  child: GestureDetector(
                    onDoubleTap: () {
                      print('upPost');
                      if (post.uid != widget.idUser) {
                        _upController.forward();
                        upPost();
                      }
                    },
                  ),
                )),
                Expanded(
                  child: Container(
                    child: GestureDetector(
                      onDoubleTap: () {
                        print('downPost');
                        if (post.uid != widget.idUser) {
                          _downController.forward();
                          downPost();
                        }
                      },
                    ),
                  ),
                )
              ],
            ),
            Center(
              child: FadeTransition(
                opacity: _upAnimation as Animation<double>,
                child: Icon(
                  Icons.arrow_upward,
                  color: Colors.green[200],
                  size: 80,
                ),
              ),
            ),
            Center(
              child: FadeTransition(
                opacity: _downAnimation as Animation<double>,
                child: Icon(
                  Icons.arrow_downward,
                  color: Colors.red[200],
                  size: 80,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget description() {
    return Container(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: EdgeInsets.only(bottom: 7.5),
          child: Card(
            color: Colors.transparent,
            shadowColor: Colors.transparent,
            child: AnimatedContainer(
                duration: Duration(seconds: 1),
                curve: Curves.bounceIn,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Card(
                            color: Colors.transparent,
                            shadowColor: Colors.transparent,
                            child: InkWell(
                                onTap: () {},
                                child: Text(userPost.username,
                                    style: mystyle(14))),
                          ),
                          SizedBox(
                            width: 2.5,
                          ),
                          Text('.', style: mystyle(11)),
                          SizedBox(
                            width: 2.5,
                          ),
                          Text(DateHelper().datePostView(post.date)),
                        ],
                      ),
                      SizedBox(
                        height: 2.5,
                      ),
                      ExpandableText(
                        descriptionFinal,
                        style: TextStyle(color: Colors.grey[300]),
                        expandText: 'Plus',
                        collapseText: 'Moins',
                        maxLines: 2,
                        onHashtagTap: (hashtags) {
                          print('one life');
                        },
                        hashtagStyle:
                            mystyle(12, Theme.of(context).primaryColor),
                      )
                    ],
                  ),
                )),
          ),
        ));
  }

  Widget actionsBar(int points) {
    return Container(
      width: MediaQuery.of(context).size.width / 4,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        _getSocialReferencement(
            iconUp: Icons.arrow_upward_outlined,
            iconDown: Icons.arrow_downward_outlined,
            title: points.toString()),
        SizedBox(
          height: 25.0,
        ),
        _getSocialAction(
            icon: Icons.insert_comment_outlined,
            title: post.commentcount.toString(),
            context: context),
        SizedBox(
          height: 25.0,
        ),
        _getViewersAction(),
        SizedBox(
          height: 25.0,
        ),
        _getMore(),
        SizedBox(
          height: 25.0,
        ),
        _getFollowAction(context: context),
      ]),
    );
  }

  Widget _getSocialReferencement(
      {required String title, IconData? iconUp, IconData? iconDown}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              color: Colors.transparent,
              shadowColor: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (post.uid != widget.idUser) {
                    upPost();
                  }
                },
                child: Icon(iconUp,
                    size: 28,
                    color: up.contains(widget.idUser)
                        ? Colors.green[200]
                        : Colors.grey[300]),
              ),
            ),
            Card(
              color: Colors.transparent,
              shadowColor: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (post.uid != widget.idUser) {
                    downPost();
                  }
                },
                child: Icon(iconDown,
                    size: 28,
                    color: down.contains(widget.idUser)
                        ? Colors.red[200]
                        : Colors.grey[300]),
              ),
            ),
          ],
        ),
        Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Card(
              color: Colors.transparent,
              shadowColor: Colors.transparent,
              child: Text(title, style: mystyle(13, Colors.white)),
            ))
      ],
    );
  }

  Widget _getSocialAction(
      {required String title, IconData? icon, required BuildContext context}) {
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      Card(
        color: Colors.transparent,
        shadowColor: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        CommentsView(post: post)));
          },
          child: Icon(icon, size: 28, color: Colors.white),
        ),
      ),
      Padding(
          padding: EdgeInsets.only(top: 2.0),
          child: Card(
              color: Colors.transparent,
              shadowColor: Colors.transparent,
              child: Text(title, style: mystyle(13, Colors.white))))
    ]);
  }

  Widget _getViewersAction() {
    return Column(
      children: [
        Card(
          color: Colors.transparent,
          shadowColor: Colors.transparent,
          child: InkWell(
            onTap: () => print('See viewers'),
            child: Icon(
              Icons.remove_red_eye_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        Card(
          color: Colors.transparent,
          shadowColor: Colors.transparent,
          child:
              Text(post.viewcount.toString(), style: mystyle(13, Colors.white)),
        ),
      ],
    );
  }

  Widget _getMore() {
    return Card(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      child: InkWell(
          onTap: () => print('More on the post'),
          child: Icon(
            Icons.more_vert_outlined,
            color: Colors.white,
            size: 26,
          )),
    );
  }

  Widget _getFollowAction({BuildContext? context}) {
    return Container(
        width: 55.0,
        height: 55.0,
        child: post.uid == widget.idUser
            ? Stack(
                children: [_getProfilePicture(context)],
              )
            : isFollowing
                ? Stack(
                    children: [_getProfilePicture(context)],
                  )
                : Stack(children: [
                    _getProfilePicture(context),
                    _getPlusIcon(context: context!)
                  ]));
  }

  Widget _getPlusIcon({required BuildContext context}) {
    return Positioned(
      bottom: 0,
      left: ((ActionWidgetSize / 2) - (PlusIconSize / 2)),
      child: GestureDetector(
        onTap: () => followUser(),
        child: Container(
            width: PlusIconSize,
            height: PlusIconSize,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).accentColor
                    ]),
                borderRadius: BorderRadius.circular(15.0)),
            child: Icon(
              Icons.add,
              color: Colors.black,
              size: 20.0,
            )),
      ),
    );
  }

  Widget _getProfilePicture(BuildContext? context) {
    return Positioned(
      left: (ActionWidgetSize / 2) - (ProfileImageSize / 2),
      child: GestureDetector(
          onTap: () => () {},
          child: userPost.imageUrl == null
              ? Container(
                  width: ProfileImageSize,
                  height: ProfileImageSize,
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
                  width: ProfileImageSize,
                  height: ProfileImageSize,
                  decoration: BoxDecoration(
                      color: Colors.white60,
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(0xFF222831)),
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image:
                              CachedNetworkImageProvider(userPost.imageUrl!))),
                )),
    );
  }

  Widget gameBar() {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      child: widget.isHome
          ? SizedBox()
          : Padding(
              padding: EdgeInsets.only(right: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 3.0),
                    child: Icon(
                      Icons.videogame_asset,
                      color: Colors.white,
                      size: 23,
                    ),
                  ),
                  Card(
                    color: Colors.transparent,
                    shadowColor: Colors.transparent,
                    child: Container(
                        height: 40,
                        width: 75,
                        child: Marquee(
                          text: post.gameName,
                          style: mystyle(13),
                          textDirection: TextDirection.ltr,
                          blankSpace: 50,
                          velocity: 30,
                        )),
                  ),
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(5.0),
                        image: DecorationImage(
                            image: CachedNetworkImageProvider(post.gameImage))),
                  )
                ],
              )),
    );
  }
}
