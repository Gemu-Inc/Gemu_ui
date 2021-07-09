import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:gemu/ui/screens/Home/comments_view.dart';
import 'package:gemu/services/database_service.dart';

import '../profile_view.dart';

class ActionsPostBar extends StatefulWidget {
  final String idUser, profilPicture, commentsCounts, idPost;

  final List? up, down;

  ActionsPostBar(
      {required this.idUser,
      required this.idPost,
      required this.profilPicture,
      required this.commentsCounts,
      required this.up,
      required this.down});

  @override
  ActionsPostBarState createState() => ActionsPostBarState();
}

class ActionsPostBarState extends State<ActionsPostBar> {
  static const double ActionWidgetSize = 60.0;
  static const double ActionIconSize = 35.0;
  static const double ShareActionIconSize = 25.0;
  static const double ProfileImageSize = 50.0;
  static const double PlusIconSize = 20.0;

  late String uid;
  bool isFollowing = false;
  bool dataIsThere = false;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;

    //check if the online user is already follow
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.idUser)
        .collection('followers')
        .doc(uid)
        .get()
        .then((document) {
      if (!document.exists) {
        setState(() {
          isFollowing = false;
        });
      } else {
        setState(() {
          isFollowing = true;
        });
      }
    });

    setState(() {
      dataIsThere = true;
    });
  }

  pointUpPost(String? id) async {
    DocumentSnapshot<Map<String, dynamic>> doc =
        await FirebaseFirestore.instance.collection('posts').doc(id).get();
    if (doc.data()!['up'].contains(uid)) {
      FirebaseFirestore.instance.collection('posts').doc(id).update({
        'up': FieldValue.arrayRemove([uid])
      });
    } else {
      FirebaseFirestore.instance.collection('posts').doc(id).update({
        'down': FieldValue.arrayRemove([uid])
      });
      FirebaseFirestore.instance.collection('posts').doc(id).update({
        'up': FieldValue.arrayUnion([uid])
      });
    }

    DatabaseService.addNotification(
        uid, widget.idUser, "a up votre post", "updown");
  }

  pointsDownPost(String? id) async {
    DocumentSnapshot<Map<String, dynamic>> doc =
        await FirebaseFirestore.instance.collection('posts').doc(id).get();
    if (doc.data()!['down'].contains(uid)) {
      FirebaseFirestore.instance.collection('posts').doc(id).update({
        'down': FieldValue.arrayRemove([uid])
      });
    } else {
      FirebaseFirestore.instance.collection('posts').doc(id).update({
        'up': FieldValue.arrayRemove([uid])
      });
      FirebaseFirestore.instance.collection('posts').doc(id).update({
        'down': FieldValue.arrayUnion([uid])
      });
    }

    DatabaseService.addNotification(
        uid, widget.idUser, "a down votre post", "updown");
  }

  followUser() async {
    var document = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.idUser)
        .collection('followers')
        .doc(uid)
        .get();

    if (!document.exists) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.idUser)
          .collection('followers')
          .doc(uid)
          .set({});

      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('following')
          .doc(widget.idUser)
          .set({});

      DatabaseService.addNotification(
          uid, widget.idUser, "a commencé à vous suivre", "follow");

      setState(() {
        isFollowing = true;
      });
    } else {
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.idUser)
          .collection('followers')
          .doc(uid)
          .delete();

      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('following')
          .doc(widget.idUser)
          .delete();

      setState(() {
        isFollowing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int points = (widget.up!.length - widget.down!.length);
    return dataIsThere
        ? Container(
            alignment: Alignment.center,
            height: 70,
            width: MediaQuery.of(context).size.width / 2,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _getSocialReferencement(
                      iconUp: Icons.arrow_upward,
                      iconDown: Icons.arrow_downward,
                      title: points.toString()),
                  _getSocialAction(
                      icon: Icons.insert_comment_outlined,
                      title: widget.commentsCounts,
                      context: context),
                  _getFollowAction(context: context),
                ]),
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }

  Widget _getSocialReferencement(
      {required String title, IconData? iconUp, IconData? iconDown}) {
    return Container(
        height: 60.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    if (uid != widget.idUser) {
                      pointUpPost(widget.idPost);
                    }
                  },
                  child: Icon(iconUp,
                      size: 28,
                      color: widget.up!.contains(uid)
                          ? Colors.green
                          : Colors.grey[300]),
                ),
                SizedBox(
                  width: 10.0,
                ),
                InkWell(
                  onTap: () {
                    if (uid != widget.idUser) {
                      pointsDownPost(widget.idPost);
                    }
                  },
                  child: Icon(iconDown,
                      size: 28,
                      color: widget.down!.contains(uid)
                          ? Colors.red
                          : Colors.grey[300]),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 2.0),
              child: Text(title, style: TextStyle(fontSize: 12.0)),
            )
          ],
        ));
  }

  Widget _getSocialAction(
      {required String title, IconData? icon, BuildContext? context}) {
    return Container(
        height: 60.0,
        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          InkWell(
            onTap: () => showModalBottomSheet(
                backgroundColor: Theme.of(context!).scaffoldBackgroundColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                context: context,
                builder: (BuildContext context) {
                  return CommentsView(
                      idPost: widget.idPost, idUser: widget.idUser);
                }),
            child: Icon(icon, size: 28, color: Colors.grey[300]),
          ),
          Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Text(title,
                style: TextStyle(fontSize: 12.0, color: Colors.grey[300])),
          )
        ]));
  }

  Widget _getFollowAction({BuildContext? context}) {
    return Container(
        margin: EdgeInsets.only(top: 10.0),
        width: 55.0,
        height: 55.0,
        child: widget.idUser == uid
            ? Stack(
                children: [_getProfilePicture(context)],
              )
            : isFollowing
                ? Stack(
                    children: [_getProfilePicture(context)],
                  )
                : Stack(children: [
                    _getProfilePicture(context),
                    _getPlusIcon(context: context!)
                  ]));
  }

  Widget _getPlusIcon({required BuildContext context}) {
    return Positioned(
      bottom: 0,
      left: ((ActionWidgetSize / 2) - (PlusIconSize / 2)),
      child: GestureDetector(
        onTap: () => followUser(),
        child: Container(
            width: PlusIconSize, // PlusIconSize = 20.0;
            height: PlusIconSize, // PlusIconSize = 20.0;
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).accentColor
                    ]),
                borderRadius: BorderRadius.circular(15.0)),
            child: Icon(
              Icons.add,
              color: Colors.black,
              size: 20.0,
            )),
      ),
    );
  }

  Widget _getProfilePicture(BuildContext? context) {
    return Positioned(
      left: (ActionWidgetSize / 2) - (ProfileImageSize / 2),
      child: GestureDetector(
          onTap: () => Navigator.push(
              context!,
              MaterialPageRoute(
                  builder: (context) => ProfileView(
                        idUser: widget.idUser,
                      ))),
          child: widget.profilPicture == null
              ? Container(
                  width: ProfileImageSize,
                  height: ProfileImageSize,
                  decoration: BoxDecoration(
                    color: Colors.white60,
                    shape: BoxShape.circle,
                    border: Border.all(color: Color(0xFF222831)),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 23,
                    color: Colors.black,
                  ))
              : Container(
                  width: ProfileImageSize,
                  height: ProfileImageSize,
                  decoration: BoxDecoration(
                      color: Colors.white60,
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(0xFF222831)),
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(
                              widget.profilPicture))),
                )),
    );
  }
}
