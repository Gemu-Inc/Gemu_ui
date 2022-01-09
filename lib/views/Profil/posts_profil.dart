import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/models/user.dart';
import 'package:gemu/models/post.dart';
import 'package:gemu/views/Autres/post_tile.dart';

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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.0),
      child: FutureBuilder(
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
                    crossAxisSpacing: 1.0,
                    mainAxisSpacing: 1.0),
                itemBuilder: (BuildContext context, int index) {
                  Post post = posts[index];
                  return post.type == 'picture'
                      ? picture(post, index)
                      : video(post, index);
                });
          }),
    );
  }

  Widget picture(Post post, int index) {
    return Material(
      color: Theme.of(context).canvasColor,
      borderRadius: BorderRadius.circular(5.0),
      child: Ink(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(5.0),
            image: DecorationImage(
                image: CachedNetworkImageProvider(post.postUrl),
                fit: BoxFit.cover)),
        child: Stack(
          children: [
            Container(
              color: Colors.black.withOpacity(0.2),
            ),
            InkWell(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PostsView(
                            postIndex: index,
                            actualUser: widget.user,
                            posts: posts,
                          ))),
              borderRadius: BorderRadius.circular(5.0),
              splashColor: Theme.of(context).primaryColor,
            ),
            Positioned(
                bottom: 5.0,
                right: 5.0,
                child: Column(
                  children: [
                    Icon(Icons.remove_red_eye, color: Colors.white),
                    Text(post.viewcount.toString(),
                        style: mystyle(12, Colors.white))
                  ],
                ))
          ],
        ),
      ),
    );
  }

  Widget video(Post post, int index) {
    return Material(
      color: Theme.of(context).canvasColor,
      borderRadius: BorderRadius.circular(5.0),
      child: Ink(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(5.0),
            image: DecorationImage(
                image: CachedNetworkImageProvider(post.previewImage!),
                fit: BoxFit.cover)),
        child: Stack(
          children: [
            Container(
              color: Colors.black.withOpacity(0.2),
            ),
            InkWell(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PostsView(
                            postIndex: index,
                            actualUser: widget.user,
                            posts: posts,
                          ))),
              borderRadius: BorderRadius.circular(5.0),
              splashColor: Theme.of(context).primaryColor,
            ),
            Positioned(
                top: 5.0,
                left: 5.0,
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                )),
            Positioned(
                bottom: 5.0,
                right: 5.0,
                child: Column(
                  children: [
                    Icon(Icons.remove_red_eye, color: Colors.white),
                    Text(post.viewcount.toString(),
                        style: mystyle(12, Colors.white))
                  ],
                ))
          ],
        ),
      ),
    );
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.0),
      child: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('posts')
              .where('uid', isEqualTo: widget.user.uid)
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
                    crossAxisSpacing: 1.0,
                    mainAxisSpacing: 1.0),
                itemBuilder: (BuildContext context, int index) {
                  Post post = posts[index];
                  return post.type == 'picture'
                      ? picture(post, index)
                      : video(post, index);
                });
          }),
    );
  }

  Widget picture(Post post, int index) {
    return Material(
      color: Theme.of(context).canvasColor,
      borderRadius: BorderRadius.circular(5.0),
      child: Ink(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(5.0),
            image: DecorationImage(
                image: CachedNetworkImageProvider(post.postUrl),
                fit: BoxFit.cover)),
        child: Stack(
          children: [
            Container(
              color: Colors.black.withOpacity(0.2),
            ),
            InkWell(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PostsView(
                            postIndex: index,
                            actualUser: widget.user,
                            posts: posts,
                          ))),
              borderRadius: BorderRadius.circular(5.0),
              splashColor: Theme.of(context).primaryColor,
            ),
            Positioned(
                bottom: 5.0,
                right: 5.0,
                child: Column(
                  children: [
                    Icon(Icons.remove_red_eye, color: Colors.white),
                    Text(post.viewcount.toString(),
                        style: mystyle(12, Colors.white))
                  ],
                ))
          ],
        ),
      ),
    );
  }

  Widget video(Post post, int index) {
    return Material(
      color: Theme.of(context).canvasColor,
      borderRadius: BorderRadius.circular(5.0),
      child: Ink(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(5.0),
            image: DecorationImage(
                image: CachedNetworkImageProvider(post.previewImage!),
                fit: BoxFit.cover)),
        child: Stack(
          children: [
            Container(
              color: Colors.black.withOpacity(0.2),
            ),
            InkWell(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PostsView(
                            postIndex: index,
                            actualUser: widget.user,
                            posts: posts,
                          ))),
              borderRadius: BorderRadius.circular(5.0),
              splashColor: Theme.of(context).primaryColor,
            ),
            Positioned(
                top: 5.0,
                left: 5.0,
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                )),
            Positioned(
                bottom: 5.0,
                right: 5.0,
                child: Column(
                  children: [
                    Icon(Icons.remove_red_eye, color: Colors.white),
                    Text(post.viewcount.toString(),
                        style: mystyle(12, Colors.white))
                  ],
                ))
          ],
        ),
      ),
    );
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
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                )),
            title: Text(
              widget.actualUser.uid == me!.uid
                  ? 'Mes posts'
                  : '${widget.actualUser.username}\'s posts',
              style: mystyle(16, Colors.white),
            ),
          ),
          body: PageView.builder(
              controller: _pageController,
              physics: AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              scrollDirection: Axis.vertical,
              itemCount: widget.posts.length,
              itemBuilder: (_, int index) {
                return PostTile(
                  idUserActual: widget.actualUser.uid,
                  post: widget.posts[index],
                  positionDescriptionBar: 5.0,
                  positionActionsBar: 5.0,
                  isGameBar: true,
                  isFollowingsSection: false,
                );
              })),
    );
  }
}
