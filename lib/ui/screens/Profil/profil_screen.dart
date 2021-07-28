import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/ui/screens/Reglages/reglages_screen.dart';
import 'package:gemu/ui/screens/Support/panel_support_screen.dart';
import 'package:gemu/models/user.dart';
import 'package:gemu/services/database_service.dart';

import 'followers.dart';
import 'follows.dart';
import 'posts_profil.dart';

class ProfilMenuDrawer extends StatefulWidget {
  final UserModel user;

  const ProfilMenuDrawer({
    Key? key,
    required this.user,
  }) : super(key: key);
  @override
  _ProfilMenuDrawerState createState() => _ProfilMenuDrawerState();
}

class _ProfilMenuDrawerState extends State<ProfilMenuDrawer>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late StreamSubscription followersListener, followingsListener, pointsListener;
  int followers = 0;
  int followings = 0;
  int points = 0;

  bool dataIsThere = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, length: 2, initialIndex: 0);

    //Listener on followers
    followersListener = DatabaseService.usersCollectionReference
        .doc(widget.user.uid)
        .collection('followers')
        .snapshots()
        .listen((data) {
      setState(() {
        followers = data.docs.length;
      });
    });

    //Listener on points
    pointsListener = FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: widget.user.uid)
        .snapshots()
        .listen((data) {
      for (var item in data.docs) {
        points = (item.data()['upcount'] - item.data()['downcount']) + points;
      }
    });

    //Listener on followings
    followingsListener = DatabaseService.usersCollectionReference
        .doc(widget.user.uid)
        .collection('following')
        .snapshots()
        .listen((data) {
      setState(() {
        followings = data.docs.length;
      });
    });

    setState(() {
      dataIsThere = true;
    });
  }

  @override
  void dispose() {
    followersListener.cancel();
    pointsListener.cancel();
    followingsListener.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: dataIsThere
            ? NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        automaticallyImplyLeading: false,
                        elevation: 6.0,
                        forceElevated: true,
                        pinned: true,
                        leading: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.arrow_back_ios,
                              size: 23,
                            )),
                        centerTitle: true,
                        title: Text(
                          widget.user.username,
                          style: TextStyle(fontSize: 23),
                        ),
                        actions: [
                          IconButton(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => PanelSupportScreen())),
                              icon: Icon(Icons.support)),
                          IconButton(
                              icon: Icon(
                                Icons.settings,
                                size: 25,
                              ),
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      settings:
                                          RouteSettings(name: "/Réglages"),
                                      builder: (BuildContext context) =>
                                          ReglagesScreen(user: widget.user)))),
                        ],
                        expandedHeight: 250,
                        flexibleSpace: Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Theme.of(context).primaryColor,
                                    Theme.of(context).accentColor
                                  ],
                                  tileMode: TileMode.clamp)),
                          child: FlexibleSpaceBar(
                            collapseMode: CollapseMode.parallax,
                            background: Stack(
                              children: [
                                Align(
                                    alignment: Alignment.center,
                                    child: widget.user.imageUrl == null
                                        ? Container(
                                            height: 90,
                                            width: 90,
                                            decoration: BoxDecoration(
                                              color:
                                                  Theme.of(context).canvasColor,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.black,
                                                  width: 2.0),
                                            ),
                                            child: Icon(
                                              Icons.person,
                                              size: 50,
                                            ))
                                        : Container(
                                            margin: EdgeInsets.all(3.0),
                                            width: 90,
                                            height: 90,
                                            decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Color(0xFF222831)),
                                                image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image:
                                                        CachedNetworkImageProvider(
                                                            widget.user
                                                                .imageUrl!))),
                                          )),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        right: 15.0, bottom: 10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        GestureDetector(
                                          onTap: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Followers(
                                                        idUser: widget.user.uid,
                                                      ))),
                                          child: Container(
                                            color: Colors.transparent,
                                            height: 60,
                                            width: 70,
                                            child: Stack(
                                              children: [
                                                Align(
                                                    alignment:
                                                        Alignment.topCenter,
                                                    child: Text(
                                                      'Followers',
                                                    )),
                                                Align(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: Text(
                                                    followers.toString(),
                                                    style:
                                                        TextStyle(fontSize: 23),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          color: Colors.transparent,
                                          height: 60,
                                          width: 50,
                                          child: Stack(
                                            children: [
                                              Align(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: Text(
                                                    'Points',
                                                  )),
                                              Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Text(
                                                  points.toString(),
                                                  style:
                                                      TextStyle(fontSize: 23),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => Follows(
                                                      idUser:
                                                          widget.user.uid))),
                                          child: Container(
                                            color: Colors.transparent,
                                            height: 60,
                                            width: 50,
                                            child: Stack(
                                              children: [
                                                Align(
                                                    alignment:
                                                        Alignment.topCenter,
                                                    child: Text(
                                                      'Follows',
                                                    )),
                                                Align(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: Text(
                                                    followings.toString(),
                                                    style:
                                                        TextStyle(fontSize: 23),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )),
                    SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverAppBarDelegate(TabBar(
                            controller: _tabController,
                            isScrollable: true,
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelColor: Theme.of(context).primaryColor,
                            unselectedLabelColor: Colors.grey,
                            indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Theme.of(context).canvasColor,
                                boxShadow: [
                                  BoxShadow(
                                      color: Theme.of(context).shadowColor,
                                      blurRadius: 3,
                                      spreadRadius: 3)
                                ]),
                            tabs: [
                              Tab(
                                text: 'Public',
                              ),
                              Tab(
                                text: 'Private',
                              ),
                            ])))
                  ];
                },
                body: Stack(
                  children: [
                    TabBarView(
                        physics: NeverScrollableScrollPhysics(),
                        controller: _tabController,
                        children: [
                          PostsPublic(user: widget.user),
                          PostsPrivate(user: widget.user)
                        ]),
                  ],
                ))
            : Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              ));
  }
}

class ProfilPost extends StatefulWidget {
  final String userPostID;

  ProfilPost({required this.userPostID});

  @override
  ProfilPostState createState() => ProfilPostState();
}

class ProfilPostState extends State<ProfilPost>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late UserModel userPost;

  late StreamSubscription followersListener, followingsListener, pointsListener;
  int followers = 0;
  int followings = 0;
  int points = 0;

  bool isFollowing = false;
  bool dataIsThere = false;

  @override
  void initState() {
    super.initState();

    if (widget.userPostID != me!.uid) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userPostID)
          .get()
          .then((data) {
        userPost = UserModel.fromMap(data, data.data()!);
      });

      userPost.ref.collection('followers').doc(me!.uid).get().then((follower) {
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
    } else {
      userPost = me!;
    }

    followersListener =
        userPost.ref.collection('followers').snapshots().listen((data) {
      setState(() {
        followers = data.docs.length;
      });

      pointsListener = FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: userPost.uid)
          .snapshots()
          .listen((data) {
        for (var item in data.docs) {
          points = (item.data()['upcount'] - item.data()['downcount']) + points;
        }
      });

      followingsListener =
          userPost.ref.collection('following').snapshots().listen((data) {
        setState(() {
          followings = data.docs.length;
        });
      });
    });

    _tabController = TabController(length: 2, vsync: this);

    setState(() {
      dataIsThere = true;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    followersListener.cancel();
    pointsListener.cancel();
    followingsListener.cancel();
    super.dispose();
  }

  followUser() async {
    userPost.ref.collection('followers').doc(me!.uid).get().then((user) {
      if (!user.exists) {
        user.reference.set({});
        FirebaseFirestore.instance
            .collection('users')
            .doc(me!.uid)
            .collection('following')
            .doc(userPost.uid)
            .set({});
        DatabaseService.addNotification(
            me!.uid, userPost.uid, "a commencé à vous suivre", "follow");

        setState(() {
          isFollowing = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: dataIsThere
          ? NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      automaticallyImplyLeading: false,
                      elevation: 6.0,
                      forceElevated: true,
                      pinned: true,
                      leading: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back_ios,
                            size: 23,
                          )),
                      centerTitle: true,
                      title: Text(
                        userPost.username,
                        style: TextStyle(fontSize: 23),
                      ),
                      expandedHeight: 250,
                      flexibleSpace: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme.of(context).primaryColor,
                                  Theme.of(context).accentColor
                                ],
                                tileMode: TileMode.clamp)),
                        child: FlexibleSpaceBar(
                          collapseMode: CollapseMode.parallax,
                          background: Stack(
                            children: [
                              Align(
                                  alignment: Alignment.center,
                                  child: userPost.imageUrl == null
                                      ? Container(
                                          height: 90,
                                          width: 90,
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).canvasColor,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.black,
                                                width: 2.0),
                                          ),
                                          child: Icon(
                                            Icons.person,
                                            size: 50,
                                          ))
                                      : Container(
                                          margin: EdgeInsets.all(3.0),
                                          width: 90,
                                          height: 90,
                                          decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Color(0xFF222831)),
                                              image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image:
                                                      CachedNetworkImageProvider(
                                                          userPost.imageUrl!))),
                                        )),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      right: 15.0, bottom: 10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      GestureDetector(
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Followers(
                                                      idUser: userPost.uid,
                                                    ))),
                                        child: Container(
                                          color: Colors.transparent,
                                          height: 60,
                                          width: 70,
                                          child: Stack(
                                            children: [
                                              Align(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: Text(
                                                    'Followers',
                                                  )),
                                              Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Text(
                                                  followers.toString(),
                                                  style:
                                                      TextStyle(fontSize: 23),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.transparent,
                                        height: 60,
                                        width: 50,
                                        child: Stack(
                                          children: [
                                            Align(
                                                alignment: Alignment.topCenter,
                                                child: Text(
                                                  'Points',
                                                )),
                                            Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Text(
                                                points.toString(),
                                                style: TextStyle(fontSize: 23),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Follows(
                                                    idUser: userPost.uid))),
                                        child: Container(
                                          color: Colors.transparent,
                                          height: 60,
                                          width: 50,
                                          child: Stack(
                                            children: [
                                              Align(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: Text(
                                                    'Follows',
                                                  )),
                                              Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Text(
                                                  followings.toString(),
                                                  style:
                                                      TextStyle(fontSize: 23),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )),
                  SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: Theme.of(context).primaryColor,
                          unselectedLabelColor: Colors.grey,
                          indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Theme.of(context).canvasColor,
                              boxShadow: [
                                BoxShadow(
                                    color: Theme.of(context).shadowColor,
                                    blurRadius: 3,
                                    spreadRadius: 3)
                              ]),
                          tabs: [
                            Tab(
                              text: 'Public',
                            ),
                            Tab(
                              text: 'Private',
                            ),
                          ])))
                ];
              },
              body: Stack(
                children: [
                  TabBarView(controller: _tabController, children: [
                    PostsPublic(user: userPost),
                    Center(
                      child: Text(
                          'Visible seulement pour les followers du compte'),
                    )
                  ]),
                ],
              ))
          : Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height + 20;

  @override
  double get maxExtent => _tabBar.preferredSize.height + 20;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 15, bottom: 15),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
