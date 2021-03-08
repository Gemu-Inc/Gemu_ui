import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import 'package:Gemu/constants/variables.dart';
import 'package:Gemu/screensmodels/Home/home_screen_model.dart';
import 'package:Gemu/ui/widgets/top_toolbar.dart';
import 'package:Gemu/ui/widgets/actions_postbar.dart';
import 'package:Gemu/ui/widgets/content_postdescription.dart';
import 'package:Gemu/models/game.dart';

import 'components/picture_item.dart';
import 'components/video_player_item.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  TabController _tabMenuController;
  PageController _pageFollowingController, _pageGamesController;

  AnimationController _animationRotateController, _animationGamesController;
  Animation _animationRotate, _animationGames;

  int currentTabIndex,
      currentTabGamesIndex,
      currentPageFollowingIndex,
      currentPageGamesIndex;

  List<Game> gamesList;

  @override
  void initState() {
    super.initState();

    /*gamesList = Provider.of<List<Game>>(context, listen: false);
    print(gamesList);*/

    _tabMenuController = TabController(initialIndex: 1, length: 2, vsync: this);
    _tabMenuController.addListener(_onTabChanged);
    currentTabIndex = 1;
    currentTabGamesIndex = 0;

    _pageFollowingController = PageController();
    currentPageFollowingIndex = 0;

    _pageGamesController = PageController();
    currentPageGamesIndex = 0;

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
    _pageFollowingController.dispose();
    _pageGamesController.dispose();
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
        currentPageGamesIndex = 0;
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

  Widget get middleSectionFollowing => PageView.builder(
      controller: _pageFollowingController,
      scrollDirection: Axis.vertical,
      onPageChanged: (index) => setState(() {
            currentPageFollowingIndex = index;
          }),
      itemCount: 6,
      itemBuilder: (context, index) => Stack(children: [
            Container(
              decoration: BoxDecoration(color: Colors.black),
            ),
            Positioned(left: 0, bottom: 80, child: ContentPostDescription()),
            Positioned(right: 0, bottom: 80, child: ActionsPostBar())
          ]));

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
                            return StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('posts')
                                  .doc(game.documentId)
                                  .collection(game.name)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (snapshot.data.docs.length == 0) {
                                  return Center(
                                    child: Text(
                                      'Pas encore de posts pour ce jeu',
                                      style: mystyle(11),
                                    ),
                                  );
                                }
                                return PageView.builder(
                                    controller: _pageGamesController,
                                    scrollDirection: Axis.vertical,
                                    onPageChanged: (index) {
                                      setState(() {
                                        currentPageGamesIndex = index;
                                        print(
                                            'currentPageGamesIndex est à: $currentPageGamesIndex');
                                      });
                                      if (_animationRotateController
                                          .isCompleted) {
                                        _animationRotateController.reverse();
                                        _animationGamesController.reverse();
                                      }
                                    },
                                    itemCount: snapshot.data.docs.length,
                                    itemBuilder: (context, index) {
                                      DocumentSnapshot post =
                                          snapshot.data.docs[index];

                                      return Stack(children: [
                                        post.data()['videoUrl'] == null
                                            ? PictureItem(
                                                pictureUrl:
                                                    post.data()['pictureUrl'],
                                              )
                                            : VideoPlayerItem(
                                                videoUrl:
                                                    post.data()['videoUrl'],
                                              ),
                                        Positioned(
                                            left: 0,
                                            bottom: 80,
                                            child: ContentPostDescription()),
                                        Positioned(
                                            right: 0,
                                            bottom: 80,
                                            child: ActionsPostBar())
                                      ]);
                                    });
                              },
                            );
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
                  currentPageGamesIndex: currentPageGamesIndex,
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
