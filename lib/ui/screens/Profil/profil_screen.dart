import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:stacked/stacked.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:Gemu/screensmodels/Profil/profil_screen_model.dart';
import 'package:Gemu/constants/variables.dart';

import 'posts_profil_screen.dart';
import 'edit_private_posts_picture.dart';
import 'edit_private_posts_video.dart';
import 'followers.dart';
import 'follows.dart';

class ProfilMenuDrawer extends StatefulWidget {
  @override
  _ProfilMenuDrawerState createState() => _ProfilMenuDrawerState();
}

class _ProfilMenuDrawerState extends State<ProfilMenuDrawer>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;

  TabController _tabController;

  bool isDrawer = true;

  String uid;
  DocumentSnapshot user;
  Future mypostspublic, mypostsprivate;
  int followers, following;
  int points = 0;
  bool dataIsThere = false;

  List postsProfil = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2, initialIndex: 0);

    getAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  getAllData() async {
    uid = FirebaseAuth.instance.currentUser.uid;

    user = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    //posts public user
    mypostspublic = FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: uid)
        .where('privacy', isEqualTo: "Public")
        .get();

    //posts private user
    mypostsprivate = FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: uid)
        .where('privacy', isEqualTo: "Private")
        .get();

    //get points user
    var documents = await FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: uid)
        .get();
    for (var item in documents.docs) {
      points = (item.data()['up'].length - item.data()['down'].length) + points;
    }

    //get followers and following
    var followersDocuments = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('followers')
        .get();
    var followingDocuments = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('following')
        .get();
    followers = followersDocuments.docs.length;
    following = followingDocuments.docs.length;

    setState(() {
      dataIsThere = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProfilScreenModel>.reactive(
      viewModelBuilder: () => ProfilScreenModel(),
      builder: (context, model, child) => isDrawer
          ? Drawer(
              child: dataIsThere
                  ? Scaffold(
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      body: NestedScrollView(
                          headerSliverBuilder:
                              (BuildContext context, bool innerBoxIsScrolled) {
                            return <Widget>[
                              SliverGradientAppBar(
                                automaticallyImplyLeading: false,
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Theme.of(context).primaryColor,
                                      Theme.of(context).accentColor
                                    ]),
                                elevation: 6.0,
                                forceElevated: true,
                                pinned: true,
                                leading: IconButton(
                                    icon: Icon(
                                      Icons.zoom_out_map_rounded,
                                      size: 26,
                                    ),
                                    onPressed: () {
                                      if (isDrawer) {
                                        setState(() {
                                          isDrawer = false;
                                        });
                                      }
                                    }),
                                centerTitle: true,
                                title: Text(
                                  user.data()['pseudo'],
                                  style: TextStyle(fontSize: 23),
                                ),
                                actions: [
                                  IconButton(
                                      icon: Icon(
                                        Icons.settings,
                                        size: 25,
                                      ),
                                      onPressed: () =>
                                          model.navigateToReglages())
                                ],
                                expandedHeight: 250,
                                flexibleSpace: FlexibleSpaceBar(
                                  collapseMode: CollapseMode.parallax,
                                  background: Container(
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                          Theme.of(context).primaryColor,
                                          Theme.of(context).accentColor
                                        ])),
                                    child: Stack(
                                      children: [
                                        Align(
                                            alignment: Alignment.center,
                                            child: user.data()['photoURL'] ==
                                                    null
                                                ? Container(
                                                    height: 90,
                                                    width: 90,
                                                    decoration: BoxDecoration(
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
                                                        color:
                                                            Colors.transparent,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                            color: Color(
                                                                0xFF222831)),
                                                        image: DecorationImage(
                                                            fit: BoxFit.cover,
                                                            image: NetworkImage(
                                                                user.data()[
                                                                    'photoURL']))),
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
                                                                idUser:
                                                                    user.data()[
                                                                        'id'],
                                                              ))),
                                                  child: Container(
                                                    color: Colors.transparent,
                                                    height: 60,
                                                    width: 70,
                                                    child: Stack(
                                                      children: [
                                                        Align(
                                                            alignment: Alignment
                                                                .topCenter,
                                                            child: Text(
                                                              'Followers',
                                                            )),
                                                        Align(
                                                          alignment: Alignment
                                                              .bottomCenter,
                                                          child: Text(
                                                            followers
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontSize: 23),
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
                                                          alignment: Alignment
                                                              .topCenter,
                                                          child: Text(
                                                            'Points',
                                                          )),
                                                      Align(
                                                        alignment: Alignment
                                                            .bottomCenter,
                                                        child: Text(
                                                          points.toString(),
                                                          style: TextStyle(
                                                              fontSize: 23),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () => Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Follows(
                                                                  idUser: user
                                                                          .data()[
                                                                      'id']))),
                                                  child: Container(
                                                    color: Colors.transparent,
                                                    height: 60,
                                                    width: 50,
                                                    child: Stack(
                                                      children: [
                                                        Align(
                                                            alignment: Alignment
                                                                .topCenter,
                                                            child: Text(
                                                              'Follows',
                                                            )),
                                                        Align(
                                                          alignment: Alignment
                                                              .bottomCenter,
                                                          child: Text(
                                                            following
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontSize: 23),
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
                                ),
                              ),
                              SliverPersistentHeader(
                                  pinned: true,
                                  delegate: _SliverAppBarDelegate(TabBar(
                                      controller: _tabController,
                                      isScrollable: true,
                                      indicatorSize: TabBarIndicatorSize.tab,
                                      labelColor:
                                          Theme.of(context).primaryColor,
                                      unselectedLabelColor: Colors.grey,
                                      indicator: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Theme.of(context).canvasColor),
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
                                  controller: _tabController,
                                  children: [postsPublic(), postsPrivate()]),
                            ],
                          )),
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
            )
          : Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: NestedScrollView(
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverGradientAppBar(
                        automaticallyImplyLeading: false,
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).accentColor
                            ]),
                        elevation: 6.0,
                        forceElevated: true,
                        pinned: true,
                        leading: IconButton(
                            icon: Icon(
                              Icons.close_fullscreen_rounded,
                              size: 26,
                            ),
                            onPressed: () {
                              if (!isDrawer) {
                                setState(() {
                                  isDrawer = true;
                                });
                              }
                            }),
                        centerTitle: true,
                        title: Text(
                          user.data()['pseudo'],
                          style: TextStyle(fontSize: 23),
                        ),
                        actions: [
                          IconButton(
                              icon: Icon(
                                Icons.settings,
                                size: 25,
                              ),
                              onPressed: () => model.navigateToReglages())
                        ],
                        expandedHeight: 250,
                        flexibleSpace: FlexibleSpaceBar(
                          collapseMode: CollapseMode.parallax,
                          background: Container(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                  Theme.of(context).primaryColor,
                                  Theme.of(context).accentColor
                                ])),
                            child: Stack(
                              children: [
                                Align(
                                    alignment: Alignment.center,
                                    child: user.data()['photoURL'] == null
                                        ? Container(
                                            height: 90,
                                            width: 90,
                                            decoration: BoxDecoration(
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
                                                    image: NetworkImage(user
                                                        .data()['photoURL']))),
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
                                                          idUser: user
                                                              .data()['id']))),
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
                                                          user.data()['id']))),
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
                                                    following.toString(),
                                                    style:
                                                        TextStyle(fontSize: 23),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
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
                                  color: Theme.of(context).canvasColor),
                              tabs: [
                                Tab(
                                  text: 'Publications',
                                ),
                                Tab(
                                  text: 'Private',
                                )
                              ])))
                    ];
                  },
                  body: Stack(
                    children: [
                      TabBarView(controller: _tabController, children: [
                        postsPublic(),
                        postsPrivate(),
                      ]),
                    ],
                  )),
            ),
    );
  }

  Widget postsPublic() {
    return FutureBuilder(
        future: mypostspublic,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data.docs.length == 0) {
            return Center(
              child: Text(
                'Pas encore de publications publiques',
                style: mystyle(11),
              ),
            );
          }
          return GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: snapshot.data.docs.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6),
              itemBuilder: (BuildContext context, int index) {
                DocumentSnapshot post = snapshot.data.docs[index];
                return post.data()['previewImage'] == null
                    ? GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PostsProfilScreen(
                                      userID: user.data()['id'],
                                      indexPost: index,
                                    ))),
                        child: Container(
                          height: 150,
                          width: 150,
                          child: Stack(
                            children: [
                              Container(
                                height: 150,
                                width: 150,
                                child: Image(
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider(
                                        post.data()['pictureUrl'])),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () =>
                                      print('Supprimer ma publication'),
                                  child: Icon(
                                    Icons.clear,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.remove_red_eye,
                                      color: Colors.white,
                                    ),
                                    Text(post.data()['viewcount'].toString()),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PostsProfilScreen(
                                    userID: user.data()['id'],
                                    indexPost: index))),
                        child: Container(
                          height: 150,
                          width: 150,
                          child: Stack(
                            children: [
                              Container(
                                height: 150,
                                width: 150,
                                child: Image(
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider(
                                        post.data()['previewImage'])),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () =>
                                      print('Supprimer ma publication'),
                                  child: Icon(
                                    Icons.clear,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.remove_red_eye,
                                      color: Colors.white,
                                    ),
                                    Text(post.data()['viewcount'].toString()),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
              });
        });
  }

  Widget postsPrivate() {
    return FutureBuilder(
        future: mypostsprivate,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data.docs.length == 0) {
            return Center(
              child: Text('Pas de publications privées', style: mystyle(11)),
            );
          }
          return GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: snapshot.data.docs.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6),
              itemBuilder: (BuildContext context, int index) {
                DocumentSnapshot post = snapshot.data.docs[index];
                return post.data()['previewImage'] == null
                    ? GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditPrivatePostsPicture(
                                      post: post,
                                    ))),
                        child: Container(
                          height: 150,
                          width: 150,
                          child: Stack(
                            children: [
                              Container(
                                height: 150,
                                width: 150,
                                child: Image(
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider(
                                        post.data()['pictureUrl'])),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () =>
                                      print('Supprimer ma publication'),
                                  child: Icon(
                                    Icons.clear,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditPrivatePostsVideo(
                                      post: post,
                                    ))),
                        child: Container(
                          height: 150,
                          width: 150,
                          child: Stack(
                            children: [
                              Container(
                                height: 150,
                                width: 150,
                                child: Image(
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider(
                                        post.data()['previewImage'])),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () =>
                                      print('Supprimer ma publication'),
                                  child: Icon(
                                    Icons.clear,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
              });
        });
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 5),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
