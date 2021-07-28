import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marquee/marquee.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:video_player/video_player.dart';

import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/models/user.dart';
import 'package:gemu/models/post.dart';
import 'package:gemu/ui/widgets/expandable_text.dart';
import 'package:gemu/services/date_helper.dart';
import 'package:gemu/ui/widgets/comments_view.dart';
import 'package:gemu/services/database_service.dart';
import 'package:gemu/ui/screens/Profil/profil_screen.dart';

class PostTile extends StatefulWidget {
  final String idUserActual;
  final Post post;
  final bool isHome;

  PostTile(
      {required this.idUserActual, required this.post, this.isHome = false});

  @override
  PostTileState createState() => PostTileState();
}

class PostTileState extends State<PostTile> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: StreamBuilder(
          stream: DefaultCacheManager().getFileStream(widget.post.postUrl),
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              );
              /*(widget.post.type == 'picture')
                  ? PictureItem(
                      postUrl: widget.post.postUrl,
                      idUserActual: widget.idUserActual,
                      post: widget.post)
                  : VideoItem(
                      videoPlayerControllerType: VideoPlayerController.network(
                          widget.post.postUrl,
                          videoPlayerOptions:
                              VideoPlayerOptions(mixWithOthers: true)),
                      idUserActual: widget.idUserActual,
                      post: widget.post);*/
            }
            return (widget.post.type == 'picture')
                ? PictureItem(
                    file: snapshot.data.file,
                    idUserActual: widget.idUserActual,
                    post: widget.post)
                : VideoItem(
                    videoPlayerControllerType: VideoPlayerController.file(
                        snapshot.data.file,
                        videoPlayerOptions:
                            VideoPlayerOptions(mixWithOthers: true)),
                    idUserActual: widget.idUserActual,
                    post: widget.post);
          }),
    );
  }
}

class PictureItem extends StatefulWidget {
  final File? file;
  final String? postUrl;
  final String idUserActual;
  final Post post;

  PictureItem(
      {this.file,
      this.postUrl,
      required this.idUserActual,
      required this.post});

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

  late AnimationController _upController, _downController;
  late Animation _upAnimation, _downAnimation;

  late Post post;
  late StreamSubscription postListener;

  late UserModel userPost;

  late String hashtags;
  late String descriptionFinal;

  bool isFollowing = false;

  late StreamSubscription upListener;
  late StreamSubscription downListener;
  List up = [];
  List down = [];

  String concatListHashtags(List hashtags) {
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

  upPost() async {
    post.reference.collection('up').doc(widget.idUserActual).get().then((uper) {
      if (!uper.exists) {
        uper.reference.set({});
        post.reference.update({'upcount': post.upcount + 1});
      }
    });

    post.reference
        .collection('down')
        .doc(widget.idUserActual)
        .get()
        .then((downer) {
      if (downer.exists) {
        downer.reference.delete();
        post.reference.update({'downcount': post.downcount - 1});
      }
    });

    DatabaseService.addNotification(
        widget.idUserActual, userPost.uid, "a up votre post", "updown");
  }

  downPost() async {
    post.reference
        .collection('down')
        .doc(widget.idUserActual)
        .get()
        .then((downer) {
      if (!downer.exists) {
        downer.reference.set({});
        post.reference.update({'downcount': post.downcount + 1});
      }
    });

    post.reference
        .collection('up')
        .doc(widget.idUserActual)
        .get()
        .then((upper) {
      if (upper.exists) {
        upper.reference.delete();
        post.reference.update({'upcount': post.upcount - 1});
      }
    });

    DatabaseService.addNotification(
        widget.idUserActual, userPost.uid, "a down votre post", "updown");
  }

  followUser() async {
    userPost.ref
        .collection('followers')
        .doc(widget.idUserActual)
        .get()
        .then((user) {
      if (!user.exists) {
        user.reference.set({});
        FirebaseFirestore.instance
            .collection('users')
            .doc(widget.idUserActual)
            .collection('following')
            .doc(userPost.uid)
            .set({});
        DatabaseService.addNotification(widget.idUserActual, userPost.uid,
            "a commencé à vous suivre", "follow");

        setState(() {
          isFollowing = true;
        });
      }
    });
  }

  updateView() async {
    post.reference.update({'viewcount': post.viewcount + 1});

    post.reference
        .collection('viewers')
        .doc(widget.idUserActual)
        .get()
        .then((viewer) {
      if (!viewer.exists) {
        viewer.reference.set({});
      }
    });
  }

  @override
  void initState() {
    super.initState();
    //écoute sur les changements du post
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

    //Prendre les infos du user du post
    if (post.uid != widget.idUserActual) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(post.uid)
          .get()
          .then((data) {
        userPost = UserModel.fromMap(data, data.data()!);
      });

      userPost.ref
          .collection('followers')
          .doc(widget.idUserActual)
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
    } else {
      userPost = me!;
    }

    //concatène les list et les différents string afin de créer une bonne description
    hashtags = concatListHashtags(post.hashtags);
    descriptionFinal = concatDescriptionHastags(post.description, hashtags);

    //Listener sur les up&down du post
    upListener = post.reference.collection('up').snapshots().listen((data) {
      if (up.length != 0) {
        up.clear();
      }
      for (var item in data.docs) {
        setState(() {
          up.add(item.id);
        });
      }
    });
    downListener = post.reference.collection('down').snapshots().listen((data) {
      if (down.length != 0) {
        down.clear();
      }
      for (var item in data.docs) {
        setState(() {
          down.add(item.id);
        });
      }
    });

    //initilisation des animations up&down sur le post
    _upController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 750));
    _upAnimation = CurvedAnimation(parent: _upController, curve: Curves.easeIn);

    _upController.addListener(() {
      if (_upController.isCompleted) {
        _upController.reverse();
      }
    });

    _downController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 750));
    _downAnimation =
        CurvedAnimation(parent: _downController, curve: Curves.easeIn);

    _downController.addListener(() {
      if (_downController.isCompleted) {
        _downController.reverse();
      }
    });
  }

  @override
  void deactivate() {
    print('deactivate');
    _upController.removeListener(() {
      if (_upController.isCompleted) {
        _upController.reverse();
      }
    });
    _downController.removeListener(() {
      if (_upController.isCompleted) {
        _upController.reverse();
      }
    });
    super.deactivate();
  }

  @override
  void dispose() {
    _upController.dispose();
    _downController.dispose();
    upListener.cancel();
    downListener.cancel();
    postListener.cancel();
    print('fin du post');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int points = (post.upcount - post.downcount);
    return Stack(
      children: [
        contentPostPicture(),
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
                  if (post.uid != widget.idUserActual) {
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
                    if (post.uid != widget.idUserActual) {
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
    );
  }

  Widget contentPostPicture() {
    return Stack(
      children: [
        Hero(
          tag: 'post${post.id}',
          child: Center(
              child: widget.file != null
                  ? Image.file(
                      widget.file!,
                      fit: BoxFit.cover,
                    )
                  : CachedNetworkImage(
                      imageUrl: widget.postUrl!,
                      fit: BoxFit.cover,
                    )),
        ),
        Container(
          color: Colors.black.withOpacity(0.2),
        ),
      ],
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
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ProfilPost(
                                                userPostID: userPost.uid,
                                              )));
                                },
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
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.0),
                          child: ExpandableText(
                            descriptionFinal,
                            style: TextStyle(color: Colors.grey[300]),
                            expandText: 'Plus',
                            collapseText: 'Moins',
                            maxLines: 2,
                            onHashtagTap: (hashtags) {
                              print('Action quand on appuie sur un hashtag');
                            },
                            hashtagStyle:
                                mystyle(12, Theme.of(context).primaryColor),
                          )),
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
                  if (post.uid != widget.idUserActual) {
                    upPost();
                  }
                },
                child: Icon(iconUp,
                    size: 28,
                    color: (up.length != 0 && up.contains(widget.idUserActual))
                        ? Colors.green[200]
                        : Colors.grey[300]),
              ),
            ),
            Card(
              color: Colors.transparent,
              shadowColor: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (post.uid != widget.idUserActual) {
                    downPost();
                  }
                },
                child: Icon(iconDown,
                    size: 28,
                    color:
                        (down.length != 0 && down.contains(widget.idUserActual))
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
                    builder: (context) => CommentsView(post: post)));
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

  Widget _getFollowAction({required BuildContext context}) {
    return Container(
        width: 55.0,
        height: 55.0,
        child: post.uid == widget.idUserActual || isFollowing
            ? _getProfilePicture(context)
            : Stack(children: [
                _getProfilePicture(context),
                _getPlusIcon(context: context)
              ]));
  }

  Widget _getProfilePicture(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProfilPost(
                      userPostID: userPost.uid,
                    )));
      },
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
                      image: CachedNetworkImageProvider(userPost.imageUrl!))),
            ),
    );
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

  Widget gameBar() {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      child: Padding(
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
                        image: CachedNetworkImageProvider(post.gameImage),
                        fit: BoxFit.cover)),
              )
            ],
          )),
    );
  }
}

class VideoItem extends StatefulWidget {
  final VideoPlayerController videoPlayerControllerType;
  final String idUserActual;
  final Post post;

  VideoItem(
      {required this.videoPlayerControllerType,
      required this.idUserActual,
      required this.post});

  @override
  VideoItemState createState() => VideoItemState();
}

class VideoItemState extends State<VideoItem> with TickerProviderStateMixin {
  static const double ActionWidgetSize = 60.0;
  static const double ActionIconSize = 35.0;
  static const double ShareActionIconSize = 25.0;
  static const double ProfileImageSize = 50.0;
  static const double PlusIconSize = 20.0;

  late AnimationController _upController, _downController;
  late Animation _upAnimation, _downAnimation;

  late Post post;
  late StreamSubscription postListener;

  late UserModel userPost;

  late String hashtags;
  late String descriptionFinal;

  bool isFollowing = false;

  late StreamSubscription upListener;
  late StreamSubscription downListener;
  List up = [];
  List down = [];

  late VideoPlayerController videoPlayerController;
  bool volumeOn = true;
  bool isNavigateComment = true;

  String concatListHashtags(List hashtags) {
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

  upPost() async {
    post.reference.collection('up').doc(widget.idUserActual).get().then((uper) {
      if (!uper.exists) {
        uper.reference.set({});
        post.reference.update({'upcount': post.upcount + 1});
      }
    });

    post.reference
        .collection('down')
        .doc(widget.idUserActual)
        .get()
        .then((downer) {
      if (downer.exists) {
        downer.reference.delete();
        post.reference.update({'downcount': post.downcount - 1});
      }
    });

    DatabaseService.addNotification(
        widget.idUserActual, userPost.uid, "a up votre post", "updown");
  }

  downPost() async {
    post.reference
        .collection('down')
        .doc(widget.idUserActual)
        .get()
        .then((downer) {
      if (!downer.exists) {
        downer.reference.set({});
        post.reference.update({'downcount': post.downcount + 1});
      }
    });

    post.reference
        .collection('up')
        .doc(widget.idUserActual)
        .get()
        .then((upper) {
      if (upper.exists) {
        upper.reference.delete();
        post.reference.update({'upcount': post.upcount - 1});
      }
    });

    DatabaseService.addNotification(
        widget.idUserActual, userPost.uid, "a down votre post", "updown");
  }

  followUser() async {
    userPost.ref
        .collection('followers')
        .doc(widget.idUserActual)
        .get()
        .then((user) {
      if (!user.exists) {
        user.reference.set({});
        FirebaseFirestore.instance
            .collection('users')
            .doc(widget.idUserActual)
            .collection('following')
            .doc(userPost.uid)
            .set({});
        DatabaseService.addNotification(widget.idUserActual, userPost.uid,
            "a commencé à vous suivre", "follow");

        setState(() {
          isFollowing = true;
        });
      }
    });
  }

  updateView() async {
    post.reference.update({'viewcount': post.viewcount + 1});

    post.reference
        .collection('viewers')
        .doc(widget.idUserActual)
        .get()
        .then((viewer) {
      if (!viewer.exists) {
        viewer.reference.set({});
      }
    });
  }

  @override
  void initState() {
    super.initState();
    videoPlayerController = widget.videoPlayerControllerType
      ..initialize().then((value) {
        if (mounted) {
          setState(() {});
          videoPlayerController.setLooping(true);
          videoPlayerController.play();
        }
      });

    //écoute sur les changements du post
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

    //Prendre les infos du user du post
    if (post.uid != widget.idUserActual) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(post.uid)
          .get()
          .then((data) {
        userPost = UserModel.fromMap(data, data.data()!);
      });

      userPost.ref
          .collection('followers')
          .doc(widget.idUserActual)
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
    } else {
      userPost = me!;
    }

    //concatène les list et les différents string afin de créer une bonne description
    hashtags = concatListHashtags(post.hashtags);
    descriptionFinal = concatDescriptionHastags(post.description, hashtags);

    //Listener sur les up&down du post
    upListener = post.reference.collection('up').snapshots().listen((data) {
      if (up.length != 0) {
        up.clear();
      }
      for (var item in data.docs) {
        setState(() {
          up.add(item.id);
        });
      }
    });
    downListener = post.reference.collection('down').snapshots().listen((data) {
      if (down.length != 0) {
        down.clear();
      }
      for (var item in data.docs) {
        setState(() {
          down.add(item.id);
        });
      }
    });

    //initilisation des animations up&down sur le post
    _upController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 750));
    _upAnimation = CurvedAnimation(parent: _upController, curve: Curves.easeIn);

    _upController.addListener(() {
      if (_upController.isCompleted) {
        _upController.reverse();
      }
    });

    _downController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 750));
    _downAnimation =
        CurvedAnimation(parent: _downController, curve: Curves.easeIn);

    _downController.addListener(() {
      if (_downController.isCompleted) {
        _downController.reverse();
      }
    });
  }

  @override
  void deactivate() {
    print('deactivate');
    _upController.removeListener(() {
      if (_upController.isCompleted) {
        _upController.reverse();
      }
    });
    _downController.removeListener(() {
      if (_upController.isCompleted) {
        _upController.reverse();
      }
    });
    super.deactivate();
  }

  @override
  void dispose() {
    _upController.dispose();
    _downController.dispose();
    upListener.cancel();
    downListener.cancel();
    postListener.cancel();
    videoPlayerController.dispose();
    print('fin du post');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int points = (post.upcount - post.downcount);
    return Stack(
      children: [
        contentPostVideo(),
        getProgressContent(),
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
                  Container(
                    height: 50,
                    child: Row(
                      children: [
                        Expanded(child: getPlayController()),
                        Expanded(child: gameBar())
                      ],
                    ),
                  )
                ],
              ),
            )),
        Column(
          children: [
            Expanded(child: Container(
              child: GestureDetector(
                onDoubleTap: () {
                  print('upPost');
                  if (post.uid != widget.idUserActual) {
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
                    if (post.uid != widget.idUserActual) {
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
    );
  }

  Widget contentPostVideo() {
    return Stack(
      children: [
        Center(
          child: videoPlayerController.value.isInitialized
              ? VisibilityDetector(
                  key: Key('visibility${widget.post.id}'),
                  child: AspectRatio(
                      aspectRatio: videoPlayerController.value.aspectRatio,
                      child: VideoPlayer(videoPlayerController)),
                  onVisibilityChanged: (VisibilityInfo info) {
                    if (info.visibleFraction == 0 && !isNavigateComment) {
                      videoPlayerController.pause();
                    } else if (info.visibleFraction == 1 &&
                        !isNavigateComment) {
                      setState(() {
                        isNavigateComment = !isNavigateComment;
                      });
                      videoPlayerController.play();
                    } else if (info.visibleFraction == 1) {
                      videoPlayerController.play();
                    }
                  })
              : CachedNetworkImage(
                  imageUrl: post.previewImage!,
                  fit: BoxFit.cover,
                ),
        ),
        Container(
          color: Colors.black.withOpacity(0.2),
        ),
      ],
    );
  }

  getPlayController() {
    return Padding(
      padding: EdgeInsets.only(left: 5.0),
      child: Card(
        color: Colors.transparent,
        shadowColor: Colors.transparent,
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                print('icon pause');
                setState(() {
                  if (videoPlayerController.value.isPlaying) {
                    videoPlayerController.pause();
                  } else {
                    videoPlayerController.play();
                  }
                });
              },
              icon: Icon(
                videoPlayerController.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                size: 23,
                color: Colors.white,
              ),
            ),
            IconButton(
                onPressed: () {
                  print('volume');
                  setState(() {
                    volumeOn = !volumeOn;
                  });

                  if (volumeOn) {
                    videoPlayerController.setVolume(1);
                  } else {
                    videoPlayerController.setVolume(0);
                  }
                },
                icon: Icon(
                  volumeOn
                      ? Icons.volume_up_outlined
                      : Icons.volume_mute_outlined,
                  size: 23,
                  color: Colors.white,
                ))
          ],
        ),
      ),
    );
  }

  Widget getProgressContent() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 8.0,
        child: VideoProgressIndicator(
          videoPlayerController,
          allowScrubbing: true,
          colors: VideoProgressColors(
              playedColor: Theme.of(context).primaryColor,
              backgroundColor: Colors.grey),
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
                                onTap: () {
                                  setState(() {
                                    isNavigateComment = false;
                                  });
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ProfilPost(
                                                userPostID: userPost.uid,
                                              )));
                                },
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
                      Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.0,
                          ),
                          child: ExpandableText(
                            descriptionFinal,
                            style: TextStyle(color: Colors.grey[300]),
                            expandText: 'Plus',
                            collapseText: 'Moins',
                            maxLines: 2,
                            onHashtagTap: (hashtags) {
                              print('Action quand on appuie sur un hashtag');
                            },
                            hashtagStyle:
                                mystyle(12, Theme.of(context).primaryColor),
                          )),
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
                  if (post.uid != widget.idUserActual) {
                    upPost();
                  }
                },
                child: Icon(iconUp,
                    size: 28,
                    color: (up.length != 0 && up.contains(widget.idUserActual))
                        ? Colors.green[200]
                        : Colors.grey[300]),
              ),
            ),
            Card(
              color: Colors.transparent,
              shadowColor: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (post.uid != widget.idUserActual) {
                    downPost();
                  }
                },
                child: Icon(iconDown,
                    size: 28,
                    color:
                        (down.length != 0 && down.contains(widget.idUserActual))
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
                  builder: (context) => CommentsView(
                      post: post, videoPlayerController: videoPlayerController),
                ));
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

  Widget _getFollowAction({required BuildContext context}) {
    return Container(
      width: 55.0,
      height: 55.0,
      child: post.uid == widget.idUserActual || isFollowing
          ? _getProfilePicture(context)
          : Stack(
              children: [_getProfilePicture(context), _getPlusIcon(context)]),
    );
  }

  Widget _getProfilePicture(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isNavigateComment = !isNavigateComment;
        });
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProfilPost(
                      userPostID: userPost.uid,
                    )));
      },
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
                      image: CachedNetworkImageProvider(userPost.imageUrl!))),
            ),
    );
  }

  Widget _getPlusIcon(BuildContext context) {
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

  Widget gameBar() {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      child: Padding(
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
                        image: CachedNetworkImageProvider(post.gameImage),
                        fit: BoxFit.cover)),
              )
            ],
          )),
    );
  }
}
