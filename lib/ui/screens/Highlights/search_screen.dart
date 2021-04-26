import 'package:Gemu/ui/screens/Games/game_focus_screen.dart';
import 'package:Gemu/ui/screens/Home/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchScreen extends StatefulWidget {
  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController _searchController = TextEditingController();

  TabController _tabController;
  int currentTabIndex;

  Future resultsGamesLoaded, resultsUsersLoaded, resultAllLoaded;
  List _allResults = [];
  List _resultsList = [];
  List _allResultsUsers = [];
  List _resultsListUsers = [];
  List _allResultsGames = [];
  List _resultsListGames = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    currentTabIndex = 0;
    _tabController.addListener(_onTabChanged);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    resultAllLoaded = getAllStreamSnapshot();
    resultsUsersLoaded = getUsersStreamSnapshots();
    resultsGamesLoaded = getGamesStreamSnapshots();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        print('Changing to Tab: ${_tabController.index}');
        currentTabIndex = _tabController.index;
      });
    }
  }

  _onSearchChanged() {
    if (_tabController.index == 0) {
      searchResultsListAll();
    }
    if (_tabController.index == 1) {
      searchResultsListUsers();
    }
    if (_tabController.index == 2) {
      searchResultsListGames();
    }
  }

  searchResultsListAll() {
    var showResults = [];

    if (_searchController.text != "") {
      for (var allSnapshot in _allResults) {
        var name;
        if (allSnapshot.data()['pseudo'] == null) {
          name = allSnapshot.data()['name'].toLowerCase();
          if (name.contains(_searchController.text.toLowerCase())) {
            showResults.add(allSnapshot);
          }
        } else {
          name = allSnapshot.data()['pseudo'].toLowerCase();
          if (name.contains(_searchController.text.toLowerCase())) {
            showResults.add(allSnapshot);
          }
        }
      }
    } else {
      showResults = List.from(_allResults);
    }
    setState(() {
      _resultsList = showResults;
    });
  }

  searchResultsListUsers() {
    var showResults = [];

    if (_searchController.text != "") {
      for (var userSnapshot in _allResultsUsers) {
        var name = userSnapshot.data()['pseudo'].toLowerCase();

        if (name.contains(_searchController.text.toLowerCase())) {
          showResults.add(userSnapshot);
        }
      }
    } else {
      showResults = List.from(_allResultsUsers);
    }
    setState(() {
      _resultsListUsers = showResults;
    });
  }

  searchResultsListGames() {
    var showResults = [];

    if (_searchController.text != "") {
      for (var gameSnapshot in _allResultsGames) {
        var name = gameSnapshot.data()['name'].toLowerCase();

        if (name.contains(_searchController.text.toLowerCase())) {
          showResults.add(gameSnapshot);
        }
      }
    } else {
      showResults = List.from(_allResultsGames);
    }
    setState(() {
      _resultsListGames = showResults;
    });
  }

  getAllStreamSnapshot() async {
    var dataUsers = await FirebaseFirestore.instance.collection('users').get();
    var dataGames = await FirebaseFirestore.instance.collection('games').get();
    setState(() {
      _allResults = List.from(dataUsers.docs)..addAll(dataGames.docs);
    });
    searchResultsListAll();
    return "complete";
  }

  getUsersStreamSnapshots() async {
    var data = await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      _allResultsUsers = data.docs;
    });
    searchResultsListUsers();
    return "complete";
  }

  getGamesStreamSnapshots() async {
    var data = await FirebaseFirestore.instance.collection('games').get();
    setState(() {
      _allResultsGames = data.docs;
    });
    searchResultsListGames();
    return "complete";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 6,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context)),
        title: TextFormField(
          controller: _searchController,
          autofocus: true,
          cursorColor: Theme.of(context).primaryColor,
          decoration: InputDecoration(
              labelText: 'Search',
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.clear),
              onPressed: () => _searchController.clear())
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(25),
          child: TabBar(
              controller: _tabController,
              labelPadding: EdgeInsets.only(bottom: 5.0),
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              tabs: [Text('All'), Text('User'), Text('Game'), Text('Hashtag')]),
        ),
      ),
      body: TabBarView(
          physics: AlwaysScrollableScrollPhysics(),
          controller: _tabController,
          children: [
            all(),
            user(),
            game(),
            Center(
              child: Text('Hastag'),
            ),
          ]),
    );
  }

  Widget all() {
    return ListView.builder(
        itemCount: _resultsList.length,
        itemBuilder: (BuildContext context, int index) {
          DocumentSnapshot all = _resultsList[index];
          return Padding(
            padding: EdgeInsets.only(top: 5.0),
            child: ListTile(
              onTap: () {
                if (all.data()['photoURL'] == null) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GameFocusScreen(game: all)));
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfileView(
                                idUser: all.data()['id'],
                              )));
                }
              },
              leading: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black),
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(
                            all.data()['photoURL'] == null
                                ? all.data()['imageUrl']
                                : all.data()['photoURL']))),
              ),
              title: Text(all.data()['pseudo'] == null
                  ? all.data()['name']
                  : all.data()['pseudo']),
            ),
          );
        });
  }

  Widget user() {
    return ListView.builder(
        itemCount: _resultsListUsers.length,
        itemBuilder: (BuildContext context, int index) {
          DocumentSnapshot user = _resultsListUsers[index];
          return Padding(
            padding: EdgeInsets.only(top: 5.0),
            child: ListTile(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileView(
                            idUser: user.data()['id'],
                          ))),
              leading: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black),
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(
                            user.data()['photoURL']))),
              ),
              title: Text(user.data()['pseudo']),
            ),
          );
        });
  }

  Widget game() {
    return ListView.builder(
        itemCount: _resultsListGames.length,
        itemBuilder: (BuildContext context, int index) {
          DocumentSnapshot game = _resultsListGames[index];
          return Padding(
            padding: EdgeInsets.only(top: 5.0),
            child: ListTile(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GameFocusScreen(game: game))),
              leading: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black),
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(
                            game.data()['imageUrl']))),
              ),
              title: Text(game.data()['name']),
            ),
          );
        });
  }
}
