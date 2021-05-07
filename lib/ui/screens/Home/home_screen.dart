import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:Gemu/screensmodels/Home/home_screen_model.dart';
import 'package:Gemu/models/game.dart';

import 'post_view_game.dart';
import 'post_view_following.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool dataIsThere = false;

  TabController? _tabMenuController;

  late AnimationController _animationRotateController,
      _animationGamesController;
  late Animation _animationRotate, _animationGames;

  late int currentTabIndex;
  late int currentTabGamesIndex;

  List<Game> gamesList = [];
  String? uid;
  late DocumentSnapshot<Map<String, dynamic>> user;

  @override
  void initState() {
    super.initState();

    _tabMenuController = TabController(initialIndex: 1, length: 2, vsync: this);
    _tabMenuController!.addListener(_onTabChanged);
    currentTabIndex = 1;
    currentTabGamesIndex = 0;

    _animationGamesController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animationGames = CurvedAnimation(
        parent: _animationGamesController, curve: Curves.easeInCubic);
    _animationRotateController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animationRotate = Tween<double>(begin: 0.0, end: 180.0).animate(
        CurvedAnimation(
            parent: _animationRotateController, curve: Curves.easeOut));
    _animationRotateController.addListener(() {
      setState(() {});
    });

    getAllData();
  }

  @override
  void dispose() {
    _animationGamesController.dispose();
    _animationRotateController.dispose();
    _tabMenuController!.removeListener(_onTabChanged);
    _tabMenuController!.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabMenuController!.indexIsChanging) {
      if (_animationRotateController.isCompleted) {
        _animationRotateController.reverse();
        _animationGamesController.reverse();
      }
      setState(() {
        print('Changing to Tab: ${_tabMenuController!.index}');
        currentTabIndex = _tabMenuController!.index;
      });
    }
  }

  double getRadianFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  getAllData() async {
    uid = FirebaseAuth.instance.currentUser!.uid;
    user = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (mounted) {
      setState(() {
        dataIsThere = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    gamesList = Provider.of<List<Game>>(context);
    return dataIsThere && gamesList.length != 0
        ? Stack(
            children: <Widget>[
              TabBarView(controller: _tabMenuController, children: [
                middleSectionFollowing, //Following
                DefaultTabController(
                    initialIndex: currentTabGamesIndex,
                    length: gamesList.length,
                    child: Stack(children: [
                      TabBarView(
                          physics: NeverScrollableScrollPhysics(),
                          children: gamesList.map((game) {
                            return PostViewGame(
                                game: game,
                                animationGamesController:
                                    _animationGamesController,
                                animationRotateController:
                                    _animationRotateController);
                          }).toList()),
                      Positioned(
                          top: MediaQuery.of(context).size.height / 5,
                          child: SizeTransition(
                            sizeFactor: _animationGames as Animation<double>,
                            child: Container(
                                height: MediaQuery.of(context).size.height / 9,
                                width: MediaQuery.of(context).size.width,
                                child: Center(
                                  child: TabBar(
                                      indicatorColor: Colors.transparent,
                                      labelColor:
                                          Theme.of(context).primaryColor,
                                      unselectedLabelColor: Colors.grey,
                                      isScrollable: true,
                                      onTap: (index) {
                                        if (_animationRotateController
                                            .isCompleted) {
                                          _animationRotateController.reverse();
                                          _animationGamesController.reverse();
                                        }
                                        setState(() {
                                          currentTabGamesIndex = index;
                                          print(
                                              'current index games: $currentTabGamesIndex');
                                        });
                                      },
                                      tabs: gamesList.map((game) {
                                        return Column(
                                          children: [
                                            Container(
                                              height: 50,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        Theme.of(context)
                                                            .primaryColor,
                                                        Theme.of(context)
                                                            .accentColor
                                                      ]),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  border: Border.all(
                                                      color: Color(0xFF222831)),
                                                  image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image:
                                                          CachedNetworkImageProvider(
                                                              game.imageUrl!))),
                                            ),
                                            SizedBox(
                                              height: 5.0,
                                            ),
                                            Text(
                                              '${game.name}',
                                              style: TextStyle(
                                                fontSize: 10,
                                              ),
                                            )
                                          ],
                                        );
                                      }).toList()),
                                )),
                          ))
                    ]))
              ]),
              Column(
                children: [
                  topBarHome(gamesList, currentTabGamesIndex),
                  followingContainer
                ],
              ),
            ],
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }

  Widget topBarHome(List<Game> game, int index) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: user.data()!['photoURL'] == null
          ? Builder(
              builder: (context) => GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Container(
                  margin: EdgeInsets.all(3.0),
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                      color: Color(0xFF222831).withOpacity(0.7),
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(0xFF222831))),
                  child: Icon(
                    Icons.person,
                    size: 30,
                  ),
                ),
              ),
            )
          : profilButton(context),
      actions: [
        Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openEndDrawer(),
            child: Container(
              margin: EdgeInsets.only(top: 7.5, bottom: 7.5, right: 5.0),
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                      color: Theme.of(context).canvasColor.withOpacity(0.5))),
              child: Icon(Icons.notifications_active,
                  size: 28, color: Theme.of(context).accentColor),
            ),
          ),
        ),
      ],
      title: PreferredSize(
          child: currentTabIndex == 0
              ? SizedBox()
              : Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).accentColor
                          ]),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Color(0xFF222831)),
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(
                              game[index].imageUrl!)))),
          preferredSize: Size.fromHeight(50)),
      centerTitle: true,
    );
  }

  Widget profilButton(BuildContext context) {
    return GestureDetector(
        onTap: () => Scaffold.of(context).openDrawer(),
        child: Opacity(
          opacity: 0.7,
          child: Container(
            margin: EdgeInsets.only(top: 3.0, left: 3.0),
            width: 45,
            height: 45,
            decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: Color(0xFF222831)),
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image:
                        CachedNetworkImageProvider(user.data()!['photoURL']))),
          ),
        ));
  }

  Widget get followingContainer => Container(
      height: 100.0,
      width: 225.0,
      margin: EdgeInsets.only(top: 5.0),
      child: Align(
        alignment: Alignment.topCenter,
        child: TabBar(
            controller: _tabMenuController,
            indicatorColor: Colors.transparent,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(
                child: currentTabIndex == 0
                    ? Text('Following',
                        style: TextStyle(
                            fontSize: 17.0, fontWeight: FontWeight.bold))
                    : Text(
                        'Following',
                        style: TextStyle(color: Colors.grey),
                      ),
              ),
              Tab(
                child: currentTabIndex == 1
                    ? GestureDetector(
                        onTap: () {
                          if (_animationRotateController.isCompleted) {
                            _animationRotateController.reverse();
                            _animationGamesController.reverse();
                          } else {
                            _animationRotateController.forward();
                            _animationGamesController.forward();
                          }
                        },
                        child: Row(
                          children: [
                            Text('Games',
                                style: TextStyle(
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.bold)),
                            Transform(
                                transform: Matrix4.rotationZ(
                                    getRadianFromDegree(
                                        _animationRotate.value)),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.expand_more,
                                ))
                          ],
                        ),
                      )
                    : Text(
                        'Games',
                        style: TextStyle(color: Colors.grey),
                      ),
              ),
            ]),
      ));

  Widget get middleSectionFollowing => PostViewFollowing();
}
