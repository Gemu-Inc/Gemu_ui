import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gemu/models/game.dart';
import 'package:gemu/constants/constants.dart';
import 'package:gemu/providers/Home/index_games_provider.dart';
import 'package:gemu/providers/Users/myself_provider.dart';
import 'package:gemu/services/auth_service.dart';
import 'package:gemu/services/database_service.dart';
import 'package:gemu/components/alert_dialog_custom.dart';

import 'game_section.dart';
import 'following_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _Homeviewstate createState() => _Homeviewstate();
}

class _Homeviewstate extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  bool dataIsThere = false;

  late TabController _tabMenuController;
  int currentTabMenuIndex = 1;

  late PageController followingsPageController;

  late AnimationController _animationRotateController,
      _animationGamesController;
  late Animation _animationRotate, _animationGames;
  bool panelGamesThere = false;

  List<Game> gamesList = [];
  List<PageController> gamesControllerList = [];
  int indexGames = 0;
  List followings = [];

  //Vérifie si l'email de l'utilisateur est vérifié ou non
  Future<void> accountVerified(String uid) async {
    User? user = await AuthService.getUser();
    await user!.reload();
    user = await AuthService.getUser();
    if (!user!.emailVerified) {
      verifyAccount();
    } else {
      DatabaseService.updateVerifyAccount(me!.uid);
    }
  }

  void _onTabMenuChanged() async {
    if (_animationRotateController.isCompleted) {
      _animationRotateController.reverse();
      _animationGamesController.reverse();
      if (panelGamesThere) {
        await Future.delayed(Duration(milliseconds: 200));
        setState(() {
          panelGamesThere = false;
        });
      }
    }
    if (!_tabMenuController.indexIsChanging) {
      setState(() {
        currentTabMenuIndex = _tabMenuController.index;
      });
    }
  }

  void _onPageChanged() async {
    if (_animationRotateController.isCompleted) {
      _animationRotateController.reverse();
      _animationGamesController.reverse();
      if (panelGamesThere) {
        await Future.delayed(Duration(milliseconds: 200));
        setState(() {
          panelGamesThere = false;
        });
      }
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

    if (!me!.verifiedAccount!) {
      accountVerified(me!.uid);
    }

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
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    gamesControllerList[indexGames].addListener(_onPageChanged);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void deactivate() {
    _tabMenuController.removeListener(_onTabMenuChanged);
    gamesControllerList[indexGames].removeListener(_onPageChanged);
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
    gamesList = ref.read(myGamesNotifierProvider);
    gamesControllerList = ref.read(myGamesControllerNotifierProvider);
    indexGames = ref.watch(indexGamesNotifierProvider);

    return DefaultTabController(
      initialIndex: indexGames,
      length: gamesList.length,
      child: Scaffold(
        backgroundColor: Color(0xFF22213C),
        body: Stack(
          children: [
            bodyHome(gamesList[indexGames]),
            Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: topHome(gamesList[indexGames]),
            ),
          ],
        ),
      ),
    );
  }

  Widget topHome(Game game) {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      height: panelGamesThere
          ? MediaQuery.of(context).size.height / 4
          : MediaQuery.of(context).size.height / 6,
      child: Column(
        children: [
          topAppBar(),
          bottomAppBar(),
          tabGames(gamesList),
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
              if (followingsPageController.positions.isNotEmpty &&
                  followingsPageController.page != 0) {
                followingsPageController.jumpToPage(0);
              }
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
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary
                    ]),
              ),
              child: Icon(Icons.subscriptions, size: 30, color: Colors.black),
            ),
          );
        case 1:
          return GestureDetector(
            onTap: () {
              //voir comment faire pour dire qu'on ne rentre pas dans cette condition si 0 posts dans la section
              if (gamesControllerList[indexGames].positions.isNotEmpty &&
                  gamesControllerList[indexGames].page != 0) {
                gamesControllerList[indexGames].jumpToPage(0);
              }
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
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary
                      ]),
                  image: DecorationImage(
                      image: CachedNetworkImageProvider(
                          gamesList[indexGames].imageUrl),
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
              color: Theme.of(context).colorScheme.primary,
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
              indicatorColor: Theme.of(context).colorScheme.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 1.0,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              isScrollable: true,
              tabs: [
                Tab(
                  child: currentTabMenuIndex == 0
                      ? Text('Followings',
                          style: Theme.of(context).textTheme.bodySmall)
                      : Text(
                          'Followings',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                ),
                Tab(
                  child: currentTabMenuIndex == 1
                      ? GestureDetector(
                          onTap: () async {
                            if (_animationRotateController.isCompleted) {
                              _animationRotateController.reverse();
                              _animationGamesController.reverse();
                              if (panelGamesThere) {
                                await Future.delayed(
                                    Duration(milliseconds: 200));
                                setState(() {
                                  panelGamesThere = false;
                                });
                              }
                            } else {
                              if (!panelGamesThere) {
                                setState(() {
                                  panelGamesThere = true;
                                });
                              }

                              _animationRotateController.forward();
                              _animationGamesController.forward();
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Games',
                                  style: Theme.of(context).textTheme.bodySmall),
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
                          style: Theme.of(context).textTheme.bodySmall,
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
        followings: followings,
        pageController: followingsPageController,
      );

  Widget tabGames(List<Game> games) {
    return Consumer(builder: (_, ref, child) {
      return Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: SizeTransition(
              sizeFactor: _animationGames as Animation<double>,
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: TabBar(
                        onTap: (index) {
                          ref
                              .read(indexGamesNotifierProvider.notifier)
                              .updateIndex(index);
                        },
                        indicatorColor: Colors.transparent,
                        labelColor: Theme.of(context).colorScheme.primary,
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
                                          Theme.of(context).colorScheme.primary,
                                          Theme.of(context)
                                              .colorScheme
                                              .secondary
                                        ]),
                                    borderRadius: BorderRadius.circular(10.0),
                                    border: Border.all(
                                        width: 1.5,
                                        color: indexGames == indexGame
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
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
    });
  }

  Widget games(List<Game> games) {
    return TabBarView(
        physics: NeverScrollableScrollPhysics(),
        children: games.map((game) {
          return GameSection(
            game: game,
            animationGamesController: _animationGamesController,
            animationRotateController: _animationRotateController,
            panelGamesThere: panelGamesThere,
            pageController: gamesControllerList[indexGames],
          );
        }).toList());
  }
}
