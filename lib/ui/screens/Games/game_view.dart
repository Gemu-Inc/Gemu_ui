import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'game_focus_screen.dart';

class GameView extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>> game;

  GameView({required this.game});

  @override
  GameViewState createState() => GameViewState();
}

class GameViewState extends State<GameView> {
  bool dataIsThere = false;
  bool isFollow = false;

  String? uid;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
    getAllData();
  }

  getAllData() async {
    List games = [];
    var doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('games')
        .get();
    for (var item in doc.docs) {
      games.add(item.id);
    }
    if (games.contains(widget.game.id)) {
      setState(() {
        isFollow = true;
      });
    } else {
      setState(() {
        isFollow = false;
      });
    }
    setState(() {
      dataIsThere = true;
    });
  }

  follow() async {
    List games = [];
    var doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('games')
        .get();
    for (var item in doc.docs) {
      games.add(item.id);
    }
    if (games.contains(widget.game.id)) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('games')
          .doc(widget.game.id)
          .delete();
      setState(() {
        isFollow = false;
      });
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('games')
          .doc(widget.game.id)
          .set({
        'name': widget.game.data()!['name'],
        'imageUrl': widget.game.data()!['imageUrl']
      });
      setState(() {
        isFollow = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return dataIsThere
        ? Container(
            margin: EdgeInsets.only(bottom: 30.0, top: 10.0),
            width: 90,
            height: 85,
            child: Stack(
              children: [
                Align(
                    alignment: Alignment.topCenter,
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => GameFocusScreen(game: widget.game)),
                      ),
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme.of(context).primaryColor,
                                  Theme.of(context).accentColor
                                ]),
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: CachedNetworkImageProvider(
                                    widget.game.data()!['imageUrl']))),
                      ),
                    )),
                Positioned(
                  bottom: 15,
                  right: 25,
                  child: followGame(),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(widget.game.data()!['name']),
                )
              ],
            ))
        : Center(
            child: CircularProgressIndicator(),
          );
  }

  Widget followGame() {
    return GestureDetector(
        onTap: () => follow(),
        child: Container(
            height: 25,
            width: 25,
            decoration: BoxDecoration(
                color: isFollow ? Colors.green[400] : Colors.red[400],
                shape: BoxShape.circle,
                border: Border.all(color: Color(0xFF222831))),
            child: isFollow
                ? Icon(
                    Icons.check,
                    size: 20,
                  )
                : Icon(
                    Icons.add,
                    size: 20,
                  )));
  }
}
