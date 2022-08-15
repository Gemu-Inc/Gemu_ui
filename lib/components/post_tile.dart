import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gemu/models/hashtag.dart';
import 'package:gemu/views/Games/profile_game_screen.dart';
import 'package:gemu/views/Post/Hashtags/hashtags_screen.dart';
import 'package:marquee/marquee.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:video_player/video_player.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/models/post.dart';
import 'package:gemu/components/expandable_text.dart';
import 'package:gemu/helpers/helpers.dart';
import 'package:gemu/views/Post/Comments/comments_screen.dart';
import 'package:gemu/services/database_service.dart';
import 'package:gemu/views/Profil/profil_screen.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/models/user.dart';

class PostTile extends StatefulWidget {
  final String idUserActual;
  final Post post;
  final double positionDescriptionBar;
  final double positionActionsBar;
  final bool isGameBar;
  final bool isFollowingsSection;

  PostTile(
      {required this.idUserActual,
      required this.post,
      required this.positionDescriptionBar,
      required this.positionActionsBar,
      required this.isGameBar,
      required this.isFollowingsSection});

  @override
  PostTileState createState() => PostTileState();
}

class PostTileState extends State<PostTile> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1.0),
      child: Container(
        color: Colors.black,
        child: StreamBuilder(
            stream: DefaultCacheManager().getFileStream(widget.post.postUrl),
            builder: (context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox();
              }
              return (widget.post.type == 'picture')
                  ? PictureItem(
                      file: snapshot.data.file,
                      idUserActual: widget.idUserActual,
                      post: widget.post,
                      positionDescriptionBar: widget.positionDescriptionBar,
                      positionActionsBar: widget.positionActionsBar,
                      isGameBar: widget.isGameBar,
                      isFollowingsSection: widget.isFollowingsSection,
                    )
                  : VideoItem(
                      videoPlayerController: VideoPlayerController.file(
                          snapshot.data.file,
                          videoPlayerOptions:
                              VideoPlayerOptions(mixWithOthers: true)),
                      idUserActual: widget.idUserActual,
                      post: widget.post,
                      positionDescriptionBar: widget.positionDescriptionBar,
                      positionActionsBar: widget.positionActionsBar,
                      isGameBar: widget.isGameBar,
                      isFollowingsSection: widget.isFollowingsSection,
                    );
            }),
      ),
    );
  }
}

class PictureItem extends StatefulWidget {
  final File? file;
  final String? postUrl;
  final String idUserActual;
  final Post post;
  final double positionDescriptionBar;
  final double positionActionsBar;
  final bool isGameBar;
  final bool isFollowingsSection;

  PictureItem(
      {this.file,
      this.postUrl,
      required this.idUserActual,
      required this.post,
      required this.positionDescriptionBar,
      required this.positionActionsBar,
      required this.isGameBar,
      required this.isFollowingsSection});

  @override
  PictureItemState createState() => PictureItemState();
}

class PictureItemState extends State<PictureItem>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  static const double ActionWidgetSize = 60.0;
  static const double ActionIconSize = 35.0;
  static const double ShareActionIconSize = 25.0;
  static const double ProfileImageSize = 45.0;
  static const double PlusIconSize = 20.0;

  late AnimationController _upController, _downController;
  late Animation _upAnimation, _downAnimation;

  late Post post;
  late StreamSubscription postListener;

  late String hashtags;
  late String descriptionFinal;

  bool isFollowing = false;

  late StreamSubscription upListener;
  late StreamSubscription downListener;
  List up = [];
  List down = [];

  late Object tagHeroPost;

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

  // getUserPost() async {
  //   await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(widget.post.uid)
  //       .get()
  //       .then((userData) {
  //     userPost = UserModel.fromMap(userData, userData.data()!);
  //   });
  // }

  upPost() async {
    post.reference!
        .collection('up')
        .doc(widget.idUserActual)
        .get()
        .then((uper) {
      if (!uper.exists) {
        uper.reference.set({});
        post.reference!.update({'upCount': post.upCount + 1});
      }
    });

    post.reference!
        .collection('down')
        .doc(widget.idUserActual)
        .get()
        .then((downer) {
      if (downer.exists) {
        downer.reference.delete();
        post.reference!.update({'downCount': post.downCount - 1});
      }
    });

    DatabaseService.addNotification(
        widget.idUserActual, post.uid, "a up votre post", "updown");
  }

  downPost() async {
    post.reference!
        .collection('down')
        .doc(widget.idUserActual)
        .get()
        .then((downer) {
      if (!downer.exists) {
        downer.reference.set({});
        post.reference!.update({'downCount': post.downCount + 1});
      }
    });

    post.reference!
        .collection('up')
        .doc(widget.idUserActual)
        .get()
        .then((upper) {
      if (upper.exists) {
        upper.reference.delete();
        post.reference!.update({'upCount': post.upCount - 1});
      }
    });

    DatabaseService.addNotification(
        widget.idUserActual, post.uid, "a down votre post", "updown");
  }

  followPublicUser() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(post.uid)
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
            .doc(post.uid)
            .set({});
        DatabaseService.addNotification(widget.idUserActual, post.uid,
            "a commencé à vous suivre", "follow");

        setState(() {
          isFollowing = true;
        });
      }
    });
  }

  // followPrivateUser() async {
  //   userPost.ref!.collection('followers').doc(me!.uid).get().then((user) {
  //     if (!user.exists) {
  //       DatabaseService.addNotification(
  //           me!.uid, userPost.uid, "voudrait vous suivre", "follow");

  //       setState(() {
  //         isFollowing = true;
  //       });
  //     }
  //   });
  // }

  showMorePostBottomSheet() {
    return showMaterialModalBottomSheet(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
        ),
        context: context,
        builder: (_) {
          return Container(
            height: MediaQuery.of(context).size.height / 2,
            child: Column(
              children: [
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black,
                            blurRadius: 1.0,
                            spreadRadius: 1.0,
                            offset: Offset(0.0, 1.0))
                      ]),
                  child: Padding(
                    padding: EdgeInsets.only(left: 5.0),
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.arrow_back_ios)),
                        Text(
                          'More',
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                    child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: Center(
                    child: ListView(
                      physics: AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      children: [
                        ListTile(
                          onTap: () => print('Signaler'),
                          leading: Icon(Icons.flag),
                          title: Text(
                            'Signaler',
                          ),
                        ),
                        ListTile(
                          onTap: () => print('Pas interessé'),
                          leading: Icon(Icons.not_interested_rounded),
                          title: Text(
                            'Pas interessé',
                          ),
                        ),
                        ListTile(
                          onTap: () => print('Copy'),
                          leading: Icon(Icons.copy),
                          title: Text(
                            'Copier le lien',
                          ),
                        ),
                        ListTile(
                          onTap: () => print('Follow/Unfollow'),
                          leading: Icon(Icons.add),
                          title: Text(
                            'Follow',
                          ),
                        ),
                        ListTile(
                          onTap: () => print('About account'),
                          leading: Icon(Icons.account_box),
                          title: Text(
                            'A propos du compte',
                          ),
                        ),
                      ],
                    ),
                  ),
                ))
              ],
            ),
          );
        });
  }

  String generateRandomString(int len) {
    var r = Random();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
        .join();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    post = widget.post;

    tagHeroPost = 'post' + post.id + generateRandomString(6);

    //écoute sur les changements du post
    postListener = FirebaseFirestore.instance
        .collection('posts')
        .doc(post.id)
        .snapshots()
        .listen((data) async {
      print('post listen');
      DocumentSnapshot<Map<String, dynamic>> dataUser = await FirebaseFirestore
          .instance
          .collection("users")
          .doc(data.data()!["uid"])
          .get();
      DocumentSnapshot<Map<String, dynamic>> dataGame = await FirebaseFirestore
          .instance
          .collection("games")
          .doc("verified")
          .collection("games_verified")
          .doc(data.data()!["idGame"])
          .get();
      setState(() {
        post = Post.fromMap(
            data, data.data()!, dataUser.data()!, dataGame.data()!);
      });
    });

    //Prendre les infos du user du post
    // if (post.uid != widget.idUserActual) {
    //   print("je rentre");
    //   FirebaseFirestore.instance
    //       .collection('users')
    //       .doc(post.uid)
    //       .collection('followers')
    //       .doc(widget.idUserActual)
    //       .get()
    //       .then((follower) async {
    //     if (post.uid != me!.uid) {
    //       // getUserPost();
    //     } else {
    //       // userPost = me!;
    //     }
    //     await Future.delayed(Duration(milliseconds: 500));
    //     if (!follower.exists) {
    //       if (userPost.privacy == 'private') {
    //         await FirebaseFirestore.instance
    //             .collection('notifications')
    //             .doc(userPost.uid)
    //             .collection('singleNotif')
    //             .where('from', isEqualTo: me!.uid)
    //             .where('type', isEqualTo: 'follow')
    //             .where('seen', isEqualTo: false)
    //             .limit(1)
    //             .get()
    //             .then((data) {
    //           if (data.docs.length == 0) {
    //             setState(() {
    //               isFollowing = false;
    //             });
    //           } else {
    //             setState(() {
    //               isFollowing = true;
    //             });
    //           }
    //         });
    //       } else {
    //         setState(() {
    //           isFollowing = false;
    //         });
    //       }
    //     } else {
    //       setState(() {
    //         isFollowing = true;
    //       });
    //     }
    //   });
    // }

    //concatène les list et les différents string afin de créer une bonne description
    // hashtags = concatListHashtags(post.hashtags);
    hashtags = "";
    descriptionFinal = concatDescriptionHastags(post.description, hashtags);

    //game du post
    // FirebaseFirestore.instance
    //     .collection('games')
    //     .doc('verified')
    //     .collection('games_verified')
    //     .doc(post.idGame)
    //     .get()
    //     .then((gameDoc) => game = Game.fromMap(gameDoc, gameDoc.data()!));

    //Listener sur les up&down du post
    upListener = post.reference!.collection('up').snapshots().listen((data) {
      if (up.length != 0) {
        up.clear();
      }
      for (var item in data.docs) {
        setState(() {
          up.add(item.id);
        });
      }
    });
    downListener =
        post.reference!.collection('down').snapshots().listen((data) {
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
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _upAnimation = CurvedAnimation(parent: _upController, curve: Curves.easeIn);

    _upController.addListener(() {
      if (_upController.isCompleted) {
        _upController.reverse();
      }
    });

    _downController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
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
    super.build(context);
    int points = (post.upCount - post.downCount);

    return Stack(
      children: [
        contentPostPicture(),
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Expanded(
                  child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [Expanded(child: description()), actionsBar(points)],
              )),
              widget.isGameBar
                  ? gameBar()
                  : SizedBox(
                      height: MediaQuery.of(context).size.height / 11,
                    )
            ],
          ),
        ),
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
              color: Colors.red,
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
          tag: tagHeroPost,
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
        alignment: Alignment.bottomCenter,
        height: MediaQuery.of(context).size.height / 1.5,
        child: Padding(
          padding: EdgeInsets.only(bottom: widget.positionDescriptionBar),
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
                      if (!widget.isGameBar && widget.isFollowingsSection)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Container(
                            height: 30.0,
                            width: MediaQuery.of(context).size.width / 2.5,
                            child: Row(
                              children: [
                                Icon(Icons.videogame_asset,
                                    color: Colors.white, size: 18),
                                Expanded(
                                    child: Marquee(
                                  text: post.gamePost!["name"],
                                  blankSpace: 50.0,
                                  velocity: 30.0,
                                )),
                                GestureDetector(
                                  // onTap: () => Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (_) => ProfileGameScreen(
                                  //               game: Game.fromMap(, data),
                                  //               navKey: navHomeAuthKey,
                                  //             ))),
                                  child: Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).canvasColor,
                                        border: Border.all(color: Colors.black),
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        image: DecorationImage(
                                            image: CachedNetworkImageProvider(
                                                post.gamePost!["imageUrl"]),
                                            fit: BoxFit.cover)),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
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
                                          builder: (context) => ProfilUser(
                                                userPostID: post.uid,
                                              )));
                                },
                                child: Text(
                                  post.userPost!["username"],
                                )),
                          ),
                          SizedBox(
                            width: 2.5,
                          ),
                          Text('.'),
                          SizedBox(
                            width: 2.5,
                          ),
                          Text(
                            Helpers.datePostView(post.date),
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 2.5,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        child: ExpandableText(
                          descriptionFinal,
                          style: TextStyle(color: Colors.white),
                          expandText: 'Plus',
                          collapseText: 'Moins',
                          maxLines: 2,
                          onHashtagTap: (hashtag) async {
                            late Hashtag tag;
                            await FirebaseFirestore.instance
                                .collection('hashtags')
                                .doc(hashtag)
                                .get()
                                .then((hashtagData) => tag = Hashtag.fromMap(
                                    hashtagData, hashtagData.data()!));
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        HashtagsScreen(hashtag: tag)));
                          },
                          // hashtagStyle:  mystyle(12, Theme.of(context).primaryColor),
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ));
  }

  Widget actionsBar(int points) {
    return Container(
      height: MediaQuery.of(context).size.height / 1.5,
      width: MediaQuery.of(context).size.width / 4,
      child: Padding(
        padding: EdgeInsets.only(bottom: widget.positionActionsBar),
        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          _getSocialReferencement(
              iconUp: Icons.arrow_upward_outlined,
              iconDown: Icons.arrow_downward_outlined,
              title: points.toString()),
          SizedBox(
            height: 35.0,
          ),
          _getSocialAction(
              icon: Icons.insert_comment_outlined,
              title: post.commentCount.toString(),
              context: context),
          SizedBox(
            height: 35.0,
          ),
          _getMore(),
          SizedBox(
            height: 35.0,
          ),
          _getFollowAction(context: context),
        ]),
      ),
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
                            ? Colors.red
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
              child: Text(title),
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
                          post: post,
                          tagHeroPost: tagHeroPost,
                        )));
          },
          child: Icon(icon, size: 28, color: Colors.white),
        ),
      ),
      Padding(
          padding: EdgeInsets.only(top: 2.0),
          child: Card(
              color: Colors.transparent,
              shadowColor: Colors.transparent,
              child: Text(title)))
    ]);
  }

  Widget _getMore() {
    return Card(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      child: InkWell(
          onTap: () => showMorePostBottomSheet(),
          child: Icon(
            Icons.more_vert_outlined,
            color: Colors.white,
            size: 26,
          )),
    );
  }

  Widget _getFollowAction({required BuildContext context}) {
    return Container(
        width: ProfileImageSize + 5.0,
        height: ProfileImageSize + 7.5,
        child: post.uid == widget.idUserActual || isFollowing
            ? _getProfilePicture(context)
            : Stack(children: [
                _getProfilePicture(context),
                _getPlusIcon(context: context)
              ]));
  }

  Widget _getProfilePicture(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfilUser(
                        userPostID: post.uid,
                      )));
        },
        child: post.userPost!["imageUrl"] == null
            ? Container(
                width: ProfileImageSize,
                height: ProfileImageSize,
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black),
                ),
                child: Icon(
                  Icons.person,
                  size: 30,
                ))
            : Container(
                width: ProfileImageSize,
                height: ProfileImageSize,
                decoration: BoxDecoration(
                    color: Colors.white60,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black),
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(
                            post.userPost!["imageUrl"]))),
              ),
      ),
    );
  }

  Widget _getPlusIcon({required BuildContext context}) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        onTap: () {
          // if (userPost.privacy == 'public') {
          //   followPublicUser();
          // } else {
          //   followPrivateUser();
          // }
        },
        child: Container(
            width: PlusIconSize,
            height: PlusIconSize,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary
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
      height: MediaQuery.of(context).size.height / 11,
      width: MediaQuery.of(context).size.width,
      child: Padding(
          padding: EdgeInsets.only(
              right: (MediaQuery.of(context).size.width / 4) / 3.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.videogame_asset,
                color: Colors.white,
                size: 23,
              ),
              Container(
                  padding: EdgeInsets.zero,
                  width: MediaQuery.of(context).size.width / 4,
                  child: Marquee(
                    text: post.gamePost!["name"],
                    textDirection: TextDirection.ltr,
                    blankSpace: 50,
                    velocity: 30,
                  )),
              Container(
                padding: EdgeInsets.zero,
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(5.0),
                    image: DecorationImage(
                        image: CachedNetworkImageProvider(
                            post.gamePost!["imageUrl"]),
                        fit: BoxFit.cover)),
                child: GestureDetector(
                    // onTap: () => Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (_) => ProfileGameScreen(
                    //               game: game,
                    //               navKey: navHomeAuthKey,
                    //             ))),
                    ),
              )
            ],
          )),
    );
  }
}

class VideoItem extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  final String idUserActual;
  final Post post;
  final double positionDescriptionBar;
  final double positionActionsBar;
  final bool isGameBar;
  final bool isFollowingsSection;

  VideoItem(
      {required this.videoPlayerController,
      required this.idUserActual,
      required this.post,
      required this.positionDescriptionBar,
      required this.positionActionsBar,
      required this.isGameBar,
      required this.isFollowingsSection});

  @override
  VideoItemState createState() => VideoItemState();
}

class VideoItemState extends State<VideoItem> with TickerProviderStateMixin {
  static const double ActionWidgetSize = 60.0;
  static const double ActionIconSize = 35.0;
  static const double ShareActionIconSize = 25.0;
  static const double ProfileImageSize = 45.0;
  static const double PlusIconSize = 20.0;

  late VideoPlayerController videoPlayerController;

  late AnimationController _upController, _downController;
  late Animation _upAnimation, _downAnimation;

  late UserModel userPost;
  late Post post;
  late StreamSubscription postListener;

  late String hashtags;
  late String descriptionFinal;

  late Game game;

  bool isFollowing = false;

  late StreamSubscription upListener;
  late StreamSubscription downListener;
  List up = [];
  List down = [];

  bool volumeOn = true;
  bool isNavigateComment = false;

  late Object tagHeroPost;

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

  getUserPost() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.post.uid)
        .get()
        .then((userData) {
      userPost = UserModel.fromMap(userData, userData.data()!);
    });
  }

  upPost() async {
    post.reference!
        .collection('up')
        .doc(widget.idUserActual)
        .get()
        .then((uper) {
      if (!uper.exists) {
        uper.reference.set({});
        post.reference!.update({'upCount': post.upCount + 1});
      }
    });

    post.reference!
        .collection('down')
        .doc(widget.idUserActual)
        .get()
        .then((downer) {
      if (downer.exists) {
        downer.reference.delete();
        post.reference!.update({'downCount': post.downCount - 1});
      }
    });

    DatabaseService.addNotification(
        widget.idUserActual, post.uid, "a up votre post", "updown");
  }

  downPost() async {
    post.reference!
        .collection('down')
        .doc(widget.idUserActual)
        .get()
        .then((downer) {
      if (!downer.exists) {
        downer.reference.set({});
        post.reference!.update({'downCount': post.downCount + 1});
      }
    });

    post.reference!
        .collection('up')
        .doc(widget.idUserActual)
        .get()
        .then((upper) {
      if (upper.exists) {
        upper.reference.delete();
        post.reference!.update({'upCount': post.upCount - 1});
      }
    });

    DatabaseService.addNotification(
        widget.idUserActual, post.uid, "a down votre post", "updown");
  }

  followPublicUser() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(post.uid)
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
            .doc(post.uid)
            .set({});
        DatabaseService.addNotification(widget.idUserActual, post.uid,
            "a commencé à vous suivre", "follow");

        setState(() {
          isFollowing = true;
        });
      }
    });
  }

  followPrivateUser() async {
    userPost.ref!.collection('followers').doc(me!.uid).get().then((user) {
      if (!user.exists) {
        DatabaseService.addNotification(
            me!.uid, userPost.uid, "voudrait vous suivre", "follow");

        setState(() {
          isFollowing = true;
        });
      }
    });
  }

  showMorePostBottomSheet() {
    return showMaterialModalBottomSheet(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
        ),
        context: context,
        builder: (_) {
          return Container(
            height: MediaQuery.of(context).size.height / 2,
            child: Column(
              children: [
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black,
                            blurRadius: 1.0,
                            spreadRadius: 1.0,
                            offset: Offset(0.0, 1.0))
                      ]),
                  child: Padding(
                    padding: EdgeInsets.only(left: 5.0),
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.arrow_back_ios)),
                        Text(
                          'More',
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                    child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: Center(
                    child: ListView(
                      physics: AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      children: [
                        ListTile(
                          onTap: () => print('Signaler'),
                          leading: Icon(Icons.flag),
                          title: Text(
                            'Signaler',
                          ),
                        ),
                        ListTile(
                          onTap: () => print('Pas interessé'),
                          leading: Icon(Icons.not_interested_rounded),
                          title: Text(
                            'Pas interessé',
                          ),
                        ),
                        ListTile(
                          onTap: () => print('Copy'),
                          leading: Icon(Icons.copy),
                          title: Text(
                            'Copier le lien',
                          ),
                        ),
                        ListTile(
                          onTap: () => print('Follow/Unfollow'),
                          leading: Icon(Icons.add),
                          title: Text(
                            'Follow',
                          ),
                        ),
                        ListTile(
                          onTap: () => print('About account'),
                          leading: Icon(Icons.account_box),
                          title: Text(
                            'A propos du compte',
                          ),
                        ),
                      ],
                    ),
                  ),
                ))
              ],
            ),
          );
        });
  }

  String generateRandomString(int len) {
    var r = Random();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
        .join();
  }

  @override
  void initState() {
    super.initState();

    videoPlayerController = widget.videoPlayerController
      ..setLooping(true)
      ..initialize().then((_) {
        setState(() {});
      });

    //écoute sur les changements du post
    post = widget.post;

    tagHeroPost = 'post' + post.id + generateRandomString(6);
    print('tagHero: $tagHeroPost');

    postListener = FirebaseFirestore.instance
        .collection('posts')
        .doc(post.id)
        .snapshots()
        .listen((data) async {
      print('post listen');
      DocumentSnapshot<Map<String, dynamic>> dataUser = await FirebaseFirestore
          .instance
          .collection("users")
          .doc(data.data()!["uid"])
          .get();
      DocumentSnapshot<Map<String, dynamic>> dataGame = await FirebaseFirestore
          .instance
          .collection("games")
          .doc("verified")
          .collection("games_verified")
          .doc(data.data()!["idGame"])
          .get();
      setState(() {
        post = Post.fromMap(
            data, data.data()!, dataUser.data()!, dataGame.data()!);
      });
    });

    //Prendre les infos du user du post
    if (post.uid != widget.idUserActual) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(post.uid)
          .collection('followers')
          .doc(widget.idUserActual)
          .get()
          .then((follower) async {
        if (post.uid != me!.uid) {
          getUserPost();
        } else {
          userPost = me!;
        }
        await Future.delayed(Duration(milliseconds: 500));
        if (!follower.exists) {
          if (userPost.privacy == 'private') {
            await FirebaseFirestore.instance
                .collection('notifications')
                .doc(userPost.uid)
                .collection('singleNotif')
                .where('from', isEqualTo: me!.uid)
                .where('type', isEqualTo: 'follow')
                .where('seen', isEqualTo: false)
                .limit(1)
                .get()
                .then((data) {
              if (data.docs.length == 0) {
                setState(() {
                  isFollowing = false;
                });
              } else {
                setState(() {
                  isFollowing = true;
                });
              }
            });
          } else {
            setState(() {
              isFollowing = false;
            });
          }
        } else {
          setState(() {
            isFollowing = true;
          });
        }
      });
    }

    //concatène les list et les différents string afin de créer une bonne description
    // hashtags = concatListHashtags(post.hashtags);
    hashtags = "";
    descriptionFinal = concatDescriptionHastags(post.description, hashtags);

    //Game du post
    FirebaseFirestore.instance
        .collection('games')
        .doc(post.idGame)
        .get()
        .then((gameDoc) => game = Game.fromMap(gameDoc, gameDoc.data()!));

    //Listener sur les up&down du post
    upListener = post.reference!.collection('up').snapshots().listen((data) {
      if (up.length != 0) {
        up.clear();
      }
      for (var item in data.docs) {
        setState(() {
          up.add(item.id);
        });
      }
    });
    downListener =
        post.reference!.collection('down').snapshots().listen((data) {
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
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _upAnimation = CurvedAnimation(parent: _upController, curve: Curves.easeIn);

    _upController.addListener(() {
      if (_upController.isCompleted) {
        _upController.reverse();
      }
    });

    _downController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
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
    int points = (post.upCount - post.downCount);
    return Stack(
      children: [
        contentPostVideo(),
        getProgressContent(),
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Expanded(
                  child: Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: description()),
                    actionsBar(points)
                  ],
                ),
              )),
              widget.isGameBar
                  ? Container(
                      height: MediaQuery.of(context).size.height / 11,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [getPlayController(), gameBar()],
                      ),
                    )
                  : SizedBox(
                      height: MediaQuery.of(context).size.height / 11,
                    )
            ],
          ),
        ),
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
              color: Colors.red,
              size: 80,
            ),
          ),
        ),
      ],
    );
  }

  Widget contentPostVideo() {
    return Stack(
      children: [
        Hero(
          tag: tagHeroPost,
          child: Center(
            child: videoPlayerController.value.isInitialized
                ? VisibilityDetector(
                    key: Key('visibility${post.id}'),
                    child: AspectRatio(
                        aspectRatio: videoPlayerController.value.aspectRatio,
                        child: VideoPlayer(videoPlayerController)),
                    onVisibilityChanged: (VisibilityInfo info) {
                      print('info: ${info.visibleFraction}');
                      if (info.visibleFraction == 0 && !isNavigateComment) {
                        print('pas visible et false');
                        if (mounted) {
                          setState(() {
                            videoPlayerController.pause();
                          });
                        }
                      } else if (info.visibleFraction == 1 &&
                          !isNavigateComment) {
                        print('visible et false');
                        if (mounted) {
                          setState(() {
                            videoPlayerController.play();
                          });
                        }
                      } else if ((info.visibleFraction == 1 ||
                              info.visibleFraction == 0) &&
                          isNavigateComment) {
                        print('visible ou pas et true');
                        if (mounted) {
                          setState(() {
                            videoPlayerController.play();
                            isNavigateComment = !isNavigateComment;
                          });
                        }
                      }
                    })
                : CachedNetworkImage(
                    imageUrl: post.previewPictureUrl,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        Container(
          color: Colors.black.withOpacity(0.2),
        ),
      ],
    );
  }

  getPlayController() {
    return Container(
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              print('press pause');
              if (videoPlayerController.value.isPlaying) {
                setState(() {
                  videoPlayerController.pause();
                });
              } else {
                setState(() {
                  videoPlayerController.play();
                });
              }
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
                volumeOn ? Icons.volume_up_outlined : Icons.volume_off_outlined,
                size: 23,
                color: Colors.white,
              )),
          SizedBox(
            width: 15.0,
          ),
          widget.isFollowingsSection
              ? GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProfileGameScreen(
                                game: game,
                                navKey: navHomeAuthKey,
                              ))),
                  child: Container(
                    height: 30.0,
                    width: 30.0,
                    decoration: BoxDecoration(
                        color: Theme.of(context).canvasColor,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(5.0),
                        image: DecorationImage(
                            image: CachedNetworkImageProvider(game.imageUrl),
                            fit: BoxFit.cover)),
                  ),
                )
              : SizedBox()
        ],
      ),
    );
  }

  Widget getProgressContent() {
    return Positioned(
      bottom: widget.isGameBar ? 0 : MediaQuery.of(context).size.height / 11,
      child: Container(
        height: 7.0,
        width: MediaQuery.of(context).size.width,
        child: VideoProgressIndicator(
          videoPlayerController,
          allowScrubbing: true,
          colors: VideoProgressColors(
              playedColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Colors.white),
        ),
      ),
    );
  }

  Widget description() {
    return Container(
        alignment: Alignment.bottomLeft,
        height: MediaQuery.of(context).size.height / 1.5,
        child: Padding(
          padding: EdgeInsets.only(bottom: widget.positionDescriptionBar),
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
                      widget.isGameBar ? SizedBox() : getPlayController(),
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
                                          builder: (context) => ProfilUser(
                                                userPostID: post.uid,
                                              )));
                                },
                                child: Text(
                                  userPost.username,
                                )),
                          ),
                          SizedBox(
                            width: 2.5,
                          ),
                          Text('.'),
                          SizedBox(
                            width: 2.5,
                          ),
                          Text(Helpers.datePostView(post.date),
                              style: TextStyle(color: Colors.white)),
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
                            onHashtagTap: (hashtag) async {
                              late Hashtag tag;
                              await FirebaseFirestore.instance
                                  .collection('hashtags')
                                  .doc(hashtag)
                                  .get()
                                  .then((hashtagData) => tag = Hashtag.fromMap(
                                      hashtagData, hashtagData.data()!));
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          HashtagsScreen(hashtag: tag)));
                            },
                            // hashtagStyle:
                            //     mystyle(12, Theme.of(context).colorScheme.primary),
                          )),
                    ],
                  ),
                )),
          ),
        ));
  }

  Widget actionsBar(int points) {
    return Container(
      height: MediaQuery.of(context).size.height / 1.5,
      width: MediaQuery.of(context).size.width / 4,
      child: Padding(
        padding: EdgeInsets.only(bottom: widget.positionActionsBar),
        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          _getSocialReferencement(
              iconUp: Icons.arrow_upward_outlined,
              iconDown: Icons.arrow_downward_outlined,
              title: points.toString()),
          SizedBox(
            height: 35.0,
          ),
          _getSocialAction(
              icon: Icons.insert_comment_outlined,
              title: post.commentCount.toString(),
              context: context),
          SizedBox(
            height: 35.0,
          ),
          _getMore(),
          SizedBox(
            height: 35.0,
          ),
          _getFollowAction(context: context),
        ]),
      ),
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
                            ? Colors.red
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
              child: Text(title),
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
            setState(() {
              isNavigateComment = true;
            });
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommentsView(
                    post: post,
                    videoPlayerController: videoPlayerController,
                    tagHeroPost: tagHeroPost,
                  ),
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
              child: Text(title)))
    ]);
  }

  Widget _getMore() {
    return Card(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      child: InkWell(
          onTap: () => showMorePostBottomSheet(),
          child: Icon(
            Icons.more_vert_outlined,
            color: Colors.white,
            size: 26,
          )),
    );
  }

  Widget _getFollowAction({required BuildContext context}) {
    return Container(
      width: ProfileImageSize + 5.0,
      height: ProfileImageSize + 7.5,
      child: post.uid == widget.idUserActual || isFollowing
          ? _getProfilePicture(context)
          : Stack(
              children: [_getProfilePicture(context), _getPlusIcon(context)]),
    );
  }

  Widget _getProfilePicture(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfilUser(
                        userPostID: post.uid,
                      )));
        },
        child: userPost.imageUrl == null
            ? Container(
                height: ProfileImageSize,
                width: ProfileImageSize,
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black),
                ),
                child: Icon(
                  Icons.person,
                  size: 30,
                ))
            : Container(
                height: ProfileImageSize,
                width: ProfileImageSize,
                decoration: BoxDecoration(
                    color: Colors.white60,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black),
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(userPost.imageUrl!))),
              ),
      ),
    );
  }

  Widget _getPlusIcon(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        onTap: () {
          if (userPost.privacy == 'public') {
            followPublicUser();
          } else {
            followPrivateUser();
          }
        },
        child: Container(
            width: PlusIconSize,
            height: PlusIconSize,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary
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
      height: MediaQuery.of(context).size.height / 11,
      child: Padding(
          padding: EdgeInsets.only(
              right: (MediaQuery.of(context).size.width / 4) / 3.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.videogame_asset,
                color: Colors.white,
                size: 23,
              ),
              Container(
                  padding: EdgeInsets.zero,
                  width: MediaQuery.of(context).size.width / 4,
                  child: Marquee(
                    text: game.name,
                    textDirection: TextDirection.ltr,
                    blankSpace: 50,
                    velocity: 30,
                  )),
              Container(
                padding: EdgeInsets.zero,
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(5.0),
                    image: DecorationImage(
                        image: CachedNetworkImageProvider(game.imageUrl),
                        fit: BoxFit.cover)),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProfileGameScreen(
                                game: game,
                                navKey: navHomeAuthKey,
                              ))),
                ),
              )
            ],
          )),
    );
  }
}
