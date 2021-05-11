import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:helpers/helpers.dart';

import 'package:Gemu/constants/route_names.dart';
import 'package:Gemu/constants/variables.dart';
import 'package:Gemu/models/game.dart';
import 'package:Gemu/ui/screens/Home/components/actions_postbar.dart';
import 'package:Gemu/ui/screens/Home/profile_view.dart';
import 'package:video_player/video_player.dart';

class EditPrivatePostsVideo extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>>? post;

  EditPrivatePostsVideo({this.post});

  @override
  EditPrivatePostsVideoState createState() => EditPrivatePostsVideoState();
}

class EditPrivatePostsVideoState extends State<EditPrivatePostsVideo> {
  bool isUploading = false;

  String? nameGame, caption;

  bool _isCaption = false;
  bool _isHashtags = false;

  late VideoPlayerController _videoPlayerController;

  TextEditingController _captionController = TextEditingController();
  TextEditingController _hashtagsController = TextEditingController();
  FocusNode? _focusNodeCaption, _focusNodeHashtags;

  List? hashtagsSelected = [];
  List<String> hashtagsListTest = [
    'Test1',
    'Test2',
    'Expérience 1',
    'Expérience 2',
    'Expérience 3',
    'Expérience 4',
    'Expérience 5',
    'Expérience 6',
    'Expérience 7',
    'Expérience 8'
  ];
  List<String> hastagsListNbPostsTest = [
    '2 000',
    '2',
    '30 000',
    '45',
    '45',
    '45',
    '45',
    '45',
    '45',
    '45'
  ];

  String? choixGameName = "";
  String privacy = "Private";

  String? id;
  int? postsCount;

  uploadVideo() {
    setState(() {
      isUploading = true;
    });

    try {
      if (privacy != "Private") {
        print('private');
        FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.post!.data()!['id'])
            .update({'privacy': 'Public'});
      }
      if (nameGame != widget.post!.data()!['game']) {
        print('name game');
        FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.post!.data()!['id'])
            .update({'game': nameGame});
      }
      if (caption != widget.post!.data()!['caption']) {
        print('caption');
        FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.post!.data()!['id'])
            .update({'caption': caption});
      }

      Navigator.pushNamedAndRemoveUntil(
          context, NavScreenRoute, (route) => false);
    } catch (e) {
      print(e);
    }
  }

  addHashtags(String hastagsText) async {
    FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post!.data()!['id'])
        .update({
      'hashtags': FieldValue.arrayUnion([_hashtagsController.text])
    });

    var hashtagdocs =
        await FirebaseFirestore.instance.collection('hashtags').get();
    int hashtagsLength = hashtagdocs.docs.length;
    print('$hashtagsLength');

    var docHashtags = await FirebaseFirestore.instance
        .collection('hashtags')
        .where('name', isEqualTo: hastagsText)
        .get();
    for (var item in docHashtags.docs) {
      id = item.data()['id'];
      postsCount = item.data()['postsCount'];
    }

    if (docHashtags.docs.isEmpty) {
      FirebaseFirestore.instance
          .collection('hashtags')
          .doc(hastagsText)
          .set({'id': hastagsText, 'name': hastagsText, 'postsCount': 1});
      FirebaseFirestore.instance
          .collection('hashtags')
          .doc(hastagsText)
          .collection('posts')
          .doc(widget.post!.data()!['id'])
          .set({});
    } else {
      FirebaseFirestore.instance
          .collection('hashtags')
          .doc(id)
          .update({'postsCount': postsCount! + 1});
      FirebaseFirestore.instance
          .collection('hashtags')
          .doc(id)
          .collection('posts')
          .doc(widget.post!.data()!['id'])
          .set({});
    }
  }

  deleteHashtags(String hash) async {
    FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post!.data()!['id'])
        .update({
      'hashtags': FieldValue.arrayRemove([hash])
    });

    var docHashtags = await FirebaseFirestore.instance
        .collection('hashtags')
        .where('name', isEqualTo: hash)
        .get();
    for (var item in docHashtags.docs) {
      id = item.data()['id'];
      postsCount = item.data()['postsCount'];
    }

    FirebaseFirestore.instance
        .collection('hashtags')
        .doc(id)
        .update({'postsCount': postsCount! - 1});
    FirebaseFirestore.instance
        .collection('hashtags')
        .doc(id)
        .collection('posts')
        .doc(widget.post!.data()!['id'])
        .delete();
  }

  @override
  void initState() {
    super.initState();

    _videoPlayerController =
        VideoPlayerController.network(widget.post!.data()!['videoUrl'])
          ..initialize().then((_) {
            setState(() {});
          });

    nameGame = widget.post!.data()!['game'];
    caption = widget.post!.data()!['caption'];
    hashtagsSelected = widget.post!.data()!['hashtags'];

    _focusNodeCaption = FocusNode();
    _focusNodeHashtags = FocusNode();

    _captionController.text = caption!;
  }

  @override
  void dispose() async {
    if (mounted) {
      await _videoPlayerController.dispose();
    }
    _captionController.dispose();
    _hashtagsController.dispose();
    _focusNodeCaption!.dispose();
    _focusNodeHashtags!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
            child: isUploading
                ? Stack(
                    children: [
                      Center(
                        child: AspectRatio(
                          aspectRatio: _videoPlayerController.value.aspectRatio,
                          child: VideoPlayer(_videoPlayerController),
                        ),
                      ),
                      Center(
                          child: Container(
                        color: Theme.of(context)
                            .scaffoldBackgroundColor
                            .withOpacity(0.7),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Uploading..',
                                style: mystyle(18),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              CircularProgressIndicator()
                            ],
                          ),
                        ),
                      )),
                    ],
                  )
                : _isCaption || _isHashtags
                    ? Stack(
                        children: [
                          Center(
                            child: AspectRatio(
                              aspectRatio:
                                  _videoPlayerController.value.aspectRatio,
                              child: VideoPlayer(_videoPlayerController),
                            ),
                          ),
                          _isCaption ? _caption() : _hashtags()
                        ],
                      )
                    : GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_videoPlayerController.value.isPlaying) {
                              _videoPlayerController.pause();
                            } else {
                              _videoPlayerController.play();
                              _videoPlayerController.setLooping(true);
                            }
                          });
                        },
                        child: Stack(
                          children: [
                            Center(
                              child: AspectRatio(
                                aspectRatio:
                                    _videoPlayerController.value.aspectRatio,
                                child: VideoPlayer(_videoPlayerController),
                              ),
                            ),
                            Center(
                                child: OpacityTransition(
                              visible: !_videoPlayerController.value.isPlaying,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle),
                                child: Icon(
                                  _videoPlayerController.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.black,
                                ),
                              ),
                            )),
                            Align(
                              alignment: Alignment.topCenter,
                              child: _topBar(),
                            ),
                            Positioned(
                                left: 0,
                                bottom: 0,
                                child: _postDescriptionEdit()),
                            Positioned(
                                right: 0,
                                bottom: 10,
                                child: ActionsPostBar(
                                  idUser: widget.post!.data()!['uid'],
                                  idPost: widget.post!.data()!['id'],
                                  profilPicture:
                                      widget.post!.data()!['profilepicture'],
                                  commentsCounts: widget.post!
                                      .data()!['commentcount']
                                      .toString(),
                                  up: widget.post!.data()!['up'],
                                  down: widget.post!.data()!['down'],
                                )),
                          ],
                        ),
                      )));
  }

  Widget _caption() {
    return Container(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isCaption = !_isCaption;
                            _captionController.text = caption!;
                          });
                        },
                        child: Icon(
                          Icons.clear,
                        ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(right: 10.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isCaption = !_isCaption;
                              caption = _captionController.text;
                            });
                          },
                          child: Icon(Icons.check),
                        ))
                  ],
                ),
              ),
            ),
            Center(
                child: TextField(
              controller: _captionController,
              focusNode: _focusNodeCaption,
              autofocus: true,
              minLines: 1,
              maxLines: 15,
              decoration: InputDecoration(border: OutlineInputBorder()),
            )),
          ],
        ));
  }

  Widget _hashtags() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isHashtags = !_isHashtags;
                      _hashtagsController.clear();
                    });
                  },
                  child: Icon(Icons.check),
                ),
              )),
          TextField(
            controller: _hashtagsController,
            focusNode: _focusNodeHashtags,
            autofocus: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              suffixIcon: InkWell(
                onTap: () {
                  if (!hashtagsSelected!
                      .contains(_hashtagsController.text.toLowerCase())) {
                    setState(() {
                      hashtagsSelected!.add(_hashtagsController.text);
                    });
                    addHashtags(_hashtagsController.text);
                  }
                  _hashtagsController.clear();
                },
                child: Icon(Icons.add),
              ),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          hashtagsSelected!.length < 1
              ? Container(
                  height: 50,
                  decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).accentColor)),
                  child: Center(
                    child: Text('Pas encore d\'hashtags'),
                  ),
                )
              : Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).accentColor)),
                  child: Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: hashtagsSelected!.map((hashtag) {
                          return Chip(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            label: Text('#$hashtag', style: mystyle(11)),
                            onDeleted: () {
                              setState(() {
                                hashtagsSelected!.remove(hashtag);
                              });
                              deleteHashtags(hashtag);
                            },
                          );
                        }).toList()),
                  )),
          SizedBox(
            height: 10.0,
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: hashtagsListTest.length,
              itemBuilder: (context, index) {
                return hashtagsListTest[index]
                        .toLowerCase()
                        .contains(_hashtagsController.text.toLowerCase())
                    ? ListTile(
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
                                      Theme.of(context).primaryColor,
                                      Theme.of(context).accentColor
                                    ])),
                            child: Icon(Icons.tag, size: 15)),
                        title: Text(
                          hashtagsListTest[index],
                          style: mystyle(12),
                        ),
                        trailing: Text(
                          '${hastagsListNbPostsTest[index]} publications',
                          style: mystyle(11, Colors.white.withOpacity(0.6)),
                        ),
                        onTap: () {
                          setState(() {
                            if (!hashtagsSelected!
                                .contains(hashtagsListTest[index])) {
                              hashtagsSelected!.add(hashtagsListTest[index]);
                              _hashtagsController.clear();
                            }
                          });
                        })
                    : Container();
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    height: 50,
                    width: 50,
                    child: Icon(
                      Icons.clear,
                      color: Colors.white,
                    ),
                  )),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 85,
              child: Column(
                children: [
                  _privacy(),
                  SizedBox(
                    height: 10.0,
                  ),
                  GestureDetector(
                    onTap: () => _chooseGame(),
                    child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.3),
                                  Theme.of(context).accentColor.withOpacity(0.3)
                                ])),
                        child: Icon(
                          Icons.videogame_asset,
                          color: Colors.white,
                        )),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: GestureDetector(
                  onTap: () => uploadVideo(),
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).accentColor
                            ])),
                    child: Icon(
                      Icons.share_outlined,
                      color: Colors.white,
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget _privacy() {
    return GestureDetector(
      onTap: () {
        if (privacy == "Public") {
          setState(() {
            privacy = "Private";
          });
        } else if (privacy == "Private") {
          setState(() {
            privacy = "Public";
          });
        }
      },
      child: Container(
        height: 25,
        width: MediaQuery.of(context).size.width / 4,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.3),
                  Theme.of(context).accentColor.withOpacity(0.3)
                ]),
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(10.0)),
        child: Text(
          privacy,
          style: mystyle(11),
        ),
      ),
    );
  }

  Future<void> _chooseGame() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).canvasColor,
            elevation: 6.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            title: Text('Choose game'),
            content: Builder(
              builder: (context) {
                var height = MediaQuery.of(context).size.height;

                return Container(
                  alignment: Alignment.center,
                  height: height - 400,
                  child: FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .get(),
                      builder: (context, AsyncSnapshot snapshotGamesID) {
                        if (!snapshotGamesID.hasData) {
                          return CircularProgressIndicator();
                        }
                        return StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('games')
                              .where(FieldPath.documentId,
                                  whereIn: snapshotGamesID.data['idGames'])
                              .snapshots(),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasData) {
                              return Wrap(
                                children: snapshot.data!.docs.map((snapshot) {
                                  Game game = Game.fromMap(
                                      snapshot.data() as Map<String, dynamic>,
                                      snapshot.id);
                                  return Container(
                                      margin: EdgeInsets.only(
                                          bottom: 10.0, top: 10.0),
                                      width: 90,
                                      height: 85,
                                      child: Stack(
                                        children: [
                                          Align(
                                              alignment: Alignment.topCenter,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    choixGameName = game.name;
                                                  });
                                                },
                                                child: Container(
                                                  height: 60,
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                          colors: [
                                                            Theme.of(context)
                                                                .primaryColor,
                                                            Theme.of(context)
                                                                .accentColor
                                                          ]),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      image: DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: CachedNetworkImageProvider(
                                                              game.imageUrl!))),
                                                ),
                                              )),
                                          Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Text(game.name!),
                                          )
                                        ],
                                      ));
                                }).toList(),
                              );
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          },
                        );
                      }),
                );
              },
            ),
            actions: [
              TextButton(
                  child: Text(
                    'Cancel',
                    style: mystyle(11, Colors.red),
                  ),
                  onPressed: () {
                    print('Avant $nameGame');
                    setState(() {
                      choixGameName = "";
                    });
                    Navigator.of(context).pop();
                    print('Après $nameGame');
                  }),
              TextButton(
                child: Text(
                  'Ok',
                  style: mystyle(11, Colors.blue),
                ),
                onPressed: () {
                  print('Avant $nameGame');
                  if (nameGame != choixGameName) {
                    setState(() {
                      nameGame = choixGameName;
                    });
                  } else {
                    setState(() {
                      choixGameName = "";
                    });
                  }
                  Navigator.pop(context);
                  print('Après $nameGame');
                },
              )
            ],
          );
        });
  }

  Widget _postDescriptionEdit() {
    return Container(
        width: MediaQuery.of(context).size.width / 2,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfileView(
                                idUser: widget.post!.data()!['uid'],
                              ))),
                  child: Text(widget.post!.data()!['username'],
                      style: mystyle(15))),
              SizedBox(
                height: 5.0,
              ),
              Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.circular(5.0)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SingleChildScrollView(
                          child: Container(
                        width: MediaQuery.of(context).size.width / 4,
                        child: Text(
                          caption!,
                          style: TextStyle(color: Colors.grey),
                        ),
                      )),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isCaption = !_isCaption;
                          });
                        },
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Theme.of(context).primaryColor,
                                    Theme.of(context).accentColor
                                  ])),
                          child: Icon(
                            Icons.edit,
                            size: 15,
                          ),
                        ),
                      )
                    ],
                  )),
              SizedBox(
                height: 10.0,
              ),
              Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.circular(5.0)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: hashtagsSelected!.length > 5 ? 75 : null,
                        width: MediaQuery.of(context).size.width / 4,
                        child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2, childAspectRatio: 1.5),
                            shrinkWrap: true,
                            physics: AlwaysScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            itemCount: hashtagsSelected!.length,
                            itemBuilder: (context, index) {
                              return Text(
                                '#${hashtagsSelected![index]}',
                                style: TextStyle(color: Colors.grey),
                              );
                            }),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isHashtags = !_isHashtags;
                          });
                        },
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Theme.of(context).primaryColor,
                                    Theme.of(context).accentColor
                                  ])),
                          child: Icon(
                            Icons.edit,
                            size: 15,
                          ),
                        ),
                      )
                    ],
                  )),
              SizedBox(
                height: 10.0,
              )
            ]));
  }
}
