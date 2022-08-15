import "dart:io" show Platform;
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/models/user.dart';
import 'package:gemu/services/database_service.dart';

import 'followers.dart';
import 'follows.dart';
import 'posts_profil.dart';

class MyProfilScreen extends StatefulWidget {
  const MyProfilScreen({
    Key? key,
  }) : super(key: key);
  @override
  _MyProfilviewstate createState() => _MyProfilviewstate();
}

class _MyProfilviewstate extends State<MyProfilScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late TabController _tabController;

  late StreamSubscription followersListener, followingsListener, pointsListener;
  int followers = 0;
  int followings = 0;
  int points = 0;

  bool dataIsThere = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, length: 2, initialIndex: 0);

    //Listener on followers
    followersListener = DatabaseService.usersCollectionReference
        .doc(me!.uid)
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
        .where('uid', isEqualTo: me!.uid)
        .snapshots()
        .listen((data) {
      for (var item in data.docs) {
        points = (item.data()['upCount'] - item.data()['downCount']) + points;
      }
    });

    //Listener on followings
    followingsListener = DatabaseService.usersCollectionReference
        .doc(me!.uid)
        .collection('following')
        .snapshots()
        .listen((data) {
      setState(() {
        followings = data.docs.length;
      });
    });

    if (!dataIsThere && mounted) {
      setState(() {
        dataIsThere = true;
      });
    }
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
    super.build(context);
    return Scaffold(
        body: dataIsThere
            ? NestedScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                headerSliverBuilder: (_, bool innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        automaticallyImplyLeading: false,
                        elevation: 6.0,
                        systemOverlayStyle: Platform.isIOS
                            ? Theme.of(context).brightness == Brightness.dark
                                ? SystemUiOverlayStyle.light
                                : SystemUiOverlayStyle.dark
                            : SystemUiOverlayStyle(
                                statusBarColor: Colors.transparent,
                                statusBarIconBrightness:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Brightness.light
                                        : Brightness.dark),
                        forceElevated: true,
                        pinned: true,
                        centerTitle: true,
                        title: Text(
                          me!.username,
                          style: TextStyle(fontSize: 23),
                        ),
                        actions: [
                          IconButton(
                              icon: Icon(
                                Icons.settings,
                                size: 25,
                              ),
                              onPressed: () => navProfileAuthKey.currentState!
                                  .pushNamed(Reglages, arguments: [me!])),
                        ],
                        expandedHeight: 255,
                        flexibleSpace: Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.secondary
                                  ],
                                  tileMode: TileMode.clamp)),
                          child: FlexibleSpaceBar(
                            collapseMode: CollapseMode.parallax,
                            background: Stack(
                              children: [
                                Align(
                                    alignment: Alignment.center,
                                    child: me!.imageUrl == null
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
                                                            me!.imageUrl!))),
                                          )),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0, vertical: 10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Followers(
                                                        idUser: me!.uid,
                                                      ))),
                                          child: Container(
                                            color: Colors.transparent,
                                            height: 60,
                                            width: 70,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Followers',
                                                ),
                                                const SizedBox(
                                                  height: 15.0,
                                                ),
                                                Text(
                                                  followers.toString(),
                                                  style:
                                                      TextStyle(fontSize: 23),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          color: Colors.transparent,
                                          height: 60,
                                          width: 70,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Points',
                                              ),
                                              const SizedBox(
                                                height: 15.0,
                                              ),
                                              Text(
                                                points.toString(),
                                                style: TextStyle(fontSize: 23),
                                              )
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => Follows(
                                                      idUser: me!.uid))),
                                          child: Container(
                                            color: Colors.transparent,
                                            height: 60,
                                            width: 70,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Follows',
                                                ),
                                                const SizedBox(
                                                  height: 15.0,
                                                ),
                                                Text(
                                                  followings.toString(),
                                                  style:
                                                      TextStyle(fontSize: 23),
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
                            labelColor: Theme.of(context).colorScheme.primary,
                            unselectedLabelColor: Colors.grey,
                            indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Theme.of(context).canvasColor,
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      offset: Offset(1.0, 1.0))
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
                        physics: AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics()),
                        controller: _tabController,
                        children: [
                          PostsPublicProfile(user: me!),
                          PostsPrivate(user: me!)
                        ]),
                  ],
                ))
            : Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ));
  }
}

class ProfilUser extends StatefulWidget {
  final String userPostID;

  ProfilUser({required this.userPostID});

  @override
  ProfilUserState createState() => ProfilUserState();
}

class ProfilUserState extends State<ProfilUser>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  UserModel? userPost;
  late bool isWaiting;

  List<String> followers = [];
  List<String> followings = [];
  int points = 0;

  bool dataIsThere = false;

  getDataProfile() async {
    if (widget.userPostID != me!.uid) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userPostID)
          .get()
          .then((data) async {
        userPost = UserModel.fromMap(data, data.data()!);
        await Future.delayed(Duration(seconds: 1));
        if (userPost!.privacy == 'private') {
          await FirebaseFirestore.instance
              .collection('notifications')
              .doc(userPost!.uid)
              .collection('singleNotif')
              .where('from', isEqualTo: me!.uid)
              .where('type', isEqualTo: 'follow')
              .where('seen', isEqualTo: false)
              .limit(1)
              .get()
              .then((data) {
            if (data.docs.length == 0) {
              print('dans le if 0');
              setState(() {
                isWaiting = false;
              });
            } else {
              print('dans le else du for');
              setState(() {
                isWaiting = true;
              });
            }
            print('notif: $isWaiting');
          });
        }
      });
    } else {
      userPost = me!;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userPostID)
        .collection('followers')
        .get()
        .then((data) {
      for (var item in data.docs) {
        followers.add(item.id);
      }
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userPostID)
        .collection('following')
        .get()
        .then((data) {
      for (var item in data.docs) {
        followings.add(item.id);
      }
    });

    await FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: widget.userPostID)
        .get()
        .then((data) {
      for (var item in data.docs) {
        points = (item.data()['upCount'] - item.data()['downCount']) + points;
      }
    });

    setState(() {
      dataIsThere = true;
    });
  }

  @override
  void initState() {
    super.initState();

    getDataProfile();

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  followPublicUser() async {
    userPost!.ref!.collection('followers').doc(me!.uid).get().then((user) {
      if (!user.exists) {
        user.reference.set({});
        FirebaseFirestore.instance
            .collection('users')
            .doc(me!.uid)
            .collection('following')
            .doc(userPost!.uid)
            .set({});
        DatabaseService.addNotification(
            me!.uid, userPost!.uid, "a commencé à vous suivre", "follow");
      }
    });

    setState(() {
      followers.add(me!.uid);
    });
  }

  followPrivateUser() async {
    userPost!.ref!.collection('followers').doc(me!.uid).get().then((user) {
      if (!user.exists) {
        DatabaseService.addNotification(
            me!.uid, userPost!.uid, "voudrait vous suivre", "follow");

        setState(() {
          isWaiting = !isWaiting;
        });
      }
    });
  }

  unfollowUser() async {
    userPost!.ref!.collection('followers').doc(me!.uid).get().then((user) {
      if (user.exists) {
        user.reference.delete();
        FirebaseFirestore.instance
            .collection('users')
            .doc(me!.uid)
            .collection('following')
            .doc(userPost!.uid)
            .delete();
      }
    });

    setState(() {
      followers.remove(me!.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: (dataIsThere && userPost != null)
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
                        userPost!.username,
                        style: TextStyle(fontSize: 23),
                      ),
                      expandedHeight: userPost!.uid != me!.uid ? 285 : 255,
                      flexibleSpace: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.secondary
                                ],
                                tileMode: TileMode.clamp)),
                        child: FlexibleSpaceBar(
                          collapseMode: CollapseMode.parallax,
                          background: Padding(
                            padding: EdgeInsets.only(top: 80.0),
                            child: Column(
                              children: [
                                userPost!.imageUrl == null
                                    ? Container(
                                        height: 90,
                                        width: 90,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).canvasColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.black, width: 2.0),
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
                                                        userPost!.imageUrl!))),
                                      ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                if (userPost!.uid != me!.uid)
                                  userPost!.privacy == 'public'
                                      ? Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.5,
                                          height: 30,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.0),
                                          child: followers.contains(me!.uid)
                                              ? ElevatedButton(
                                                  onPressed: () {
                                                    unfollowUser();
                                                  },
                                                  style: TextButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      elevation: 0,
                                                      shape: RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              color:
                                                                  Colors.black),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  10.0))),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Icon(Icons.remove,
                                                          size: 23,
                                                          color: Colors.black),
                                                      SizedBox(
                                                        width: 5.0,
                                                      ),
                                                      Text(
                                                        'Unfollow',
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700),
                                                      )
                                                    ],
                                                  ))
                                              : ElevatedButton(
                                                  onPressed: () {
                                                    followPublicUser();
                                                  },
                                                  style: TextButton.styleFrom(
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .primaryColor,
                                                      elevation: 6,
                                                      shape: RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              color:
                                                                  Colors.black),
                                                          borderRadius:
                                                              BorderRadius.circular(10.0))),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Icon(Icons.add,
                                                          size: 23,
                                                          color: Colors.black),
                                                      SizedBox(
                                                        width: 10.0,
                                                      ),
                                                      Text(
                                                        'Follow',
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700),
                                                      )
                                                    ],
                                                  )),
                                        )
                                      : followers.contains(me!.uid)
                                          ? Container(
                                              width: MediaQuery.of(context).size.width /
                                                  2.5,
                                              height: 30,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10.0),
                                              child: ElevatedButton(
                                                  onPressed: () {
                                                    unfollowUser();
                                                  },
                                                  style: TextButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      elevation: 0,
                                                      shape: RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              color:
                                                                  Colors.black),
                                                          borderRadius: BorderRadius.circular(
                                                              10.0))),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Icon(Icons.remove,
                                                          size: 23,
                                                          color: Colors.black),
                                                      SizedBox(
                                                        width: 5.0,
                                                      ),
                                                      Text(
                                                        'Unfollow',
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700),
                                                      )
                                                    ],
                                                  )))
                                          : isWaiting
                                              ? Container(
                                                  alignment: Alignment.center,
                                                  width: MediaQuery.of(context).size.width /
                                                      2.5,
                                                  height: 30,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.0),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(color: Colors.black),
                                                      borderRadius: BorderRadius.circular(10.0)),
                                                  child: Text('En attente', style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w700)))
                                              : Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2.5,
                                                  height: 30,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.0),
                                                  child: ElevatedButton(
                                                      onPressed: () {
                                                        followPrivateUser();
                                                      },
                                                      style: TextButton.styleFrom(
                                                          backgroundColor:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          elevation: 6,
                                                          shape: RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                  color: Colors
                                                                      .black),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0))),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Icon(Icons.add,
                                                              size: 23,
                                                              color:
                                                                  Colors.black),
                                                          SizedBox(
                                                            width: 10.0,
                                                          ),
                                                          Text(
                                                            'Follow',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                          )
                                                        ],
                                                      )),
                                                ),
                                SizedBox(
                                  height: 15.0,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15.0, vertical: 5.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Followers(
                                                      idUser: userPost!.uid,
                                                    ))),
                                        child: Container(
                                          color: Colors.transparent,
                                          height: 60,
                                          width: 70,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Followers',
                                              ),
                                              const SizedBox(
                                                height: 15.0,
                                              ),
                                              Text(
                                                followers.length.toString(),
                                                style: TextStyle(fontSize: 23),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.transparent,
                                        height: 60,
                                        width: 70,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Points',
                                            ),
                                            const SizedBox(
                                              height: 15.0,
                                            ),
                                            Text(
                                              points.toString(),
                                              style: TextStyle(fontSize: 23),
                                            )
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Follows(
                                                    idUser: userPost!.uid))),
                                        child: Container(
                                          color: Colors.transparent,
                                          height: 60,
                                          width: 70,
                                          child: Column(
                                            children: [
                                              Text(
                                                'Follows',
                                              ),
                                              const SizedBox(
                                                height: 15.0,
                                              ),
                                              Text(
                                                followings.length.toString(),
                                                style: TextStyle(fontSize: 23),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )),
                  SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: Theme.of(context).colorScheme.primary,
                          unselectedLabelColor: Colors.grey,
                          indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Theme.of(context).canvasColor,
                              boxShadow: [
                                BoxShadow(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    offset: Offset(1.0, 1.0))
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
              body: TabBarView(
                  controller: _tabController,
                  children: userPost!.privacy == 'public'
                      ? accountPublic()
                      : accountPrivate()),
            )
          : Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: 1.5,
              ),
            ),
    );
  }

  List<Widget> accountPublic() {
    return userPost!.uid == me!.uid
        ? [PostsPublicProfile(user: userPost!), PostsPrivate(user: userPost!)]
        : [
            PostsPublicProfile(user: userPost!),
            followers.contains(me!.uid)
                ? PostsPrivate(user: userPost!)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock, size: 33),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text('Visible seulement par les followers',
                          style: Theme.of(context).textTheme.bodySmall)
                    ],
                  ),
          ];
  }

  List<Widget> accountPrivate() {
    return (userPost!.uid == me!.uid || followers.contains(me!.uid))
        ? [PostsPublicProfile(user: userPost!), PostsPrivate(user: userPost!)]
        : [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, size: 33),
                SizedBox(
                  height: 10.0,
                ),
                Text('Visible seulement par les followers',
                    style: Theme.of(context).textTheme.bodySmall)
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, size: 33),
                SizedBox(
                  height: 10.0,
                ),
                Text('Visible seulement par les followers',
                    style: Theme.of(context).textTheme.bodySmall)
              ],
            )
          ];
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
    return Container(
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
