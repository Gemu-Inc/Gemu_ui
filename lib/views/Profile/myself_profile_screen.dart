import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/services/database_service.dart';
import 'package:gemu/views/Profile/followers.dart';
import 'package:gemu/views/Profile/follows.dart';
import 'package:gemu/views/Profile/posts_profil.dart';

class MyselfProfileScreen extends ConsumerStatefulWidget {
  const MyselfProfileScreen({Key? key}) : super(key: key);

  @override
  _MyselfProfileScreen createState() => _MyselfProfileScreen();
}

class _MyselfProfileScreen extends ConsumerState<MyselfProfileScreen>
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
                              onPressed: () => navProfileAuthKey!.currentState!
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
