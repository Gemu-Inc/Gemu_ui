import 'dart:io' show Platform;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemu/components/bottom_sheet_custom.dart';

import 'package:gemu/models/game.dart';
import 'package:gemu/constants/constants.dart';
import 'package:gemu/providers/Home/home_provider.dart';
import 'package:gemu/services/auth_service.dart';
import 'package:gemu/services/database_service.dart';
import 'package:gemu/components/alert_dialog_custom.dart';

import 'game_section.dart';
import 'followings_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _Homeviewstate createState() => _Homeviewstate();
}

class _Homeviewstate extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabMenuController;
  int currentTabMenuIndex = 1;

  late PageController gamesFollowingsController, usersFollowingsController;

  late AnimationController _animationRotateController,
      _animationGamesController;
  late Animation _animationRotate, _animationGames;

  List<Game> gamesTab = [];

  //Vérifie si l'email de l'utilisateur est vérifié ou non
  Future<void> accountVerified(String uid) async {
    User? user = await AuthService.getUser();
    await user!.reload();
    user = await AuthService.getUser();
    if (!user!.emailVerified) {
      verifyAccount(context);
    } else {
      DatabaseService.updateVerifyAccount(me!.uid);
    }
  }

  void _onTabMenuChanged() async {
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

    if (!me!.verifiedAccount!) {
      accountVerified(me!.uid);
    }

    _tabMenuController = TabController(
        initialIndex: currentTabMenuIndex, length: 2, vsync: this);
    _tabMenuController.addListener(_onTabMenuChanged);

    gamesFollowingsController = PageController();
    usersFollowingsController = PageController();

    _animationGamesController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animationGames = CurvedAnimation(
        parent: _animationGamesController, curve: Curves.easeOut);

    _animationRotateController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
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
    gamesFollowingsController.dispose();
    usersFollowingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    gamesTab = ref.watch(gamesTabNotifierProvider);

    return Scaffold(
        backgroundColor: Color(0xFF22213C),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: Platform.isIOS
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle(
                  statusBarColor: Color(0xFF22213C).withOpacity(0.3),
                  statusBarIconBrightness: Brightness.light,
                  systemNavigationBarColor: Color(0xFF22213C),
                  systemNavigationBarIconBrightness: Brightness.light),
          child: Stack(
            children: [
              bodyHome(),
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 15),
                child: topHome(),
              ),
            ],
          ),
        ));
  }

  Widget topHome() {
    return Container(
      child: Column(
        children: [topAppBar(), bottomAppBar(), listGamesFollowings()],
      ),
    );
  }

  Widget topAppBar() {
    return Builder(builder: (_) {
      switch (currentTabMenuIndex) {
        case 0:
          return GestureDetector(
            onTap: () {
              if (usersFollowingsController.positions.isNotEmpty &&
                  usersFollowingsController.page != 0) {
                usersFollowingsController.jumpToPage(0);
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
              if (gamesFollowingsController.positions.isNotEmpty &&
                  gamesFollowingsController.page != 0) {
                gamesFollowingsController.jumpToPage(0);
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
              child: Icon(Icons.videogame_asset, size: 30, color: Colors.black),
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
                              Theme.of(context).colorScheme.primary, 17)
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
                          } else {
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
                                  Theme.of(context).colorScheme.primary, 17),
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

  Widget listGamesFollowings() {
    return SizeTransition(
      sizeFactor: _animationGames as Animation<double>,
      child: Container(
          height: 110,
          child: Center(
              child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  itemCount: gamesTab.length,
                  itemBuilder: (_, index) {
                    Game game = gamesTab[index];

                    return game.name == "Ajouter"
                        ? Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: SizedBox(
                              width: 60,
                              child: GestureDetector(
                                onTap: () => gamesBottomSheet(
                                  navMainAuthKey.currentContext!,
                                ),
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
                                        borderRadius:
                                            BorderRadius.circular(10.0),
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
                                      style: textStyleCustomRegular(
                                          Colors.white, 12),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: SizedBox(
                              width: 60,
                              child: GestureDetector(
                                onTap: () => navHomeAuthKey!.currentState!
                                    .pushNamed(GameProfile,
                                        arguments: [game, navHomeAuthKey]),
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
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          border: Border.all(
                                              width: 1.5, color: Colors.white),
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
                                          Colors.white, 12),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                  }))),
    );
  }

  Widget bodyHome() {
    return TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: _tabMenuController,
        children: [
          following,
          games,
        ]);
  }

  Widget get following => FollowingSection(
        pageController: usersFollowingsController,
      );

  Widget get games => GameSection(
      pageController: gamesFollowingsController,
      animationGamesController: _animationGamesController,
      animationRotateController: _animationRotateController);
}
