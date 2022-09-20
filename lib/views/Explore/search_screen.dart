import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:algolia/algolia.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gemu/components/snack_bar_custom.dart';
import 'package:gemu/constants/constants.dart';
import 'package:gemu/helpers/helpers.dart';
import 'package:gemu/models/user.dart';
import 'package:gemu/providers/Explore/search_provider.dart';
import 'package:gemu/providers/Keyboard/keyboard_visible_provider.dart';
import 'package:gemu/services/algolia_service.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/models/hashtag.dart';

//TODO
//calmer le listener de recherche pcq ça pompe sur Algolia niveau requests
//logique appels firebase => dans DatabaseService

class SearchScreen extends ConsumerStatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  late ScrollController _scrollController;

  bool _loadedRecentSearch = false;
  List listRecentSearches = [];

  late TabController _tabController;
  List<String> listFilters = ["Tout", "Utilisateurs", "Jeux", "Hashtags"];

  bool _searching = false;
  String currentSearch = "";
  Algolia algolia = AlgoliaService.algolia;
  List<AlgoliaObjectSnapshot> _all = [];
  List<AlgoliaObjectSnapshot> _users = [];
  List<AlgoliaObjectSnapshot> _games = [];
  List<AlgoliaObjectSnapshot> _hashtags = [];

  void _scrollListener() {
    if (_scrollController.offset != 0.0 && _searchFocusNode.hasFocus) {
      setState(() {
        _searchFocusNode.unfocus();
      });
    }
  }

  void _searchListener() {
    if (_searchController.text.isNotEmpty &&
        currentSearch != _searchController.text) {
      currentSearch = _searchController.text;
      _searchAll();
    }
  }

  Future<void> getRecentSearches() async {
    List recentSearches = [];

    try {
      QuerySnapshot<Map<String, dynamic>> dataSearches = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(me!.uid)
          .collection('recentSearches')
          .orderBy('dateSearch', descending: true)
          .get();

      for (var item in dataSearches.docs) {
        if (item.data()["type"] == "user") {
          DocumentSnapshot<Map<String, dynamic>> dataUser =
              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(item.data()["id"])
                  .get();
          UserModel user = UserModel(
              ref: item.reference,
              documentId: item.id,
              uid: item.data()['id'],
              username: dataUser.data()!['username'],
              email: dataUser.data()!['email'],
              imageUrl: dataUser.data()!['imageUrl'],
              privacy: dataUser.data()!['privacy'],
              dateBirthday: dataUser.data()!["dateBirthday"],
              country: dataUser.data()!["country"],
              verifiedAccount: dataUser.data()!["verified_account"],
              type: item.data()["type"] ?? "user");
          recentSearches.add(user);
        } else if (item.data()["type"] == "game") {
          DocumentSnapshot<Map<String, dynamic>> dataGame =
              await FirebaseFirestore.instance
                  .collection("games")
                  .doc("verified")
                  .collection("games_verified")
                  .doc(item.data()["id"])
                  .get();
          Game game = Game(
              snapshot: item,
              reference: item.reference,
              documentId: item.id,
              name: dataGame.data()!['name'],
              imageUrl: dataGame.data()!['imageUrl'],
              categories: dataGame.data()!['categories'],
              type: item.data()["type"] ?? "game");
          recentSearches.add(game);
        } else {
          DocumentSnapshot<Map<String, dynamic>> dataHashtag =
              await FirebaseFirestore.instance
                  .collection("hashtags")
                  .doc(item.data()["id"])
                  .get();
          Hashtag hashtag = Hashtag(
              snapshot: item,
              reference: item.reference,
              documentId: item.id,
              name: dataHashtag.data()!['name'],
              postsCount: dataHashtag.data()!['postsCount'],
              type: item.data()["type"] ?? "hashtag");
          recentSearches.add(hashtag);
        }
      }

      ref
          .read(recentSearchesNotifierProvider.notifier)
          .initRecentSearches(recentSearches);
      ref
          .read(loadedRecentSearchesNotifierProvider.notifier)
          .recentSearchesLoaded();
    } catch (e) {
      print(e);
      messageUser(context, "Oups, un problème est survenu");
    }
  }

  _searchAll() async {
    if (mounted) {
      setState(() {
        _searching = true;
      });
    }

    AlgoliaQuery queryUsers = algolia.instance.index('users');
    queryUsers = queryUsers.query(_searchController.text);
    _users = (await queryUsers.getObjects()).hits;

    AlgoliaQuery queryGames = algolia.instance.index('games');
    queryGames = queryGames.query(_searchController.text);
    _games = (await queryGames.getObjects()).hits;

    AlgoliaQuery queryHashtags = algolia.instance.index('hashtags');
    queryHashtags = queryHashtags.query(_searchController.text);
    _hashtags = (await queryHashtags.getObjects()).hits;

    _all = [..._users, ..._games, ..._hashtags];

    if (mounted) {
      setState(() {
        _searching = false;
      });
    }
  }

  addInRecentSearches(AlgoliaObjectSnapshot recentSearch) async {
    try {
      int dateSearch = DateTime.now().millisecondsSinceEpoch.toInt();

      if (recentSearch.data["type"] == "user" &&
          !listRecentSearches.any((element) =>
              element.documentId == recentSearch.data["objectID"])) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(me!.uid)
            .collection('recentSearches')
            .doc(recentSearch.data["objectID"])
            .set({
          'id': recentSearch.data["objectID"],
          'type': recentSearch.data["type"],
          'dateSearch': dateSearch,
        });
        ref
            .read(recentSearchesNotifierProvider.notifier)
            .addRecentSearches(recentSearch);
      } else if (recentSearch.data["type"] == "game" &&
          !listRecentSearches.any((element) =>
              element.documentId == recentSearch.data["objectID"])) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(me!.uid)
            .collection('recentSearches')
            .doc(recentSearch.data["objectID"])
            .set({
          'id': recentSearch.data["objectID"],
          'type': recentSearch.data["type"],
          'dateSearch': dateSearch
        });
        ref
            .read(recentSearchesNotifierProvider.notifier)
            .addRecentSearches(recentSearch);
      } else if (recentSearch.data["type"] == "hashtag" &&
          !listRecentSearches.any((element) =>
              element.documentId == recentSearch.data["objectID"])) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(me!.uid)
            .collection('recentSearches')
            .doc(recentSearch.data["objectID"])
            .set({
          'id': recentSearch.data["objectID"],
          'type': recentSearch.data["type"],
          'dateSearch': dateSearch
        });
        ref
            .read(recentSearchesNotifierProvider.notifier)
            .addRecentSearches(recentSearch);
      }
    } catch (e) {
      print(e);
      messageUser(context, "Oups, un problème est survenu");
    }
  }

  deleteInRecentSearches(var recentSearch) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(me!.uid)
          .collection('recentSearches')
          .doc(recentSearch.documentId)
          .delete();

      ref
          .read(recentSearchesNotifierProvider.notifier)
          .deleteRecentSearches(recentSearch);
    } catch (e) {
      print(e);
      messageUser(context, "Oups, un problème est survenu");
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (!ref.read(loadedRecentSearchesNotifierProvider)) {
      getRecentSearches();
    }

    _tabController = TabController(length: 4, vsync: this);

    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _searchController.addListener(_searchListener);

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final newValue = bottomInset > 0.0;
    if (newValue != ref.read(keyboardVisibilityNotifierProvider)) {
      ref
          .read(keyboardVisibilityNotifierProvider.notifier)
          .updateVisibilityKeyboard(newValue);
    }
    super.didChangeMetrics();
  }

  @override
  void deactivate() {
    _scrollController.removeListener(_scrollListener);
    _searchController.removeListener(_searchListener);
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _searchFocusNode.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _loadedRecentSearch = ref.watch(loadedRecentSearchesNotifierProvider);
    listRecentSearches = ref.watch(recentSearchesNotifierProvider);

    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: PreferredSize(
          child: ClipRRect(
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Theme.of(context).shadowColor.withOpacity(0.7),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Row(
                          children: [
                            Expanded(
                                child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Container(
                                height: 40.0,
                                alignment: Alignment.center,
                                child: TextField(
                                  controller: _searchController,
                                  autofocus: false,
                                  focusNode: _searchFocusNode,
                                  cursorColor:
                                      Theme.of(context).colorScheme.primary,
                                  textInputAction: TextInputAction.search,
                                  maxLines: 1,
                                  style: textStyleCustomRegular(
                                      _searchFocusNode.hasFocus
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Colors.grey,
                                      14),
                                  decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.only(
                                          top: 15.0, left: 15.0),
                                      filled: true,
                                      fillColor: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      hintText: 'Rechercher',
                                      hintStyle: textStyleCustomBold(
                                          _searchFocusNode.hasFocus
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Colors.grey,
                                          14),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      prefixIcon: Icon(
                                        Icons.search_sharp,
                                        size: 20,
                                      ),
                                      suffixIcon: _searchController
                                              .text.isNotEmpty
                                          ? IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  _searchController.clear();
                                                });
                                              },
                                              icon: Icon(
                                                Icons.clear,
                                                size: 20,
                                                color: _searchFocusNode.hasFocus
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                    : Colors.grey,
                                              ))
                                          : const SizedBox()),
                                  onTap: () {
                                    setState(() {
                                      FocusScope.of(context)
                                          .requestFocus(_searchFocusNode);
                                    });
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      value = _searchController.text;
                                    });
                                  },
                                ),
                              ),
                            )),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: TextButton(
                                onPressed: () =>
                                    navExploreAuthKey!.currentState!.pop(),
                                child: Text(
                                  "Annuler",
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      _searchController.text.isEmpty
                          ? const SizedBox()
                          : Container(
                              height: 50,
                              alignment: Alignment.center,
                              child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                physics: const AlwaysScrollableScrollPhysics(
                                    parent: BouncingScrollPhysics()),
                                itemCount: listFilters.length,
                                itemBuilder: (_, index) {
                                  String nameFilter = listFilters[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 5.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _tabController.index = index;
                                        });
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: _tabController.index == index
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Colors.transparent,
                                            border: Border.all(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary),
                                            borderRadius:
                                                BorderRadius.circular(10.0)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Text(nameFilter,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ],
                  ),
                )),
          ),
          preferredSize: Size(MediaQuery.of(context).size.width,
              _searchController.text.isNotEmpty ? 110 : 60),
        ),
        body: GestureDetector(
          onTap: () => Helpers.hideKeyboard(context),
          child: body(),
        ));
  }

  Widget body() {
    return _searchController.text.isEmpty ? recentSearches() : searches();
  }

  Widget recentSearches() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            controller: _scrollController,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Container(
                  height: 30.0,
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      "Recherches récentes",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ),
              ),
              _loadedRecentSearch
                  ? listRecentSearches.length == 0
                      ? Container(
                          height: 150,
                          alignment: Alignment.center,
                          child: Text(
                            'Pas de recherches récentes actuellement',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: listRecentSearches.length,
                          itemBuilder: (_, index) {
                            var recentSearch = listRecentSearches[index];

                            switch (recentSearch.type) {
                              case "user":
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: ListTile(
                                    onTap: () {
                                      navExploreAuthKey!.currentState!
                                          .pushNamed(UserProfile,
                                              arguments: [recentSearch.uid]);
                                    },
                                    leading: recentSearch.imageUrl == null
                                        ? Container(
                                            height: 65,
                                            width: 65,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black),
                                                shape: BoxShape.circle,
                                                color: Theme.of(context)
                                                    .shadowColor),
                                            child: Icon(
                                              Icons.person,
                                              color: Colors.black,
                                              size: 33,
                                            ),
                                          )
                                        : Container(
                                            height: 65,
                                            width: 65,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black),
                                                shape: BoxShape.circle,
                                                color: Theme.of(context)
                                                    .shadowColor,
                                                image: DecorationImage(
                                                    image:
                                                        CachedNetworkImageProvider(
                                                            recentSearch
                                                                .imageUrl),
                                                    fit: BoxFit.cover)),
                                          ),
                                    title: Text(
                                      recentSearch.username,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    trailing: IconButton(
                                        onPressed: () => deleteInRecentSearches(
                                            recentSearch),
                                        icon: Icon(Icons.clear)),
                                  ),
                                );
                              case "game":
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: ListTile(
                                    onTap: () {
                                      navExploreAuthKey!.currentState!
                                          .pushNamed(GameProfile, arguments: [
                                        recentSearch,
                                        navExploreAuthKey
                                      ]);
                                    },
                                    leading: recentSearch.imageUrl == null
                                        ? Container(
                                            height: 65,
                                            width: 65,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black),
                                                shape: BoxShape.circle,
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
                                                    ])),
                                            child: Icon(
                                              Icons.videogame_asset,
                                              size: 33,
                                            ),
                                          )
                                        : Container(
                                            height: 65,
                                            width: 65,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black),
                                                shape: BoxShape.circle,
                                                color: Theme.of(context)
                                                    .shadowColor,
                                                image: DecorationImage(
                                                    image:
                                                        CachedNetworkImageProvider(
                                                            recentSearch
                                                                .imageUrl),
                                                    fit: BoxFit.cover)),
                                          ),
                                    title: Text(
                                      recentSearch.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    trailing: IconButton(
                                        onPressed: () => deleteInRecentSearches(
                                            recentSearch),
                                        icon: Icon(Icons.clear)),
                                  ),
                                );
                              case "hashtag":
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: ListTile(
                                    onTap: () {
                                      navExploreAuthKey!.currentState!
                                          .pushNamed(HashtagProfile,
                                              arguments: [
                                            recentSearch,
                                            navExploreAuthKey
                                          ]);
                                    },
                                    leading: Container(
                                      height: 65,
                                      width: 65,
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black),
                                          shape: BoxShape.circle,
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
                                              ])),
                                      child: Icon(Icons.tag, size: 33),
                                    ),
                                    title: Text(
                                      recentSearch.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    trailing: IconButton(
                                        onPressed: () => deleteInRecentSearches(
                                            recentSearch),
                                        icon: Icon(
                                          Icons.clear,
                                        )),
                                  ),
                                );
                              default:
                                return const SizedBox();
                            }
                          })
                  : Container(
                      height: 150,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                        strokeWidth: 1.0,
                      ))
            ],
          ),
        ),
      ],
    );
  }

  Widget searches() {
    return _searching
        ? Column(
            children: [
              Expanded(
                child: Container(
                  height: 150,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 15.0,
                        width: 15.0,
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      SizedBox(
                        width: 5.0,
                      ),
                      Text(
                        _searchController.text.length < 10
                            ? 'Recherche de "${_searchController.text}.."'
                            : 'Recherche de "${_searchController.text.substring(0, 10)}.."',
                        style: Theme.of(context).textTheme.titleSmall,
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ),
            ],
          )
        : Column(
            children: [
              Expanded(
                child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _allResultsSearch(),
                      _usersResultsSearch(),
                      _gamesResultsSearch(),
                      _hashtagsResultsSearch()
                    ]),
              ),
            ],
          );
  }

  Widget _allResultsSearch() {
    return _all.length == 0
        ? Container(
            height: 150,
            alignment: Alignment.center,
            child: Text(
              "Pas de résultats trouvés",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          )
        : ListView.builder(
            controller: _scrollController,
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            itemCount: _all.length,
            itemBuilder: (_, index) {
              AlgoliaObjectSnapshot recentSearch = _all[index];

              switch (recentSearch.data["type"]) {
                case "user":
                  return Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: ListTile(
                        onTap: () {
                          addInRecentSearches(recentSearch);
                          navExploreAuthKey!.currentState!.pushNamed(
                              UserProfile,
                              arguments: [recentSearch.data["objectID"]]);
                        },
                        leading: recentSearch.data["imageUrl"] == null
                            ? Container(
                                height: 65,
                                width: 65,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).shadowColor),
                                child: Icon(Icons.person,
                                    size: 33, color: Colors.black),
                              )
                            : Container(
                                height: 65,
                                width: 65,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).shadowColor,
                                    image: DecorationImage(
                                        image: CachedNetworkImageProvider(
                                            recentSearch.data["imageUrl"]),
                                        fit: BoxFit.cover)),
                              ),
                        title: Text(
                          recentSearch.data["username"],
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ));
                case "game":
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: ListTile(
                      onTap: () {
                        addInRecentSearches(recentSearch);
                        navExploreAuthKey!.currentState!
                            .pushNamed(GameProfile, arguments: [
                          Game.fromMapAlgolia(recentSearch, recentSearch.data),
                          navExploreAuthKey
                        ]);
                      },
                      leading: recentSearch.data["imageUrl"] == null
                          ? Container(
                              height: 65,
                              width: 65,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Theme.of(context).colorScheme.primary,
                                        Theme.of(context).colorScheme.secondary
                                      ])),
                              child: Icon(
                                Icons.videogame_asset,
                                size: 33,
                              ),
                            )
                          : Container(
                              height: 65,
                              width: 65,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).shadowColor,
                                  image: DecorationImage(
                                      image: CachedNetworkImageProvider(
                                          recentSearch.data["imageUrl"]),
                                      fit: BoxFit.cover)),
                            ),
                      title: Text(
                        recentSearch.data["name"],
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  );
                case "hashtag":
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: ListTile(
                      onTap: () {
                        addInRecentSearches(recentSearch);
                        navExploreAuthKey!.currentState!
                            .pushNamed(HashtagProfile, arguments: [
                          Hashtag.fromMapAlgolia(
                              recentSearch, recentSearch.data),
                          navExploreAuthKey
                        ]);
                      },
                      leading: Container(
                        height: 65,
                        width: 65,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.secondary
                                ])),
                        child: Icon(
                          Icons.tag_sharp,
                          size: 33,
                        ),
                      ),
                      title: Text(
                        recentSearch.data["name"],
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  );
                default:
                  return const SizedBox();
              }
            });
  }

  Widget _usersResultsSearch() {
    return _users.length == 0
        ? Container(
            height: 150,
            alignment: Alignment.center,
            child: Text(
              "Pas d'utilisateurs trouvés",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            controller: _scrollController,
            itemCount: _users.length,
            itemBuilder: (_, index) {
              AlgoliaObjectSnapshot recentSearch = _users[index];

              return Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: ListTile(
                    onTap: () {
                      addInRecentSearches(recentSearch);
                      navExploreAuthKey!.currentState!.pushNamed(UserProfile,
                          arguments: [recentSearch.data["objectID"]]);
                    },
                    leading: recentSearch.data["imageUrl"] == null
                        ? Container(
                            height: 65,
                            width: 65,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                shape: BoxShape.circle,
                                color: Theme.of(context).shadowColor),
                            child: Icon(Icons.person,
                                size: 33, color: Colors.black),
                          )
                        : Container(
                            height: 65,
                            width: 65,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                shape: BoxShape.circle,
                                color: Theme.of(context).shadowColor,
                                image: DecorationImage(
                                    image: CachedNetworkImageProvider(
                                        recentSearch.data["imageUrl"]),
                                    fit: BoxFit.cover)),
                          ),
                    title: Text(
                      recentSearch.data["username"],
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ));
            });
  }

  Widget _gamesResultsSearch() {
    return _games.length == 0
        ? Container(
            height: 150,
            alignment: Alignment.center,
            child: Text(
              "Pas de de jeux trouvés",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            controller: _scrollController,
            itemCount: _games.length,
            itemBuilder: (_, index) {
              AlgoliaObjectSnapshot recentSearch = _games[index];

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: ListTile(
                  onTap: () {
                    addInRecentSearches(recentSearch);
                    navExploreAuthKey!.currentState!.pushNamed(GameProfile,
                        arguments: [
                          Game.fromMapAlgolia(recentSearch, recentSearch.data),
                          navExploreAuthKey
                        ]);
                  },
                  leading: recentSearch.data["imageUrl"] == null
                      ? Container(
                          height: 65,
                          width: 65,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.secondary
                                  ])),
                          child: Icon(
                            Icons.videogame_asset,
                            size: 33,
                          ),
                        )
                      : Container(
                          height: 65,
                          width: 65,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              shape: BoxShape.circle,
                              color: Theme.of(context).shadowColor,
                              image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                      recentSearch.data["imageUrl"]),
                                  fit: BoxFit.cover)),
                        ),
                  title: Text(
                    recentSearch.data["name"],
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              );
            });
  }

  Widget _hashtagsResultsSearch() {
    return _hashtags.length == 0
        ? Container(
            height: 150,
            alignment: Alignment.center,
            child: Text(
              "Pas d'hashtags trouvés",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            controller: _scrollController,
            itemCount: _hashtags.length,
            itemBuilder: (_, index) {
              AlgoliaObjectSnapshot recentSearch = _hashtags[index];

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: ListTile(
                  onTap: () {
                    addInRecentSearches(recentSearch);
                    navExploreAuthKey!.currentState!
                        .pushNamed(HashtagProfile, arguments: [
                      Hashtag.fromMapAlgolia(recentSearch, recentSearch.data),
                      navExploreAuthKey
                    ]);
                  },
                  leading: Container(
                    height: 65,
                    width: 65,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary
                            ])),
                    child: Icon(
                      Icons.tag_sharp,
                      size: 33,
                    ),
                  ),
                  title: Text(
                    recentSearch.data["name"],
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              );
            });
  }
}
