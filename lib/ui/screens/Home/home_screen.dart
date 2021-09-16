import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';

import 'package:gemu/models/user.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/ui/providers/index_tab_games_home.dart';

import 'game_section.dart';
import 'following_section.dart';

class HomeScreen extends StatefulWidget {
  final UserModel userActual;
  final List followings;
  final List<Game> games;
  final List<PageController> gamePageController;
  final IndexGamesHome indexGamesHome;

  HomeScreen(
      {Key? key,
      required this.userActual,
      required this.followings,
      required this.games,
      required this.gamePageController,
      required this.indexGamesHome})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  bool dataIsThere = false;

  late TabController _tabMenuController;
  int currentTabMenuIndex = 1;

  int currentTabGamesIndex = 0;

  late PageController followingsPageController;

  late AnimationController _animationRotateController,
      _animationGamesController;
  late Animation _animationRotate, _animationGames;

  void _onTabMenuChanged() {
    if (_animationRotateController.isCompleted) {
      _animationRotateController.reverse();
      _animationGamesController.reverse();
    }
    if (!_tabMenuController.indexIsChanging) {
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

    followingsPageController = PageController();

    _animationGamesController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    _animationGames = CurvedAnimation(
        parent: _animationGamesController, curve: Curves.easeOut);

    _animationRotateController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
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
    currentTabGamesIndex = widget.indexGamesHome.getIndex();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black),
      child: SafeArea(
          left: false,
          right: false,
          child: DefaultTabController(
            initialIndex: currentTabGamesIndex,
            length: widget.games.length,
            child: Scaffold(
              backgroundColor: Colors.black,
              appBar: PreferredSize(
                  child: AppBar(
                    backgroundColor: Colors.black,
                  ),
                  preferredSize: Size.fromHeight(0)),
              body: Stack(
                children: [
                  bodyHome(widget.games[currentTabGamesIndex]),
                  topHome(widget.games[currentTabGamesIndex])
                ],
              ),
            ),
          )),
    );
  }

  Widget topHome(Game game) {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      height: MediaQuery.of(context).size.height / 4,
      color: Colors.transparent,
      child: Column(
        children: [
          topAppBar(),
          bottomAppBar(),
          tabGames(widget.games),
        ],
      ),
    );
  }

  Widget topAppBar() {
    return Builder(builder: (_) {
      switch (currentTabMenuIndex) {
        case 0:
          return GestureDetector(
            onTap: () {
              followingsPageController.jumpToPage(0);
            },
            child: Container(
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
                    ]),
              ),
              child: Icon(Icons.subscriptions, size: 30, color: Colors.black),
            ),
          );
        case 1:
          return GestureDetector(
            onTap: () {
              widget.gamePageController[currentTabGamesIndex].jumpToPage(0);
            },
            child: Container(
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
                      ]),
                  image: DecorationImage(
                      image: CachedNetworkImageProvider(
                          widget.games[currentTabGamesIndex].imageUrl),
                      fit: BoxFit.cover)),
            ),
          );
        default:
          return Container(
            height: 50,
            width: 50,
            alignment: Alignment.center,
            color: Colors.grey,
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
              strokeWidth: 1.5,
            ),
          );
      }
    });
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
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              indicatorColor: Theme.of(context).primaryColor,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 1.0,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              isScrollable: true,
              tabs: [
                Tab(
                  child: currentTabMenuIndex == 0
                      ? Text('Followings', style: mystyle(15))
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
                              Text('Games', style: mystyle(15)),
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
          games(widget.games),
        ]);
  }

  Widget get following => FollowingSection(
        followings: widget.followings,
        pageController: followingsPageController,
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
                        widget.indexGamesHome.setIndex(index);
                        currentTabGamesIndex = widget.indexGamesHome.getIndex();
                      },
                      indicatorColor: Colors.transparent,
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Colors.grey,
                      isScrollable: true,
                      tabs: games.map((game) {
                        int indexGame = games.indexOf(game);
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
                                  border: Border.all(
                                      width: 1.5,
                                      color: currentTabGamesIndex == indexGame
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey),
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
            animationRotateController: _animationRotateController,
            pageController: widget.gamePageController[currentTabGamesIndex],
          );
        }).toList());
  }
}
