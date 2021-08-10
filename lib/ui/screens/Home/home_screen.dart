import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:gemu/models/user.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/ui/constants/constants.dart';

import 'game_section.dart';
import 'following_section.dart';

class HomeScreen extends StatefulWidget {
  final UserModel userActual;
  final List followings;
  final List<Game> games;

  HomeScreen({
    Key? key,
    required this.userActual,
    required this.followings,
    required this.games,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  bool dataIsThere = false;

  List<Game> gamesList = [];

  late TabController _tabMenuController;
  int currentTabMenuIndex = 1;
  int currentTabGamesIndex = 0;

  late AnimationController _animationRotateController,
      _animationGamesController;
  late Animation _animationRotate, _animationGames;

  void _onTabMenuChanged() {
    if (!_tabMenuController.indexIsChanging) {
      if (_animationRotateController.isCompleted) {
        _animationRotateController.reverse();
        _animationGamesController.reverse();
      }
      setState(() {
        currentTabMenuIndex = _tabMenuController.index;
      });
    }
  }

  double getRadianFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _tabMenuController = TabController(
        initialIndex: currentTabMenuIndex, length: 2, vsync: this);
    _tabMenuController.addListener(_onTabMenuChanged);

    gamesList = widget.games;

    _animationGamesController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animationGames = CurvedAnimation(
        parent: _animationGamesController, curve: Curves.easeOut);

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
  void deactivate() {
    _tabMenuController.removeListener(_onTabMenuChanged);
    super.deactivate();
  }

  @override
  void dispose() {
    _animationGamesController.dispose();
    _animationRotateController.dispose();
    _tabMenuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
        left: false,
        right: false,
        child: DefaultTabController(
            initialIndex: currentTabGamesIndex,
            length: gamesList.length,
            child: Stack(
              children: [
                bodyHome(gamesList[currentTabGamesIndex]),
                topHome(gamesList[currentTabGamesIndex]),
              ],
            )));
  }

  Widget topHome(Game game) {
    return Column(
      children: [
        topAppBar(game),
        bottomAppBar(),
        tabGames(gamesList),
      ],
    );
  }

  Widget topAppBar(Game game) {
    return Container(
      height: 55,
      alignment: Alignment.center,
      child: currentTabMenuIndex == 0
          ? Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10.0),
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).accentColor
                      ])),
              child: Icon(
                Icons.follow_the_signs_sharp,
                color: Colors.black,
                size: 30,
              ),
            )
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
                  border: Border.all(color: Colors.black),
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(game.imageUrl)))),
    );
  }

  Widget bottomAppBar() {
    return Container(
        height: 30.0,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 15.0),
        child: Align(
          alignment: Alignment.topCenter,
          child: TabBar(
              controller: _tabMenuController,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorWeight: 0.5,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(
                  child: currentTabMenuIndex == 0
                      ? Container(
                          alignment: Alignment.center,
                          child: Text('Followings', style: mystyle(16)),
                        )
                      : Text(
                          'Followings',
                          style: mystyle(13, Colors.grey),
                        ),
                ),
                Tab(
                  child: currentTabMenuIndex == 1
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Games', style: mystyle(16)),
                              Padding(
                                  padding: EdgeInsets.only(top: 1.0),
                                  child: Transform(
                                      transform: Matrix4.rotationZ(
                                          getRadianFromDegree(
                                              _animationRotate.value)),
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.expand_more,
                                      ))),
                            ],
                          ),
                        )
                      : Text(
                          'Games',
                          style: mystyle(13, Colors.grey),
                        ),
                ),
              ]),
        ));
  }

  Widget bodyHome(Game game) {
    return TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: _tabMenuController,
        children: [
          following,
          games(gamesList),
        ]);
  }

  Widget get following => FollowingSection(
        followings: widget.followings,
      );

  Widget tabGames(List<Game> games) {
    return Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: SizeTransition(
            sizeFactor: _animationGames as Animation<double>,
            child: Container(
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: TabBar(
                      onTap: (index) {
                        setState(() {
                          currentTabGamesIndex = index;
                        });
                      },
                      indicatorColor: Colors.transparent,
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Colors.grey,
                      isScrollable: true,
                      tabs: games.map((game) {
                        return Column(
                          children: [
                            Container(
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
                                  border: Border.all(color: Colors.black),
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: CachedNetworkImageProvider(
                                          game.imageUrl))),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              game.name,
                              style: TextStyle(
                                fontSize: 10,
                              ),
                            )
                          ],
                        );
                      }).toList()),
                ))));
  }

  Widget games(List<Game> games) {
    return TabBarView(
        physics: NeverScrollableScrollPhysics(),
        children: games.map((game) {
          return GameSection(
              game: game,
              animationGamesController: _animationGamesController,
              animationRotateController: _animationRotateController);
        }).toList());
  }
}
