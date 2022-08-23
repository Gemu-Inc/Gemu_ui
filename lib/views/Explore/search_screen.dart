import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:algolia/algolia.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/services/algolia_service.dart';
import 'package:gemu/views/Profile/profile_user_screen.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/models/hashtag.dart';
import 'package:gemu/views/Games/profile_game_screen.dart';
import 'package:gemu/views/Hashtags/hashtags_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  Searchviewstate createState() => Searchviewstate();
}

class Searchviewstate extends State<SearchScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TextEditingController _searchController = TextEditingController(text: "");
  String value = "";
  bool _searching = false;

  Algolia algolia = AlgoliaService.algolia;
  List<AlgoliaObjectSnapshot> _all = [];
  List<AlgoliaObjectSnapshot> _users = [];
  List<AlgoliaObjectSnapshot> _games = [];
  List<AlgoliaObjectSnapshot> _hashtags = [];

  late TabController _tabController;
  int currentTabIndex = 0;

  late FocusNode _keyboardFocusNode;
  late ScrollController _scrollController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);

    _searchController.addListener(_searchListener);

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    _keyboardFocusNode = FocusNode();
  }

  @override
  void deactivate() {
    _scrollController.removeListener(_scrollListener);
    _searchController.removeListener(_searchListener);
    _tabController.removeListener(_onTabChanged);
    super.deactivate();
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        print('Changing to Tab: ${_tabController.index}');
        currentTabIndex = _tabController.index;
      });
      if (_searchController.text.isNotEmpty) {
        if (_tabController.index == 0) {
          print('search 0');
          searchAll();
        }
        if (_tabController.index == 1) {
          print('search 1');
          searchUser();
        }
        if (_tabController.index == 2) {
          print('search 2');
          searchGame();
        }
        if (_tabController.index == 3) {
          print('search 3');
          searchHashtag();
        }
      }
    }
  }

  void _scrollListener() {
    if (_scrollController.offset != 0.0 && _keyboardFocusNode.hasFocus) {
      setState(() {
        _keyboardFocusNode.unfocus();
      });
    }
  }

  void _searchListener() {
    if (value != _searchController.text) {
      value = _searchController.text;
      _onSearchChanged();
    }
  }

  _onSearchChanged() {
    if (_tabController.index == 0) {
      print('search 0');
      searchAll();
    }
    if (_tabController.index == 1) {
      print('search 1');
      searchUser();
    }
    if (_tabController.index == 2) {
      print('search 2');
      searchGame();
    }
    if (_tabController.index == 3) {
      print('search 3');
      searchHashtag();
    }
  }

  searchAll() async {
    if (_keyboardFocusNode.hasPrimaryFocus) {
      if (_all.length != 0) {
        _all.clear();
      }

      if (_searchController.text.isNotEmpty) {
        setState(() {
          _searching = true;
        });

        List<AlgoliaObjectSnapshot> _users = [];
        List<AlgoliaObjectSnapshot> _games = [];
        List<AlgoliaObjectSnapshot> _hashtags = [];

        AlgoliaQuery queryUsers = algolia.instance.index('users');
        queryUsers = queryUsers.query(_searchController.text);

        _users = (await queryUsers.getObjects()).hits;
        print('${_users.length}');

        AlgoliaQuery queryGames = algolia.instance.index('games');
        queryGames = queryGames.query(_searchController.text);

        _games = (await queryGames.getObjects()).hits;
        print('${_games.length}');

        AlgoliaQuery queryHashtags = algolia.instance.index('hashtags');
        queryHashtags = queryHashtags.query(_searchController.text);

        _hashtags = (await queryHashtags.getObjects()).hits;
        print('${_hashtags.length}');

        _all = _users + _games + _hashtags;
        print('${_all.length}');

        _users.clear();
        _games.clear();
        _hashtags.clear();

        setState(() {
          _searching = false;
        });
      }
    }
  }

  searchUser() async {
    if (_users.length != 0) {
      _users.clear();
    }

    if (_searchController.text.isNotEmpty) {
      setState(() {
        _searching = true;
      });

      AlgoliaQuery query = algolia.instance.index('users');
      query = query.query(_searchController.text);

      _users = (await query.getObjects()).hits;

      print('${_users.length}');

      setState(() {
        _searching = false;
      });
    }
  }

  searchGame() async {
    if (_games.length != 0) {
      _games.clear();
    }

    if (_searchController.text.isNotEmpty) {
      setState(() {
        _searching = true;
      });

      AlgoliaQuery query = algolia.instance.index('games');
      query = query.query(_searchController.text);

      _games = (await query.getObjects()).hits;

      print('${_games.length}');

      setState(() {
        _searching = false;
      });
    }
  }

  searchHashtag() async {
    if (_hashtags.length != 0) {
      _hashtags.clear();
    }

    if (_searchController.text.isNotEmpty) {
      setState(() {
        _searching = true;
      });

      AlgoliaQuery query = algolia.instance.index('hashtags');
      query = query.query(_searchController.text);

      _hashtags = (await query.getObjects()).hits;

      print('${_hashtags.length}');

      setState(() {
        _searching = false;
      });
    }
  }

  addInRecentSearch(AlgoliaObjectSnapshot snapshot) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(me!.uid)
        .collection('recentSearch')
        .doc(snapshot.data["objectID"])
        .set({
      'username': snapshot.data["username"],
      'name': snapshot.data["name"],
      'imageUrl': snapshot.data["imageUrl"],
      'categories': snapshot.data["categories"],
      'postsCount': snapshot.data["postsCount"],
      'type': snapshot.data["type"],
      'date': DateTime.now().millisecondsSinceEpoch.toInt()
    });
  }

  deleteFromRecentSearch(DocumentSnapshot snapshot) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(me!.uid)
        .collection('recentSearch')
        .doc(snapshot.id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
          elevation: 6,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () => Navigator.pop(context)),
          title: TextFormField(
            controller: _searchController,
            autofocus: false,
            focusNode: _keyboardFocusNode,
            cursorColor: Theme.of(context).colorScheme.primary,
            textInputAction: TextInputAction.search,
            maxLines: 1,
            decoration: InputDecoration(
                labelText: 'Search',
                labelStyle: TextStyle(
                    color: _keyboardFocusNode.hasFocus
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey),
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none),
            onTap: () {
              setState(() {
                FocusScope.of(context).requestFocus(_keyboardFocusNode);
              });
            },
          ),
          actions: [
            _searchController.text.isEmpty
                ? SizedBox()
                : IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                      });
                    }),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              child: Container(
                height: 40,
                child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.transparent,
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    isScrollable: true,
                    tabs: [
                      tabSearch('All', 0),
                      tabSearch('Users', 1),
                      tabSearch('Games', 2),
                      tabSearch('Hashtags', 3),
                    ]),
              ),
            ),
            Expanded(
                child: TabBarView(
                    physics: AlwaysScrollableScrollPhysics(),
                    controller: _tabController,
                    children: [
                  all(),
                  users(),
                  games(),
                  hastags(),
                ])),
          ],
        ));
  }

  Widget tabSearch(String title, int index) {
    return currentTabIndex == index
        ? Container(
            height: 27.5,
            width: 75,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(15.0),
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.7)
                    ])),
            child: Text(title),
          )
        : Container(
            height: 27.5,
            width: 75,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(15.0),
                color: Colors.transparent),
            child: Text(title),
          );
  }

  Widget recentSearchAll() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 5.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              'Recherches récentes',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Expanded(
              child: FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(me!.uid)
                      .collection('recentSearch')
                      .orderBy('date', descending: true)
                      .get(),
                  builder: (_, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    }
                    if (snapshot.data.docs.length == 0) {
                      return Center(
                        child: Text(
                          'Pas encore de recherches récentes',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    }
                    return ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (_, index) {
                          DocumentSnapshot<Map<String, dynamic>> recentSearch =
                              snapshot.data.docs[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.0),
                            child: recentSearch.data()!['type'] == 'hashtag'
                                ? ListTile(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => HashtagsScreen(
                                                  hashtag: Hashtag.fromMap(
                                                      recentSearch,
                                                      recentSearch.data()!))));
                                    },
                                    leading: Container(
                                      height: 45,
                                      width: 45,
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
                                      child: Icon(
                                        Icons.tag,
                                        color: Colors.black,
                                      ),
                                    ),
                                    title: Text(
                                      recentSearch.data()!['name'],
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    subtitle: Text(
                                      '${recentSearch.data()!['postsCount'].toString()} publications',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    trailing: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            deleteFromRecentSearch(
                                                recentSearch);
                                          });
                                        },
                                        icon: Icon(Icons.clear)),
                                  )
                                : recentSearch.data()!['type'] == 'user'
                                    ? ListTile(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) => ProfilUser(
                                                      userPostID:
                                                          recentSearch.id)));
                                        },
                                        leading: recentSearch
                                                    .data()!['imageUrl'] ==
                                                null
                                            ? Container(
                                                height: 45,
                                                width: 45,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black),
                                                    shape: BoxShape.circle,
                                                    color: Theme.of(context)
                                                        .canvasColor),
                                                child: Icon(
                                                  Icons.person,
                                                  color: Colors.black,
                                                ),
                                              )
                                            : Container(
                                                height: 45,
                                                width: 45,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black),
                                                    shape: BoxShape.circle,
                                                    color: Theme.of(context)
                                                        .canvasColor,
                                                    image: DecorationImage(
                                                        image:
                                                            CachedNetworkImageProvider(
                                                                recentSearch
                                                                        .data()![
                                                                    'imageUrl']),
                                                        fit: BoxFit.cover)),
                                              ),
                                        title: Text(
                                          recentSearch.data()!['username'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                        trailing: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                deleteFromRecentSearch(
                                                    recentSearch);
                                              });
                                            },
                                            icon: Icon(Icons.clear)),
                                      )
                                    : ListTile(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      ProfileGameScreen(
                                                        game: Game.fromMap(
                                                            recentSearch,
                                                            recentSearch
                                                                .data()!),
                                                        navKey:
                                                            navExploreAuthKey!,
                                                      )));
                                        },
                                        leading: Container(
                                          height: 45,
                                          width: 45,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black),
                                              shape: BoxShape.circle,
                                              color:
                                                  Theme.of(context).canvasColor,
                                              image: DecorationImage(
                                                  image:
                                                      CachedNetworkImageProvider(
                                                          recentSearch.data()![
                                                              'imageUrl']),
                                                  fit: BoxFit.cover)),
                                        ),
                                        title: Text(
                                          recentSearch.data()!['name'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                        trailing: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                deleteFromRecentSearch(
                                                    recentSearch);
                                              });
                                            },
                                            icon: Icon(Icons.clear)),
                                      ),
                          );
                        });
                  }))
        ],
      ),
    );
  }

  Widget recentSearchUsers() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 5.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              'Recherches récentes',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Expanded(
              child: FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(me!.uid)
                      .collection('recentSearch')
                      .where('type', isEqualTo: 'user')
                      .orderBy('date', descending: true)
                      .get(),
                  builder: (_, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    }
                    if (snapshot.data.docs.length == 0) {
                      return Center(
                        child: Text(
                          'Pas encore de recherches récentes',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    }
                    return ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (_, index) {
                          DocumentSnapshot<Map<String, dynamic>> recentSearch =
                              snapshot.data.docs[index];
                          return Padding(
                              padding: EdgeInsets.symmetric(vertical: 5.0),
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => ProfilUser(
                                              userPostID: recentSearch.id)));
                                },
                                leading: recentSearch.data()!['imageUrl'] ==
                                        null
                                    ? Container(
                                        height: 45,
                                        width: 45,
                                        decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.black),
                                            shape: BoxShape.circle,
                                            color:
                                                Theme.of(context).canvasColor),
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.black,
                                        ),
                                      )
                                    : Container(
                                        height: 45,
                                        width: 45,
                                        decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.black),
                                            shape: BoxShape.circle,
                                            color:
                                                Theme.of(context).canvasColor,
                                            image: DecorationImage(
                                                image:
                                                    CachedNetworkImageProvider(
                                                        recentSearch.data()![
                                                            'imageUrl']),
                                                fit: BoxFit.cover)),
                                      ),
                                title: Text(
                                  recentSearch.data()!['username'],
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                trailing: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        deleteFromRecentSearch(recentSearch);
                                      });
                                    },
                                    icon: Icon(Icons.clear)),
                              ));
                        });
                  }))
        ],
      ),
    );
  }

  Widget recentSearchGames() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 5.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              'Recherches récentes',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Expanded(
              child: FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(me!.uid)
                      .collection('recentSearch')
                      .where('type', isEqualTo: 'game')
                      .orderBy('date', descending: true)
                      .get(),
                  builder: (_, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    }
                    if (snapshot.data.docs.length == 0) {
                      return Center(
                        child: Text(
                          'Pas encore de recherches récentes',
                        ),
                      );
                    }
                    return ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (_, index) {
                          DocumentSnapshot<Map<String, dynamic>> recentSearch =
                              snapshot.data.docs[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.0),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => ProfileGameScreen(
                                            game: Game.fromMap(recentSearch,
                                                recentSearch.data()!),
                                            navKey: navExploreAuthKey!)));
                              },
                              leading: Container(
                                height: 45,
                                width: 45,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).canvasColor,
                                    image: DecorationImage(
                                        image: CachedNetworkImageProvider(
                                            recentSearch.data()!['imageUrl']),
                                        fit: BoxFit.cover)),
                              ),
                              title: Text(
                                recentSearch.data()!['name'],
                              ),
                              trailing: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      deleteFromRecentSearch(recentSearch);
                                    });
                                  },
                                  icon: Icon(Icons.clear)),
                            ),
                          );
                        });
                  }))
        ],
      ),
    );
  }

  Widget recentSearchHashtags() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 5.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              'Recherches récentes',
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Expanded(
              child: FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(me!.uid)
                      .collection('recentSearch')
                      .where('type', isEqualTo: 'hashtag')
                      .orderBy('date', descending: true)
                      .get(),
                  builder: (_, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    }
                    if (snapshot.data.docs.length == 0) {
                      return Center(
                        child: Text(
                          'Pas encore de recherches récentes',
                        ),
                      );
                    }
                    return ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (_, index) {
                          DocumentSnapshot<Map<String, dynamic>> recentSearch =
                              snapshot.data.docs[index];
                          return Padding(
                              padding: EdgeInsets.symmetric(vertical: 5.0),
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => HashtagsScreen(
                                              hashtag: Hashtag.fromMap(
                                                  recentSearch,
                                                  recentSearch.data()!))));
                                },
                                leading: Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
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
                                    Icons.tag,
                                    color: Colors.black,
                                  ),
                                ),
                                title: Text(
                                  recentSearch.data()!['name'],
                                ),
                                subtitle: Text(
                                  '${recentSearch.data()!['postsCount'].toString()} publications',
                                ),
                                trailing: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        deleteFromRecentSearch(recentSearch);
                                      });
                                    },
                                    icon: Icon(Icons.clear)),
                              ));
                        });
                  }))
        ],
      ),
    );
  }

  Widget all() {
    return _searching
        ? Center(
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
                )
              ],
            ),
          )
        : _searchController.text.isEmpty
            ? recentSearchAll()
            : _all.length == 0
                ? Center(
                    child: Text(
                      'No results found',
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: _all.length,
                    itemBuilder: (_, index) {
                      AlgoliaObjectSnapshot snap = _all[index];

                      return snap.data["type"] == "hashtag"
                          ? Padding(
                              padding: EdgeInsets.symmetric(vertical: 5.0),
                              child: ListTile(
                                onTap: () {
                                  addInRecentSearch(snap);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => HashtagsScreen(
                                              hashtag: Hashtag.fromMapAlgolia(
                                                  snap, snap.data))));
                                },
                                leading: Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
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
                                  child: Icon(Icons.tag_sharp),
                                ),
                                title: Text(
                                  snap.data["name"],
                                ),
                                subtitle: Text(
                                  '${snap.data["postsCount"]} publications',
                                ),
                              ),
                            )
                          : snap.data["type"] == "user"
                              ? Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5.0),
                                  child: ListTile(
                                    onTap: () {
                                      addInRecentSearch(snap);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => ProfilUser(
                                                  userPostID:
                                                      snap.data["objectID"])));
                                    },
                                    leading: snap.data["imageUrl"] == null
                                        ? Container(
                                            height: 45,
                                            width: 45,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black),
                                                shape: BoxShape.circle,
                                                color: Theme.of(context)
                                                    .canvasColor),
                                            child: Icon(Icons.person,
                                                size: 23, color: Colors.black),
                                          )
                                        : Container(
                                            height: 45,
                                            width: 45,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black),
                                                shape: BoxShape.circle,
                                                color: Theme.of(context)
                                                    .canvasColor,
                                                image: DecorationImage(
                                                    image:
                                                        CachedNetworkImageProvider(
                                                            snap.data[
                                                                "imageUrl"]),
                                                    fit: BoxFit.cover)),
                                          ),
                                    title: Text(
                                      snap.data["username"],
                                    ),
                                  ))
                              : Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5.0),
                                  child: ListTile(
                                    onTap: () {
                                      addInRecentSearch(snap);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => ProfileGameScreen(
                                                  game: Game.fromMapAlgolia(
                                                      snap, snap.data),
                                                  navKey: navExploreAuthKey!)));
                                    },
                                    leading: snap.data["imageUrl"] == null
                                        ? Container(
                                            height: 45,
                                            width: 45,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black),
                                                shape: BoxShape.circle,
                                                color: Theme.of(context)
                                                    .canvasColor),
                                            child: Icon(Icons.person,
                                                size: 23, color: Colors.black),
                                          )
                                        : Container(
                                            height: 45,
                                            width: 45,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black),
                                                shape: BoxShape.circle,
                                                color: Theme.of(context)
                                                    .canvasColor,
                                                image: DecorationImage(
                                                    image:
                                                        CachedNetworkImageProvider(
                                                            snap.data[
                                                                "imageUrl"]),
                                                    fit: BoxFit.cover)),
                                          ),
                                    title: Text(
                                      snap.data["name"],
                                    ),
                                  ),
                                );
                    });
  }

  Widget users() {
    return _searching
        ? Center(
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
                )
              ],
            ),
          )
        : _searchController.text.isEmpty
            ? recentSearchUsers()
            : _users.length == 0
                ? Center(
                    child: Text(
                      'No users found',
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: _users.length,
                    itemBuilder: (_, index) {
                      AlgoliaObjectSnapshot snap = _users[index];

                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.0),
                        child: ListTile(
                          onTap: () {
                            addInRecentSearch(snap);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => ProfilUser(
                                        userPostID: snap.data["objectID"])));
                          },
                          leading: snap.data["imageUrl"] == null
                              ? Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      shape: BoxShape.circle,
                                      color: Theme.of(context).canvasColor),
                                  child: Icon(Icons.person,
                                      size: 23, color: Colors.black),
                                )
                              : Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      shape: BoxShape.circle,
                                      color: Theme.of(context).canvasColor,
                                      image: DecorationImage(
                                          image: CachedNetworkImageProvider(
                                              snap.data["imageUrl"]),
                                          fit: BoxFit.cover)),
                                ),
                          title: Text(
                            snap.data["username"],
                          ),
                        ),
                      );
                    });
  }

  Widget games() {
    return _searching
        ? Center(
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
                )
              ],
            ),
          )
        : _searchController.text.isEmpty
            ? recentSearchGames()
            : _games.length == 0
                ? Center(
                    child: Text(
                      'No games found',
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: _games.length,
                    itemBuilder: (_, index) {
                      AlgoliaObjectSnapshot snap = _games[index];

                      return Padding(
                          padding: EdgeInsets.symmetric(vertical: 5.0),
                          child: ListTile(
                            onTap: () {
                              addInRecentSearch(snap);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => ProfileGameScreen(
                                          game: Game.fromMapAlgolia(
                                              snap, snap.data),
                                          navKey: navExploreAuthKey!)));
                            },
                            leading: Container(
                              height: 45,
                              width: 45,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).canvasColor,
                                  image: DecorationImage(
                                      image: CachedNetworkImageProvider(
                                          snap.data["imageUrl"]),
                                      fit: BoxFit.cover)),
                            ),
                            title: Text(
                              snap.data["name"],
                            ),
                          ));
                    });
  }

  Widget hastags() {
    return _searching
        ? Center(
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
                )
              ],
            ),
          )
        : _searchController.text.isEmpty
            ? recentSearchHashtags()
            : _hashtags.length == 0
                ? Center(
                    child: Text(
                      'No hashtags found',
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: _hashtags.length,
                    itemBuilder: (_, index) {
                      AlgoliaObjectSnapshot snap = _hashtags[index];

                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.0),
                        child: ListTile(
                          onTap: () {
                            addInRecentSearch(snap);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => HashtagsScreen(
                                        hashtag: Hashtag.fromMapAlgolia(
                                            snap, snap.data))));
                          },
                          leading: Container(
                            height: 45,
                            width: 45,
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
                            child: Icon(Icons.tag_sharp),
                          ),
                          title: Text(
                            snap.data["name"],
                          ),
                          subtitle: Text(
                            '${snap.data["postsCount"]} publications',
                          ),
                        ),
                      );
                    });
  }
}
