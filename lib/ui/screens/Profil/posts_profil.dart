import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/models/user.dart';
import 'package:gemu/models/post.dart';
import 'package:gemu/ui/widgets/post_tile.dart';

class PostsPublic extends StatefulWidget {
  final UserModel user;

  PostsPublic({required this.user});

  @override
  PostsPublicState createState() => PostsPublicState();
}

class PostsPublicState extends State<PostsPublic>
    with AutomaticKeepAliveClientMixin {
  List<Post> posts = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('posts')
            .where('uid', isEqualTo: widget.user.uid)
            .where('privacy', isEqualTo: "Public")
            .orderBy('date', descending: true)
            .get(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ));
          }
          if (snapshot.data!.docs.length == 0) {
            return Center(
              child: Text(
                'Pas encore de publications publiques',
                style: mystyle(11),
              ),
            );
          }
          if (posts.length != 0) {
            posts.clear();
          }
          for (var item in snapshot.data!.docs) {
            posts.add(Post.fromMap(item, item.data()));
          }
          return GridView.builder(
              scrollDirection: Axis.vertical,
              physics: AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              shrinkWrap: true,
              itemCount: posts.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6),
              itemBuilder: (BuildContext context, int index) {
                return posts[index].type == 'picture'
                    ? GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PostsView(
                                      postIndex: index,
                                      actualUser: me!,
                                      posts: posts,
                                    ))),
                        child: Container(
                          height: 150,
                          width: 150,
                          child: Stack(
                            children: [
                              Container(
                                height: 150,
                                width: 150,
                                child: CachedNetworkImage(
                                    imageUrl: posts[index].postUrl,
                                    fit: BoxFit.cover),
                              ),
                              Container(
                                color: Colors.black.withOpacity(0.2),
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
                                    Text(posts[index].viewcount.toString()),
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
                                builder: (context) => PostsView(
                                      postIndex: index,
                                      actualUser: me!,
                                      posts: posts,
                                    ))),
                        child: Container(
                          height: 150,
                          width: 150,
                          child: Stack(
                            children: [
                              Container(
                                height: 150,
                                width: 150,
                                child: CachedNetworkImage(
                                  imageUrl: posts[index].previewImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Container(
                                color: Colors.black.withOpacity(0.2),
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
                                    Text(posts[index].viewcount.toString()),
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
  final UserModel user;

  PostsPrivate({required this.user});

  @override
  PostsPrivateState createState() => PostsPrivateState();
}

class PostsPrivateState extends State<PostsPrivate>
    with AutomaticKeepAliveClientMixin {
  List<Post> posts = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('posts')
            .where('uid', isEqualTo: me!.uid)
            .where('privacy', isEqualTo: 'Private')
            .orderBy('date', descending: true)
            .get(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          }
          if (snapshot.data!.docs.length == 0) {
            return Center(
              child: Text(
                'Pas encore de publications privées',
                style: mystyle(11),
              ),
            );
          }
          if (posts.length != 0) {
            posts.clear();
          }
          for (var item in snapshot.data!.docs) {
            posts.add(Post.fromMap(item, item.data()));
          }
          return GridView.builder(
              scrollDirection: Axis.vertical,
              physics: AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              shrinkWrap: true,
              itemCount: posts.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1),
              itemBuilder: (BuildContext context, int index) {
                return posts[index].type == 'picture'
                    ? GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PostsView(
                                      postIndex: index,
                                      actualUser: me!,
                                      posts: posts,
                                    ))),
                        child: Stack(
                          children: [
                            Container(
                              child: CachedNetworkImage(
                                imageUrl: posts[index].postUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              color: Colors.black.withOpacity(0.2),
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
                                  Text(posts[index].viewcount.toString()),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PostsView(
                                      postIndex: index,
                                      actualUser: me!,
                                      posts: posts,
                                    ))),
                        child: Stack(
                          children: [
                            Container(
                              child: CachedNetworkImage(
                                imageUrl: posts[index].previewImage!,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              color: Colors.black.withOpacity(0.2),
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
                                  Text(posts[index].viewcount.toString()),
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
                      );
              });
        });
  }
}

class PostsView extends StatefulWidget {
  final int postIndex;
  final UserModel actualUser;
  final List<Post> posts;

  PostsView({
    required this.postIndex,
    required this.actualUser,
    required this.posts,
  });

  @override
  PostsViewState createState() => PostsViewState();
}

class PostsViewState extends State<PostsView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.postIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      left: false,
      right: false,
      child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.expand_more,
                  size: 33,
                )),
            title: Text('Mes posts'),
          ),
          body: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: widget.posts.length,
              itemBuilder: (_, int index) {
                return PostTile(
                  idUserActual: widget.actualUser.uid,
                  post: widget.posts[index],
                );
              })),
    );
  }
}
