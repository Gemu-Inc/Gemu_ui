import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:gemu/ui/constants/constants.dart';

import './posts_profil_screen.dart';

class PostsPublic extends StatefulWidget {
  final String uid;

  PostsPublic({required this.uid});

  @override
  PostsPublicState createState() => PostsPublicState();
}

class PostsPublicState extends State<PostsPublic>
    with AutomaticKeepAliveClientMixin {
  late String uid;

  @override
  void initState() {
    super.initState();
    uid = widget.uid;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('uid', isEqualTo: uid)
            .where('privacy', isEqualTo: "Public")
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ));
          }
          if (snapshot.data.docs.length == 0) {
            return Center(
              child: Text(
                'Pas encore de publications publiques',
                style: mystyle(11),
              ),
            );
          }
          return GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: snapshot.data.docs.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6),
              itemBuilder: (BuildContext context, int index) {
                DocumentSnapshot<Map<String, dynamic>> post =
                    snapshot.data.docs[index];
                return post.data()!['previewImage'] == null
                    ? GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PostsProfilScreen(
                                      userID: uid,
                                      indexPost: index,
                                    ))),
                        child: Container(
                          height: 150,
                          width: 150,
                          child: Stack(
                            children: [
                              Container(
                                height: 150,
                                width: 150,
                                child: Image(
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider(
                                        post.data()!['pictureUrl'])),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () =>
                                      print('Supprimer ma publication'),
                                  child: Icon(
                                    Icons.clear,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.remove_red_eye,
                                      color: Colors.white,
                                    ),
                                    Text(post.data()!['viewcount'].toString()),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PostsProfilScreen(
                                    userID: uid, indexPost: index))),
                        child: Container(
                          height: 150,
                          width: 150,
                          child: Stack(
                            children: [
                              Container(
                                height: 150,
                                width: 150,
                                child: Image(
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider(
                                        post.data()!['previewImage'])),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () =>
                                      print('Supprimer ma publication'),
                                  child: Icon(
                                    Icons.clear,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.remove_red_eye,
                                      color: Colors.white,
                                    ),
                                    Text(post.data()!['viewcount'].toString()),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
              });
        });
  }
}

class PostsPrivate extends StatefulWidget {
  final String uid;

  PostsPrivate({required this.uid});

  @override
  PostsPrivateState createState() => PostsPrivateState();
}

class PostsPrivateState extends State<PostsPrivate>
    with AutomaticKeepAliveClientMixin {
  late String uid;

  @override
  void initState() {
    super.initState();
    uid = widget.uid;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('uid', isEqualTo: uid)
            .where('privacy', isEqualTo: "Private")
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ));
          }
          if (snapshot.data.docs.length == 0) {
            return Center(
              child: Text('Pas de publications privées', style: mystyle(11)),
            );
          }
          return GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: snapshot.data.docs.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6),
              itemBuilder: (BuildContext context, int index) {
                DocumentSnapshot<Map<String, dynamic>> post =
                    snapshot.data.docs[index];
                return post.data()!['previewImage'] == null
                    ? GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PostsProfilScreen(userID: uid))),
                        child: Container(
                          height: 150,
                          width: 150,
                          child: Stack(
                            children: [
                              Container(
                                height: 150,
                                width: 150,
                                child: Image(
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider(
                                        post.data()!['pictureUrl'])),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () =>
                                      print('Supprimer ma publication'),
                                  child: Icon(
                                    Icons.clear,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PostsProfilScreen(userID: uid))),
                        child: Container(
                          height: 150,
                          width: 150,
                          child: Stack(
                            children: [
                              Container(
                                height: 150,
                                width: 150,
                                child: Image(
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider(
                                        post.data()!['previewImage'])),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () =>
                                      print('Supprimer ma publication'),
                                  child: Icon(
                                    Icons.clear,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
              });
        });
  }
}
