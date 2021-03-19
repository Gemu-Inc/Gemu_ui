import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import 'package:Gemu/screensmodels/Home/home_screen_model.dart';
import 'package:Gemu/ui/widgets/top_toolbar.dart';
import 'package:Gemu/models/game.dart';

import 'post_view_game.dart';
import 'post_view_following.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  TabController _tabMenuController;

  AnimationController _animationRotateController, _animationGamesController;
  Animation _animationRotate, _animationGames;

  int currentTabIndex, currentTabGamesIndex;

  List<Game> gamesList;

  @override
  void initState() {
    super.initState();

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
  void dispose() {
    _tabMenuController.dispose();
    _animationGamesController.dispose();
    _animationRotateController.dispose();
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

  @override
  Widget build(BuildContext context) {
    gamesList = Provider.of<List<Game>>(context);
    return ViewModelBuilder<HomeScreenModel>.reactive(
      disposeViewModel: false,
      viewModelBuilder: () => HomeScreenModel(),
      builder: (context, model, child) => Stack(
        children: <Widget>[
          TabBarView(controller: _tabMenuController, children: [
            middleSectionFollowing, //Following
            gamesList != null //Games
                ? DefaultTabController(
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
                            sizeFactor: _animationGames,
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
                                                              game.imageUrl))),
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
                : Center(
                    child: CircularProgressIndicator(),
                  )
          ]),
          Column(
            children: [
              TopToolBarHome(
                  model: model,
                  gradient1: Colors.transparent,
                  gradient2: Colors.transparent,
                  elevationBar: 0,
                  currentTabGamesIndex: currentTabGamesIndex,
                  currentTabIndex: currentTabIndex,
                  game: gamesList),
              followingContainer
            ],
          ),
        ],
      ),
    );
  }
}
