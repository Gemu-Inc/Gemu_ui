import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

class ProfileView extends StatefulWidget {
  final String idUser;

  ProfileView({this.idUser});

  @override
  ProfileViewState createState() => ProfileViewState();
}

class ProfileViewState extends State<ProfileView>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  String uid;
  Future myposts;
  int pointsPost;
  int followers, following;
  int points = 0;
  bool isFollowing;
  bool dataIsThere = false;

  @override
  void initState() {
    super.initState();

    getAllData();

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  getAllData() async {
    //id online user
    uid = FirebaseAuth.instance.currentUser.uid;

    //posts du profile user
    myposts = FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: widget.idUser)
        .get();

    //get points user
    var documents = await FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: widget.idUser)
        .get();
    for (var item in documents.docs) {
      points = (item.data()['up'].length - item.data()['down'].length) + points;
    }

    //get followers and following
    var followersDocuments = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.idUser)
        .collection('followers')
        .get();
    var followingDocuments = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.idUser)
        .collection('following')
        .get();
    followers = followersDocuments.docs.length;
    following = followingDocuments.docs.length;

    //check if the online user is already following
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.idUser)
        .collection('followers')
        .doc(uid)
        .get()
        .then((document) {
      if (!document.exists) {
        setState(() {
          isFollowing = false;
        });
      } else {
        setState(() {
          isFollowing = true;
        });
      }
    });

    setState(() {
      dataIsThere = true;
    });
  }

  followUser() async {
    var document = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.idUser)
        .collection('followers')
        .doc(uid)
        .get();

    if (!document.exists) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.idUser)
          .collection('followers')
          .doc(uid)
          .set({});

      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('following')
          .doc(widget.idUser)
          .set({});

      setState(() {
        isFollowing = true;

        followers++;
      });
    } else {
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.idUser)
          .collection('followers')
          .doc(uid)
          .delete();

      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('following')
          .doc(widget.idUser)
          .delete();

      setState(() {
        isFollowing = false;
        followers--;
      });
    }
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
                      centerTitle: true,
                      title: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.idUser)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                snapshot.data['pseudo'],
                                style: TextStyle(fontSize: 23),
                              );
                            } else {
                              return CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation(
                                    Theme.of(context).primaryColor),
                              );
                            }
                          }),
                      actions: [
                        IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () => Navigator.pop(context))
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
                                  child: StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(widget.idUser)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          return widget.idUser == uid
                                              ? snapshot.data['photoURL'] ==
                                                      null
                                                  ? Container(
                                                      height: 90,
                                                      width: 90,
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                            .canvasColor,
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
                                                      margin:
                                                          EdgeInsets.all(3.0),
                                                      width: 90,
                                                      height: 90,
                                                      decoration: BoxDecoration(
                                                          color: Colors
                                                              .transparent,
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                              color: Color(
                                                                  0xFF222831)),
                                                          image: DecorationImage(
                                                              fit: BoxFit.cover,
                                                              image: NetworkImage(
                                                                  snapshot.data[
                                                                      'photoURL']))),
                                                    )
                                              : Container(
                                                  height: 100,
                                                  width: 90,
                                                  child: Stack(
                                                    children: [
                                                      snapshot.data[
                                                                  'photoURL'] ==
                                                              null
                                                          ? Container(
                                                              height: 90,
                                                              width: 90,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Theme.of(
                                                                        context)
                                                                    .canvasColor,
                                                                shape: BoxShape
                                                                    .circle,
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .black,
                                                                    width: 2.0),
                                                              ),
                                                              child: Icon(
                                                                Icons.person,
                                                                size: 50,
                                                              ))
                                                          : Container(
                                                              width: 90,
                                                              height: 90,
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .transparent,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  border: Border.all(
                                                                      color: Color(
                                                                          0xFF222831)),
                                                                  image: DecorationImage(
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      image: NetworkImage(
                                                                          snapshot
                                                                              .data['photoURL']))),
                                                            ),
                                                      Align(
                                                        alignment: Alignment
                                                            .bottomCenter,
                                                        child: GestureDetector(
                                                          onTap: () =>
                                                              followUser(),
                                                          child: Container(
                                                            height: 30,
                                                            width: 30,
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient: LinearGradient(
                                                                  begin: Alignment
                                                                      .topLeft,
                                                                  end: Alignment.bottomRight,
                                                                  colors: [
                                                                    Theme.of(
                                                                            context)
                                                                        .primaryColor,
                                                                    Theme.of(
                                                                            context)
                                                                        .accentColor
                                                                  ]),
                                                              shape: BoxShape
                                                                  .circle,
                                                              border: Border.all(
                                                                  color: Color(
                                                                      0xFF222831)),
                                                            ),
                                                            child: isFollowing
                                                                ? Icon(
                                                                    Icons.check)
                                                                : Icon(
                                                                    Icons.add),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                );
                                        } else {
                                          return CircularProgressIndicator();
                                        }
                                      })),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      right: 15.0, bottom: 10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Container(
                                        height: 60,
                                        width: 70,
                                        child: Stack(
                                          children: [
                                            Align(
                                                alignment: Alignment.topCenter,
                                                child: Text(
                                                  'Followers',
                                                )),
                                            Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Text(
                                                followers.toString(),
                                                style: TextStyle(fontSize: 23),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
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
                                      Container(
                                        height: 60,
                                        width: 60,
                                        child: Stack(
                                          children: [
                                            Align(
                                                alignment: Alignment.topCenter,
                                                child: Text(
                                                  'Follows',
                                                )),
                                            Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Text(
                                                following.toString(),
                                                style: TextStyle(fontSize: 23),
                                              ),
                                            )
                                          ],
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
                                text: 'Statistics',
                              )
                            ])))
                  ];
                },
                body: Stack(
                  children: [
                    TabBarView(controller: _tabController, children: [
                      posts(),
                      Center(
                        child: Text('Statistics\'s content'),
                      )
                    ]),
                  ],
                ))
            : Center(
                child: CircularProgressIndicator(),
              ));
  }

  Widget posts() {
    return FutureBuilder(
        future: myposts,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: snapshot.data.docs.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, childAspectRatio: 1, crossAxisSpacing: 6),
              itemBuilder: (BuildContext context, int index) {
                DocumentSnapshot post = snapshot.data.docs[index];
                pointsPost =
                    (post.data()['up'].length - post.data()['down'].length);
                return post.data()['previewImage'] == null
                    ? Container(
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
                              bottom: 0,
                              right: 0,
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.remove_red_eye,
                                    color: Colors.white,
                                  ),
                                  Text('0')
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
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
                              bottom: 0,
                              right: 0,
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.remove_red_eye,
                                    color: Colors.white,
                                  ),
                                  Text('0')
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
