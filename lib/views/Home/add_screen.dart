import 'dart:io' show Platform;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gemu/components/loader_overlay_custom.dart';
import 'package:gemu/components/snack_bar_custom.dart';
import 'package:gemu/providers/Games/games_discover_provider.dart';
import 'package:gemu/providers/Users/myself_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gemu/constants/constants.dart';

import 'package:gemu/models/game.dart';
import 'package:gemu/models/categorie.dart';
import 'package:gemu/components/alert_dialog_custom.dart';
import 'package:gemu/services/database_service.dart';

class AddScreen extends ConsumerStatefulWidget {
  const AddScreen({Key? key}) : super(key: key);

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends ConsumerState<AddScreen>
    with SingleTickerProviderStateMixin {
  ScrollController _mainScrollController = ScrollController();

  bool dataIsThere = false;
  bool loadMoreCategorie = false;
  List<Categorie> categoriesList = [];

  List<Game> gamesList = [];

  bool loadingDiscover = false;
  late bool isLoadingMoreData;
  late bool stopReached;
  List<Game> gamesDiscover = [];
  List<Game> newGamesDiscover = [];

  loadMoreData() async {
    try {
      Game game = gamesDiscover.last;

      ref.read(loadingMoreGamesDiscoverNotifierProvider.notifier).update(true);

      await DatabaseService.loadMoreGamesDiscover(context, ref, game);

      ref.read(loadingMoreGamesDiscoverNotifierProvider.notifier).update(false);
      if (ref.read(newGamesDiscoverNotifierProvider).length == 0) {
        ref.read(stopReachedDiscoverNotifierProvider.notifier).update();
      }
    } catch (e) {
      print(e);
      messageUser(context, "Oups un problème est survenu!");
    }
  }

  Future alertUnfollowGame(Game game, BuildContext context, WidgetRef ref,
      List<Game> gamesList, bool stopReached) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white24
            : Colors.black54,
        builder: (context) {
          return AlertDialogCustom(context, 'Ne plus suivre',
              'Veux-tu retirer ce jeu de tes jeux suivis?', [
            TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  LoaderOverlayCustom.showLoader(context);
                  await DatabaseService.unfollowGame(
                      context, game, ref, gamesList, stopReached);
                  LoaderOverlayCustom.hideLoader();
                },
                child: Text(
                  'Oui',
                  style: TextStyle(color: cGreenConfirm),
                )),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Non',
                  style: TextStyle(color: cRedCancel),
                )),
          ]);
        });
  }

  Future alertFollowGame(Game game, BuildContext context, WidgetRef ref) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white24
            : Colors.black54,
        builder: (context) {
          return AlertDialogCustom(
              context, 'Suivre', 'Veux-tu ajouter ce jeu à tes jeux suivis?', [
            TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  LoaderOverlayCustom.showLoader(context);
                  await DatabaseService.followGame(context, game, ref);
                  LoaderOverlayCustom.hideLoader();
                },
                child: Text(
                  'Oui',
                  style: TextStyle(color: cGreenConfirm),
                )),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Non',
                  style: TextStyle(color: cRedCancel),
                )),
          ]);
        });
  }

  @override
  void initState() {
    super.initState();

    if (!ref.read(loadingGamesDiscoverNotifierProvider.notifier).getState) {
      DatabaseService.getGamesDiscover(context, ref);
    }

    _mainScrollController.addListener(() {
      if (_mainScrollController.offset >=
              _mainScrollController.position.maxScrollExtent &&
          !_mainScrollController.position.outOfRange &&
          !stopReached) {
        loadMoreData();
      }
    });
  }

  @override
  void deactivate() {
    _mainScrollController.removeListener(() {
      if (_mainScrollController.offset >=
              _mainScrollController.position.maxScrollExtent &&
          !_mainScrollController.position.outOfRange &&
          !stopReached) {
        loadMoreData();
      }
    });
    super.deactivate();
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    gamesList = ref.watch(myGamesNotifierProvider);

    loadingDiscover = ref.watch(loadingGamesDiscoverNotifierProvider);
    gamesDiscover = ref.watch(gamesDiscoverNotifierProvider);
    newGamesDiscover = ref.watch(newGamesDiscoverNotifierProvider);
    isLoadingMoreData = ref.watch(loadingMoreGamesDiscoverNotifierProvider);
    stopReached = ref.read(stopReachedDiscoverNotifierProvider);

    return WillPopScope(
      onWillPop: () async {
        navMainAuthKey.currentState!.pop();
        return false;
      },
      child: GestureDetector(
        onHorizontalDragStart: (details) {
          if (details.globalPosition.dx <= 75 && details.globalPosition.distance > 15.0) {
            navMainAuthKey.currentState!.pop();
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            child: ClipRRect(
                child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: AppBar(
                automaticallyImplyLeading: false,
                elevation: 0,
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                systemOverlayStyle: Platform.isIOS
                    ? Theme.of(context).brightness == Brightness.dark
                        ? SystemUiOverlayStyle.light
                        : SystemUiOverlayStyle.dark
                    : SystemUiOverlayStyle(
                        statusBarColor: Colors.transparent,
                        statusBarIconBrightness:
                            Theme.of(context).brightness == Brightness.dark
                                ? Brightness.light
                                : Brightness.dark,
                        systemNavigationBarColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        systemNavigationBarIconBrightness:
                            Theme.of(context).brightness == Brightness.dark
                                ? Brightness.light
                                : Brightness.dark),
                title: Text(
                  "Ajouter",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                      onPressed: () async {
                        navMainAuthKey.currentState!.pop();
                      },
                      icon: Icon(Icons.clear,
                          color: Theme.of(context).iconTheme.color))
                ],
              ),
            )),
            preferredSize: Size(MediaQuery.of(context).size.width, 60),
          ),
          body: Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: ListView(
              controller: _mainScrollController,
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text(
                    "Jeux suivis",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                followGames(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text(
                    "Jeux à découvrir",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                loadingDiscover
                    ? discoverGames()
                    : Container(
                        height: 200,
                        alignment: Alignment.center,
                        child: SizedBox(
                          height: 30.0,
                          width: 30.0,
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                            strokeWidth: 1.5,
                          ),
                        ),
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget followGames() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 45.0),
      child: Container(
        height: 170,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.centerLeft,
        child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            itemCount: gamesList.length,
            itemBuilder: (BuildContext context, int index) {
              Game game = gamesList[index];
              return _itemGameFollow(game, index);
            }),
      ),
    );
  }

  Widget discoverGames() {
    return Column(
      children: [
        GridView.builder(
            shrinkWrap: true,
            padding:
                const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.6,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6),
            itemCount: gamesDiscover.length,
            itemBuilder: (_, index) {
              Game game = gamesDiscover[index];
              return _itemGameDiscover(game, index);
            }),
        Stack(
          children: [
            Container(
                height: MediaQuery.of(context).size.height / 14,
                child: stopReached
                    ? Center(
                        child: Text(
                          "C'est tout pour le moment",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      )
                    : isLoadingMoreData
                        ? Center(
                            child: SizedBox(
                              height: 30.0,
                              width: 30.0,
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                                strokeWidth: 1.5,
                              ),
                            ),
                          )
                        : SizedBox()),
          ],
        )
      ],
    );
  }

  Widget _itemGameFollow(Game game, int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: InkWell(
        onTap: () =>
            alertUnfollowGame(game, context, ref, gamesList, stopReached),
        child: Container(
          width: 110,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary
                        ])),
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.5)
                        ])),
              ),
              Center(
                child: Icon(
                  Icons.videogame_asset,
                  size: 35,
                  color: Colors.white,
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                    padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                    child: Text(
                      game.name,
                      style: textStyleCustomBold(Colors.white, 14),
                      textAlign: TextAlign.end,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemGameDiscover(Game game, int index) {
    return InkWell(
      onTap: () => alertFollowGame(game, context, ref),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary
                    ])),
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.5)
                    ])),
          ),
          Center(
            child: Icon(
              Icons.videogame_asset,
              size: 35,
              color: Colors.white,
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
                padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                child: Text(
                  game.name,
                  style: textStyleCustomBold(Colors.white, 14),
                  textAlign: TextAlign.end,
                )),
          ),
        ],
      ),
    );
  }
}
