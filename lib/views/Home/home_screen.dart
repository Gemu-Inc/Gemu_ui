import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemu/components/bottom_sheet_custom.dart';

import 'package:gemu/models/game.dart';
import 'package:gemu/constants/constants.dart';
import 'package:gemu/providers/Home/home_provider.dart';
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
    with TickerProviderStateMixin {
  late TabController _tabMenuController;
  int currentTabMenuIndex = 1;

  late PageController followingsPageController;
  late PageController gamesController;

  late AnimationController _animationRotateController,
      _animationGamesController;
  late Animation _animationRotate, _animationGames;
  bool panelGamesThere = false;

  List<Game> gamesTab = [];
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

  double getRadianFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

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
    gamesController = PageController();

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
    gamesTab = ref.watch(gamesTabNotifierProvider);
    gamesControllerList = ref.watch(myGamesControllerNotifierProvider);
    indexGames = ref.watch(indexGamesNotifierProvider);

    return Scaffold(
        backgroundColor: Color(0xFF22213C),
        body: Stack(
          children: [
            bodyHome(),
            Padding(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).padding.top + 15),
              child: topHome(gamesTab[indexGames]),
            ),
          ],
        ));
  }

  Widget topHome(Game game) {
    return Container(
      child: Column(
        children: [topAppBar(), bottomAppBar(), tabGames(gamesTab)],
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
              height: 65,
              width: 45,
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
              child: Icon(Icons.people_alt, size: 30, color: Colors.black),
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
              height: 65,
              width: 45,
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
                          gamesTab[indexGames].imageUrl),
                      fit: BoxFit.cover)),
            ),
          );
        default:
          return Container(
            height: 65,
            width: 45,
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
        height: 50,
        width: MediaQuery.of(context).size.width,
        child: TabBar(
            controller: _tabMenuController,
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            indicatorColor: Colors.transparent,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor:
                Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.primary == cPrimaryPink
                        ? cInactiveIconPinkDarkTheme
                        : cInactiveIconPurpleDarkTheme
                    : Theme.of(context).colorScheme.primary == cPrimaryPink
                        ? cInactiveIconPinkLightTheme
                        : cInactiveIconPurpleLightTheme,
            isScrollable: false,
            tabs: [
              Container(
                  width: MediaQuery.of(context).size.width / 2,
                  alignment: Alignment.center,
                  child: Text('Abonnements',
                      style: currentTabMenuIndex == 0
                          ? textStyleCustomBold(
                              Theme.of(context).colorScheme.primary, 14)
                          : textStyleCustomBold(Colors.white, 14))),
              Container(
                width: MediaQuery.of(context).size.width / 2,
                alignment: Alignment.center,
                child: currentTabMenuIndex == 1
                    ? GestureDetector(
                        onTap: () async {
                          if (_animationRotateController.isCompleted) {
                            _animationRotateController.reverse();
                            _animationGamesController.reverse();
                            if (panelGamesThere) {
                              await Future.delayed(Duration(milliseconds: 200));
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
                            Text(
                              'Jeux suivis',
                              style: textStyleCustomBold(
                                  Theme.of(context).colorScheme.primary, 14),
                            ),
                            Padding(
                                padding: EdgeInsets.only(top: 3.0),
                                child: Transform(
                                    transform: Matrix4.rotationZ(
                                        getRadianFromDegree(
                                            _animationRotate.value)),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.expand_more,
                                      size: 26,
                                    ))),
                          ],
                        ),
                      )
                    : Text(
                        'Jeux suivis',
                        style: textStyleCustomBold(Colors.white, 14),
                      ),
              ),
            ]));
  }

  Widget bodyHome() {
    return TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: _tabMenuController,
        children: [
          following,
          games(gamesTab),
        ]);
  }

  Widget get following => FollowingSection(
        followings: followings,
        pageController: followingsPageController,
      );

  Widget tabGames(List<Game> games) {
    return SizeTransition(
      sizeFactor: _animationGames as Animation<double>,
      child: Container(
        height: 105,
        child: Center(
          child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: gamesTab.length,
              itemBuilder: (_, index) {
                Game game = gamesTab[index];
                return game.name == "Ajouter"
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: SizedBox(
                          width: 55,
                          child: GestureDetector(
                            onTap: () => gamesBottomSheet(
                                navMainAuthKey.currentContext!,
                                gamesController),
                            child: Column(
                              children: [
                                Container(
                                  height: 65,
                                  width: 45,
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
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                                Text(
                                  game.name,
                                  style:
                                      textStyleCustomRegular(Colors.white, 12),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: SizedBox(
                          width: 55,
                          child: GestureDetector(
                            onTap: () {
                              ref
                                  .read(indexGamesNotifierProvider.notifier)
                                  .updateIndex(index);
                              gamesController.jumpToPage(index);
                            },
                            child: Column(
                              children: [
                                Container(
                                  height: 65,
                                  width: 45,
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            Theme.of(context)
                                                .colorScheme
                                                .secondary
                                          ]),
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(
                                          width: 1.5,
                                          color: indexGames == index
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Colors.white),
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
                                  textAlign: TextAlign.center,
                                  style: textStyleCustomRegular(
                                      indexGames == index
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Colors.white,
                                      12),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
              }),
        ),
      ),
    );
  }

  Widget games(List<Game> games) {
    return PageView.builder(
        controller: gamesController,
        physics: NeverScrollableScrollPhysics(),
        itemCount: gamesTab.length,
        itemBuilder: (_, int index) {
          print(index);
          Game game = games[index];
          PageController gameController = gamesControllerList[index];
          return GameSection(
            game: game,
            animationGamesController: _animationGamesController,
            animationRotateController: _animationRotateController,
            panelGamesThere: panelGamesThere,
            pageController: gameController,
          );
        });
  }
}
