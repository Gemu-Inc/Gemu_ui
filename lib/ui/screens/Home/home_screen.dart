import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:gemu/ui/constants/constants.dart';

import 'post_view_game.dart';
import 'post_view_following.dart';

class HomeScreen extends StatefulWidget {
  final String uid;

  HomeScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  bool dataIsThere = false;

  String? userImageUrl;

  late TabController _tabMenuController;

  late AnimationController _animationRotateController,
      _animationGamesController;
  late Animation _animationRotate, _animationGames;

  late int currentTabIndex;
  late int currentTabGamesIndex;

  List gamesList = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    userImageUrl = me!.imageUrl;

    _tabMenuController = TabController(initialIndex: 1, length: 2, vsync: this);
    _tabMenuController.addListener(_onTabChanged);
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (gamesList.length != 0) {
      gamesList.clear();
    }
    getUserGames();
  }

  @override
  void dispose() {
    _animationGamesController.dispose();
    _animationRotateController.dispose();
    _tabMenuController.removeListener(_onTabChanged);
    _tabMenuController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabMenuController.indexIsChanging) {
      if (_animationRotateController.isCompleted) {
        _animationRotateController.reverse();
        _animationGamesController.reverse();
      }
      setState(() {
        print('Changing to Tab: ${_tabMenuController.index}');
        currentTabIndex = _tabMenuController.index;
      });
    }
  }

  double getRadianFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  getUserGames() async {
    var games = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('games')
        .get();

    for (var item in games.docs) {
      var game = await FirebaseFirestore.instance
          .collection('games')
          .doc(item.id)
          .get();
      gamesList.add(game);
    }

    if (mounted) {
      setState(() {
        dataIsThere = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return dataIsThere && gamesList.length != 0
        ? Stack(
            children: <Widget>[
              TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: _tabMenuController,
                  children: [
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
                                sizeFactor:
                                    _animationGames as Animation<double>,
                                child: Container(
                                    height:
                                        MediaQuery.of(context).size.height / 9,
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
                                              _animationRotateController
                                                  .reverse();
                                              _animationGamesController
                                                  .reverse();
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
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment.bottomRight,
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
                                                          color: Color(
                                                              0xFF222831)),
                                                      image: DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: CachedNetworkImageProvider(
                                                              game.data()[
                                                                  'imageUrl']))),
                                                ),
                                                SizedBox(
                                                  height: 5.0,
                                                ),
                                                Text(
                                                  '${game.data()['name']}',
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

  Widget topBarHome(List game, int index) {
    final double statusbarHeight = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.only(top: statusbarHeight),
      child: Container(
        height: 55,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: userImageUrl == null
                  ? Builder(
                      builder: (context) => GestureDetector(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: Container(
                          margin: EdgeInsets.all(3.0),
                          height: 40,
                          width: 40,
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
            ),
            currentTabIndex == 0
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
                                game[index].data()['imageUrl'])))),
            Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: Opacity(
                  opacity: 0.7,
                  child: GestureDetector(
                    onTap: () => Scaffold.of(context).openEndDrawer(),
                    child: Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                          color: Theme.of(context).canvasColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black)),
                      child: Icon(Icons.notifications_active,
                          size: 28, color: Theme.of(context).accentColor),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget profilButton(BuildContext context) {
    return Opacity(
        opacity: 0.7,
        child: GestureDetector(
          onTap: () => Scaffold.of(context).openDrawer(),
          child: Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                shape: BoxShape.circle,
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(userImageUrl!))),
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
