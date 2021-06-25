import 'package:Gemu/ui/screens/Games/game_focus_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchGameScreen extends StatefulWidget {
  @override
  SearchGameScreenState createState() => SearchGameScreenState();
}

class SearchGameScreenState extends State<SearchGameScreen> {
  TextEditingController _searchGame = TextEditingController();

  Future? resultsLoaded;
  List _allResults = [];
  List _resultsList = [];

  @override
  void initState() {
    super.initState();
    _searchGame.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchGame.removeListener(_onSearchChanged);
    _searchGame.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    resultsLoaded = getGamesStreamSnapshots();
  }

  _onSearchChanged() {
    searchResultsList();
  }

  searchResultsList() {
    var showResults = [];

    if (_searchGame.text != "") {
      for (var gameSnapshot in _allResults) {
        var name = gameSnapshot.data()['name'].toLowerCase();

        if (name.contains(_searchGame.text.toLowerCase())) {
          showResults.add(gameSnapshot);
        }
      }
    } else {
      showResults = List.from(_allResults);
    }
    setState(() {
      _resultsList = showResults;
    });
  }

  getGamesStreamSnapshots() async {
    var data = await FirebaseFirestore.instance
        .collection('games')
        .where('verified', isEqualTo: true)
        .get();
    setState(() {
      _allResults = data.docs;
    });
    searchResultsList();
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
            controller: _searchGame,
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
                icon: Icon(Icons.clear), onPressed: () => _searchGame.clear())
          ],
        ),
        body: ListView.builder(
            itemCount: _resultsList.length,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot<Map<String, dynamic>> game = _resultsList[index];
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
                            image: CachedNetworkImageProvider(
                                game.data()!['imageUrl']))),
                  ),
                  title: Text(game.data()!['name']),
                ),
              );
            }));
  }
}
