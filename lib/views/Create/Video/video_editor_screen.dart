import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gemu/constants/constants.dart';
import 'package:gemu/models/game.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VideoEditorScreen extends StatefulWidget {
  final File? file;

  VideoEditorScreen({required this.file});

  @override
  VideoEditorviewstate createState() => VideoEditorviewstate();
}

class VideoEditorviewstate extends State<VideoEditorScreen> {
  String uid = FirebaseAuth.instance.currentUser!.uid;

  late PageController _pageController;
  int currentPageIndex = 0;

  late VideoPlayerController _videoPlayerController;

  late TextEditingController _captionController, _hashtagsController;
  late FocusNode _captionFocusNode, _hashtagsFocusNode;

  Future? gamesLoaded, hashtagsLoaded;

  bool public = true;

  Game selectedGame = Game(
      documentId: "0", name: "No game", imageUrl: "No game", categories: []);

  List<String> hashtagsSelected = [];
  List _allResults = [];
  List _resultList = [];
  List _allResultsGames = [];

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.file(widget.file!,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true))
      ..initialize().then((value) {
        if (mounted) {
          setState(() {
            _videoPlayerController.setLooping(true);
            _videoPlayerController.setVolume(0.0);
            _videoPlayerController.play();
          });
        }
      });

    _pageController = PageController(initialPage: currentPageIndex);
    _captionController = TextEditingController();
    _hashtagsController = TextEditingController();
    _captionFocusNode = FocusNode();
    _hashtagsFocusNode = FocusNode();

    gamesLoaded = getGamesStreamSnapshots();
    _hashtagsController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    hashtagsLoaded = getHashtagsStreamSnapshots();
  }

  @override
  void dispose() {
    _captionFocusNode.dispose();
    _hashtagsFocusNode.dispose();
    _captionController.dispose();
    _hashtagsController.removeListener(_onSearchChanged);
    _hashtagsController.dispose();
    _pageController.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  getGamesStreamSnapshots() async {
    var data = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('games')
        .get();
    for (var item in data.docs) {
      var game = await FirebaseFirestore.instance
          .collection('games')
          .doc('verified')
          .collection('games_verified')
          .doc(item.id)
          .get();
      setState(() {
        _allResultsGames.add(game);
      });
    }
  }

  getHashtagsStreamSnapshots() async {
    var data = await FirebaseFirestore.instance
        .collection('hashtags')
        .orderBy('postsCount', descending: true)
        .get();
    setState(() {
      _allResults = data.docs;
    });
    searchResultsListHashtags();
    return "complete";
  }

  _onSearchChanged() {
    searchResultsListHashtags();
  }

  searchResultsListHashtags() {
    var showResults = [];

    if (_hashtagsController.text != "") {
      for (var hashtagSnapshot in _allResults) {
        var name = hashtagSnapshot.data()['name'].toLowerCase();

        if (name.contains(_hashtagsController.text.toLowerCase())) {
          showResults.add(hashtagSnapshot);
        }
      }
    } else {
      showResults = List.from(_allResults);
    }
    setState(() {
      _resultList = showResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          SizedBox(
            height: 20.0,
          ),
          Container(
            height: 50,
            width: MediaQuery.of(context).size.width,
            child: Center(
                child: Row(
              children: [
                IconButton(
                    onPressed: () async {
                      navMainAuthKey.currentState!.pushNamedAndRemoveUntil(
                          BottomTabNav, (route) => false);
                    },
                    icon: Icon(Icons.clear)),
                Text(
                  'Edit video',
                ),
              ],
            )),
          ),
          Expanded(
              child: Stack(
            children: [
              AnimatedBuilder(
                  animation: _videoPlayerController,
                  builder: (_, __) {
                    return Center(
                      child: AspectRatio(
                        aspectRatio: _videoPlayerController.value.aspectRatio,
                        child: VideoPlayer(_videoPlayerController),
                      ),
                    );
                  }),
              PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                children: [gamePage(), captionPage(), hashtagsPage()],
              )
            ],
          )),
          bottomBar()
        ],
      ),
    );
  }

  Widget gamePage() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          SizedBox(
            height: 20.0,
          ),
          Container(
            height: 100,
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                selectedGame.name == 'No game'
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Game',
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Icon(Icons.videogame_asset),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text('No game')
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Game',
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(5.0),
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider(
                                        selectedGame.imageUrl))),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(selectedGame.name)
                        ],
                      ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Privacy',
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    IconButton(
                        icon: Icon(
                          public ? Icons.lock_open : Icons.lock_outline,
                          size: 33,
                        ),
                        onPressed: () {
                          setState(() {
                            public = !public;
                          });
                        }),
                    Text(public ? 'Public' : 'Private')
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: _allResultsGames.length,
                itemBuilder: (BuildContext context, int index) {
                  DocumentSnapshot<Map<String, dynamic>> _documentSnapshot =
                      _allResultsGames[index];
                  return ListTile(
                    onTap: () {
                      setState(() {
                        selectedGame = Game.fromMap(
                            _documentSnapshot, _documentSnapshot.data()!);
                      });
                    },
                    leading: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(5.0),
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                  _documentSnapshot.data()!['imageUrl']))),
                    ),
                    title: Text(_documentSnapshot.data()!['name']),
                  );
                }),
          )
        ],
      ),
    );
  }

  Widget captionPage() {
    return GestureDetector(
      onTap: () {
        if (_captionFocusNode.hasFocus) {
          _captionFocusNode.unfocus();
        }
      },
      child: Container(
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Center(
              child: TextField(
            controller: _captionController,
            focusNode: _captionFocusNode,
            autofocus: true,
            minLines: 1,
            maxLines: 15,
            cursorColor: Theme.of(context).colorScheme.secondary,
            decoration: InputDecoration(
                labelText: 'Write caption',
                labelStyle:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary)),
                suffixIcon: IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    onPressed: () => _captionController.clear())),
          ))),
    );
  }

  Widget hashtagsPage() {
    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: GestureDetector(
        onTap: () {
          if (_hashtagsFocusNode.hasFocus) {
            _hashtagsFocusNode.unfocus();
          }
        },
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              TextField(
                controller: _hashtagsController,
                focusNode: _hashtagsFocusNode,
                autofocus: false,
                decoration: InputDecoration(
                  labelText: 'Write hashtag',
                  labelStyle:
                      TextStyle(color: Theme.of(context).colorScheme.secondary),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary)),
                  contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  suffixIcon: InkWell(
                    onTap: () {
                      if (!hashtagsSelected
                          .contains(_hashtagsController.text.toLowerCase())) {
                        setState(() {
                          hashtagsSelected.add(_hashtagsController.text);
                        });
                        _hashtagsController.clear();
                      } else {
                        _hashtagsController.clear();
                      }
                    },
                    child: Icon(Icons.add,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              hashtagsSelected.length < 1
                  ? Container(
                      height: 50,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).colorScheme.secondary)),
                      child: Center(
                        child: Text('Pas encore d\'hashtags'),
                      ),
                    )
                  : Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).colorScheme.secondary)),
                      child: Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: hashtagsSelected.map((hashtag) {
                              return Chip(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                label: Text(
                                  '#$hashtag',
                                ),
                                onDeleted: () {
                                  setState(() {
                                    hashtagsSelected.remove(hashtag);
                                  });
                                },
                              );
                            }).toList()),
                      )),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: _resultList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                        leading: Container(
                            alignment: Alignment.center,
                            height: 25,
                            width: 25,
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
                            child: Icon(Icons.tag, size: 15)),
                        title: Text(
                          _resultList[index].data()['name'],
                        ),
                        trailing: Text(
                          '${_resultList[index].data()['postsCount']} publications',
                        ),
                        onTap: () {
                          setState(() {
                            if (!hashtagsSelected
                                .contains(_resultList[index].data()['name'])) {
                              hashtagsSelected
                                  .add(_resultList[index].data()['name']);
                              _hashtagsController.clear();
                            }
                          });
                        });
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomBar() {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          currentPageIndex == 0
              ? SizedBox()
              : Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        currentPageIndex--;
                      });
                      if (_captionFocusNode.hasFocus) {
                        _captionFocusNode.unfocus();
                      }
                      if (_hashtagsFocusNode.hasFocus) {
                        _hashtagsFocusNode.unfocus();
                      }
                      _pageController.previousPage(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.bounceInOut);
                    },
                    child: Container(
                      height: 30,
                      width: 60,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(15.0),
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary
                              ])),
                      child: Center(
                        child: Text(
                          'Prev',
                        ),
                      ),
                    ),
                  ),
                ),
          currentPageIndex < 2
              ? Padding(
                  padding: EdgeInsets.only(right: 10.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        currentPageIndex++;
                      });
                      if (_captionFocusNode.hasFocus) {
                        _captionFocusNode.unfocus();
                      }
                      if (_hashtagsFocusNode.hasFocus) {
                        _hashtagsFocusNode.unfocus();
                      }
                      _pageController.nextPage(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.bounceInOut);
                    },
                    child: Container(
                      height: 30,
                      width: 60,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(15.0),
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary
                              ])),
                      child: Center(
                        child: Text(
                          'Next',
                        ),
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.only(right: 10.0),
                  child: GestureDetector(
                    onTap: () => navMainAuthKey.currentState!
                        .pushNamed(PostNewVideo, arguments: [
                      widget.file,
                      public,
                      _captionController.text,
                      hashtagsSelected,
                      _allResultsGames,
                      selectedGame,
                    ]),
                    child: Container(
                      height: 30,
                      width: 60,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(15.0),
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary
                              ])),
                      child: Center(
                          child: Icon(
                        Icons.check,
                        color: Colors.black38,
                      )),
                    ),
                  ),
                )
        ],
      ),
    );
  }
}
