import 'package:Gemu/screensmodels/Profil/profil_screen_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:stacked/stacked.dart';

class ProfilMenuDrawer extends StatefulWidget {
  @override
  _ProfilMenuDrawerState createState() => _ProfilMenuDrawerState();
}

class _ProfilMenuDrawerState extends State<ProfilMenuDrawer>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;

  TabController _tabController;

  bool isDrawer = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProfilScreenModel>.reactive(
      viewModelBuilder: () => ProfilScreenModel(),
      builder: (context, model, child) => isDrawer
          ? Drawer(
              child: Scaffold(
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
                          title: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser.uid)
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
                                      child: StreamBuilder(
                                          stream: FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(FirebaseAuth
                                                  .instance.currentUser.uid)
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return snapshot
                                                          .data['photoURL'] ==
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
                                                    alignment:
                                                        Alignment.topCenter,
                                                    child: Text(
                                                      'Followers',
                                                    )),
                                                Align(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: Text(
                                                    '0',
                                                    style:
                                                        TextStyle(fontSize: 23),
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
                                                    alignment:
                                                        Alignment.topCenter,
                                                    child: Text(
                                                      'Points',
                                                    )),
                                                Align(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: Text(
                                                    '0',
                                                    style:
                                                        TextStyle(fontSize: 23),
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
                                                    alignment:
                                                        Alignment.topCenter,
                                                    child: Text(
                                                      'Follows',
                                                    )),
                                                Align(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: Text(
                                                    '0',
                                                    style:
                                                        TextStyle(fontSize: 23),
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
                          Center(
                            child: Text('Publication\'s content'),
                          ),
                          Center(
                            child: Text('Statistics\'s content'),
                          )
                        ]),
                      ],
                    )),
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
                        title: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser.uid)
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
                                    child: StreamBuilder(
                                        stream: FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(FirebaseAuth
                                                .instance.currentUser.uid)
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return snapshot.data['photoURL'] ==
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
                                                                snapshot.data[
                                                                    'photoURL']))),
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
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: Text(
                                                    'Followers',
                                                  )),
                                              Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Text(
                                                  '0',
                                                  style:
                                                      TextStyle(fontSize: 23),
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
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: Text(
                                                    'Points',
                                                  )),
                                              Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Text(
                                                  '0',
                                                  style:
                                                      TextStyle(fontSize: 23),
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
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: Text(
                                                    'Follows',
                                                  )),
                                              Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Text(
                                                  '0',
                                                  style:
                                                      TextStyle(fontSize: 23),
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
                        Center(
                          child: Text('Publication\'s content'),
                        ),
                        Center(
                          child: Text('Statistics\'s content'),
                        )
                      ]),
                    ],
                  )),
            ),
    );
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
