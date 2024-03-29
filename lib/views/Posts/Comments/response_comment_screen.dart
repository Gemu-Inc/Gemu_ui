import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/models/commentaire.dart';
import 'package:gemu/components/snack_bar_custom.dart';
import 'package:gemu/services/database_service.dart';
import 'package:gemu/models/user.dart';
import 'package:gemu/helpers/helpers.dart';
import 'package:gemu/views/Profile/profile_user_screen.dart';
import 'package:gemu/models/response.dart';

class ResponseCommentScreen extends StatefulWidget {
  final Commentaire comment;
  final Response? response;
  final List upper, downer;

  const ResponseCommentScreen(
      {Key? key,
      required this.comment,
      this.response,
      required this.upper,
      required this.downer})
      : super(key: key);

  @override
  ResponseCommentviewstate createState() => ResponseCommentviewstate();
}

class ResponseCommentviewstate extends State<ResponseCommentScreen> {
  late TextEditingController _responseController;

  late FocusNode _focusNodeResponse;

  hideKeyboard() {
    if (_focusNodeResponse.hasFocus) {
      _focusNodeResponse.unfocus();
    }
  }

  publishResponse() async {
    int date = DateTime.now().millisecondsSinceEpoch.toInt();

    widget.comment.reference
        .collection('responses')
        .doc('Response${me!.uid}$date')
        .set({
      'uid': me!.uid,
      'response': _responseController.text,
      'upcount': 0,
      'downcount': 0,
      'date': date,
      'id': 'Response${me!.uid}$date'
    });

    widget.comment.reference
        .update({'responsescount': widget.comment.responsescount + 1});

    _responseController.clear();

    DatabaseService.addNotification(me!.uid, widget.comment.uid,
        "a ajouté une réponse à votre commentaire", "comment");

    hideKeyboard();
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _responseController = TextEditingController();
    _focusNodeResponse = FocusNode();
  }

  @override
  void dispose() {
    _responseController.dispose();
    _focusNodeResponse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 6,
        leading: IconButton(
            onPressed: () {
              hideKeyboard();
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios)),
        title: Text(
          'Réponse',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: comment(),
              ),
            ),
          ),
          Container(
            height: 50,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Theme.of(context).shadowColor,
                border: Border(
                    top: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        width: 0.1))),
            alignment: Alignment.center,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.0),
                child: Row(
                  children: [
                    me!.imageUrl == null
                        ? Container(
                            margin: EdgeInsets.all(3.0),
                            width: 40,
                            height: 40,
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
                            margin: EdgeInsets.all(3.0),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white60,
                              shape: BoxShape.circle,
                              border: Border.all(color: Color(0xFF222831)),
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: CachedNetworkImageProvider(
                                      me!.imageUrl!)),
                            )),
                    Expanded(
                        child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: TextFormField(
                        scrollPhysics: AlwaysScrollableScrollPhysics(),
                        controller: _responseController,
                        cursorColor: Theme.of(context).colorScheme.primary,
                        autofocus: true,
                        focusNode: _focusNodeResponse,
                        textInputAction: TextInputAction.go,
                        onFieldSubmitted: (value) {
                          value = _responseController.text;
                          if (value.isEmpty) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBarCustom(
                              context: context,
                              error: 'Response should not be empty',
                            ));
                          } else {
                            publishResponse();
                          }
                        },
                        decoration: InputDecoration(
                          hintText: "Ajouter une réponse...",
                          border: InputBorder.none,
                        ),
                      ),
                    )),
                    IconButton(
                        onPressed: () {
                          if (_responseController.text.isEmpty) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBarCustom(
                              context: context,
                              error: 'Response should not be empty',
                            ));
                          } else {
                            publishResponse();
                          }
                        },
                        icon: Icon(
                          Icons.send_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ))
                  ],
                )),
          )
        ],
      ),
    );
  }

  Widget comment() {
    return widget.response == null
        ? FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(widget.comment.uid)
                .get(),
            builder: (context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return SizedBox();
              }
              UserModel userComment =
                  UserModel.fromMap(snapshot.data, snapshot.data.data());
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
                    child: Container(
                        child: GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ProfileUser(userPostID: userComment.uid))),
                      child: userComment.imageUrl != null
                          ? Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).canvasColor,
                                  border: Border.all(color: Colors.black),
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: CachedNetworkImageProvider(
                                          userComment.imageUrl!),
                                      fit: BoxFit.cover)),
                            )
                          : Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(context).canvasColor,
                                border: Border.all(color: Colors.black),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.person, color: Colors.black),
                            ),
                    )),
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 25.0,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => ProfileUser(
                                          userPostID: userComment.uid))),
                              child: Text(
                                userComment.username,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            Text('-'),
                            SizedBox(
                              width: 5.0,
                            ),
                            Text(
                              Helpers.datePostView(widget.comment.date),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Text(widget.comment.comment,
                                  style: TextStyle(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white60
                                          : Colors.black87))),
                          Container(
                            width: 50,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.arrow_upward,
                                        color: widget.upper.contains(me!.uid)
                                            ? Colors.green[200]
                                            : Colors.grey,
                                        size: 17),
                                    SizedBox(
                                      width: 5.0,
                                    ),
                                    Icon(Icons.arrow_downward,
                                        color: widget.downer.contains(me!.uid)
                                            ? Colors.red
                                            : Colors.grey,
                                        size: 17),
                                  ],
                                ),
                                Text(
                                  (widget.upper.length - widget.downer.length)
                                      .toString(),
                                  style: Theme.of(context).textTheme.bodySmall,
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ))
                ],
              );
            })
        : FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(widget.response!.uid)
                .get(),
            builder: (context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return SizedBox();
              }
              UserModel userComment =
                  UserModel.fromMap(snapshot.data, snapshot.data.data());
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
                    child: Container(
                        child: GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ProfileUser(userPostID: userComment.uid))),
                      child: userComment.imageUrl != null
                          ? Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).canvasColor,
                                  border: Border.all(color: Colors.black),
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: CachedNetworkImageProvider(
                                          userComment.imageUrl!),
                                      fit: BoxFit.cover)),
                            )
                          : Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(context).canvasColor,
                                border: Border.all(color: Colors.black),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.person, color: Colors.black),
                            ),
                    )),
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 25.0,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => ProfileUser(
                                          userPostID: userComment.uid))),
                              child: Text(
                                userComment.username,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            Text('-'),
                            SizedBox(
                              width: 5.0,
                            ),
                            Text(
                              Helpers.datePostView(widget.response!.date),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Text(widget.response!.response,
                                  style: TextStyle(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white60
                                          : Colors.black87))),
                          Container(
                            width: 50,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.arrow_upward,
                                        color: widget.upper.contains(me!.uid)
                                            ? Colors.green[200]
                                            : Colors.grey,
                                        size: 17),
                                    SizedBox(
                                      width: 5.0,
                                    ),
                                    Icon(Icons.arrow_downward,
                                        color: widget.downer.contains(me!.uid)
                                            ? Colors.red
                                            : Colors.grey,
                                        size: 17),
                                  ],
                                ),
                                Text(
                                  (widget.upper.length - widget.downer.length)
                                      .toString(),
                                  style: Theme.of(context).textTheme.bodySmall,
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ))
                ],
              );
            });
  }
}

class ResponseTile extends StatefulWidget {
  final Commentaire comment;
  final Response response;

  const ResponseTile({Key? key, required this.response, required this.comment})
      : super(key: key);

  @override
  ResponseTileState createState() => ResponseTileState();
}

class ResponseTileState extends State<ResponseTile> {
  late StreamSubscription upListener, downListener;
  List upper = [];
  List downer = [];

  upResponse(Response response) {
    response.reference.collection('up').doc(me!.uid).get().then((upper) {
      if (!upper.exists) {
        upper.reference.set({});
        response.reference.update({'upcount': response.upcount + 1});
      }

      response.reference.collection('down').doc(me!.uid).get().then((downer) {
        if (downer.exists) {
          downer.reference.delete();
          response.reference.update({'downcount': response.downcount - 1});
        }
      });
    });

    DatabaseService.addNotification(
        me!.uid, widget.comment.uid, "a up votre réponse", "updown");
  }

  downResponse(Response response) {
    response.reference.collection('down').doc(me!.uid).get().then((downer) {
      if (!downer.exists) {
        downer.reference.set({});
        response.reference.update({'downcount': response.downcount + 1});
      }
    });

    response.reference.collection('up').doc(me!.uid).get().then((upper) {
      if (upper.exists) {
        upper.reference.delete();
        response.reference.update({'upcount': response.upcount - 1});
      }
    });

    DatabaseService.addNotification(
        me!.uid, widget.comment.uid, "a down votre réponse", "updown");
  }

  @override
  void initState() {
    super.initState();

    upListener =
        widget.response.reference.collection('up').snapshots().listen((data) {
      if (upper.length != 0) {
        upper.clear();
      }
      for (var item in data.docs) {
        setState(() {
          upper.add(item.id);
        });
      }
    });

    downListener =
        widget.response.reference.collection('down').snapshots().listen((data) {
      if (downer.length != 0) {
        downer.clear();
      }
      for (var item in data.docs) {
        downer.add(item.id);
      }
    });
  }

  @override
  void dispose() {
    upListener.cancel();
    downListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.response.uid)
            .get(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return SizedBox();
          }
          UserModel userComment =
              UserModel.fromMap(snapshot.data, snapshot.data.data());
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
                child: Container(
                    child: GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              ProfileUser(userPostID: userComment.uid))),
                  child: userComment.imageUrl != null
                      ? Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                              color: Theme.of(context).canvasColor,
                              border: Border.all(color: Colors.black),
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                      userComment.imageUrl!),
                                  fit: BoxFit.cover)),
                        )
                      : Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                            color: Theme.of(context).canvasColor,
                            border: Border.all(color: Colors.black),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.person, color: Colors.black),
                        ),
                )),
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 25.0,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ProfileUser(
                                      userPostID: userComment.uid))),
                          child: Text(
                            userComment.username,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Text('-'),
                        SizedBox(
                          width: 5.0,
                        ),
                        Text(
                          Helpers.datePostView(widget.response.date),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Text(widget.response.response,
                              style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white60
                                      : Colors.black87))),
                      Container(
                        width: 50,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () => upResponse(widget.response),
                                  child: Icon(Icons.arrow_upward,
                                      color: upper.contains(me!.uid)
                                          ? Colors.green[200]
                                          : Colors.grey,
                                      size: 17),
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                GestureDetector(
                                  onTap: () => downResponse(widget.response),
                                  child: Icon(Icons.arrow_downward,
                                      color: downer.contains(me!.uid)
                                          ? Colors.red
                                          : Colors.grey,
                                      size: 17),
                                )
                              ],
                            ),
                            Text(
                              (upper.length - downer.length).toString(),
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  Container(
                    height: 25,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => upResponse(widget.response),
                          child: Text(
                            'Up',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Text('-'),
                        SizedBox(
                          width: 5.0,
                        ),
                        GestureDetector(
                          onTap: () => downResponse(widget.response),
                          child: Text(
                            'Down',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Text('-'),
                        SizedBox(
                          width: 5.0,
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ResponseCommentScreen(
                                      comment: widget.comment,
                                      response: widget.response,
                                      upper: upper,
                                      downer: downer))),
                          child: Text(
                            'Répondre',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ))
            ],
          );
        });
  }
}
