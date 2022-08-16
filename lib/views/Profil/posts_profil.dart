import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/models/user.dart';
import 'package:gemu/models/post.dart';
import 'package:gemu/components/post_tile.dart';

class PostsPublicProfile extends StatefulWidget {
  final UserModel user;

  PostsPublicProfile({required this.user});

  @override
  _PostsPublicProfileState createState() => _PostsPublicProfileState();
}

class _PostsPublicProfileState extends State<PostsPublicProfile>
    with AutomaticKeepAliveClientMixin {
  bool _loadingPosts = false;

  List<Post> posts = [];

  Future<void> getPostsPublic() async {
    QuerySnapshot<Map<String, dynamic>> dataPosts = await FirebaseFirestore
        .instance
        .collection('posts')
        .where('uid', isEqualTo: widget.user.uid)
        .where('privacy', isEqualTo: "Public")
        .orderBy('date', descending: true)
        .get();

    for (var item in dataPosts.docs) {
      DocumentSnapshot<Map<String, dynamic>> dataUser = await FirebaseFirestore
          .instance
          .collection("users")
          .doc(item.data()["uid"])
          .get();
      DocumentSnapshot<Map<String, dynamic>> dataGame = await FirebaseFirestore
          .instance
          .collection("games")
          .doc("verified")
          .collection("games_verified")
          .doc(item.data()["idGame"])
          .get();
      posts.add(
          Post.fromMap(item, item.data(), dataUser.data()!, dataGame.data()!));
    }

    if (mounted) {
      setState(() {
        _loadingPosts = true;
      });
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    getPostsPublic();
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
        child: _loadingPosts
            ? posts.length == 0
                ? Center(
                    child: Text(
                      'Pas encore de publications publiques',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  )
                : GridView.builder(
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
                    })
            : Center(
                child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: 1.0,
              )));
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
              splashColor: Theme.of(context).colorScheme.primary,
            ),
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
                image: CachedNetworkImageProvider(post.previewPictureUrl),
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
              splashColor: Theme.of(context).colorScheme.primary,
            ),
            Positioned(
                top: 5.0,
                left: 5.0,
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                )),
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
  bool _loadingPosts = false;

  List<Post> posts = [];

  Future<void> getPostsPrivate() async {
    QuerySnapshot<Map<String, dynamic>> dataPosts = await FirebaseFirestore
        .instance
        .collection('posts')
        .where('uid', isEqualTo: widget.user.uid)
        .where('privacy', isEqualTo: 'Private')
        .orderBy('date', descending: true)
        .get();

    for (var item in dataPosts.docs) {
      DocumentSnapshot<Map<String, dynamic>> dataUser = await FirebaseFirestore
          .instance
          .collection("users")
          .doc(item.data()["uid"])
          .get();
      DocumentSnapshot<Map<String, dynamic>> dataGame = await FirebaseFirestore
          .instance
          .collection("games")
          .doc("verified")
          .collection("games_verified")
          .doc(item.data()["idGame"])
          .get();
      posts.add(
          Post.fromMap(item, item.data(), dataUser.data()!, dataGame.data()!));
    }

    if (mounted) {
      setState(() {
        _loadingPosts = true;
      });
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    getPostsPrivate();
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
        child: _loadingPosts
            ? posts.length == 0
                ? Center(
                    child: Text(
                      'Pas encore de publications privées',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  )
                : GridView.builder(
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
                    })
            : Center(
                child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: 1.0,
              )));
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
              splashColor: Theme.of(context).colorScheme.primary,
            ),
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
                image: CachedNetworkImageProvider(post.previewPictureUrl),
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
              splashColor: Theme.of(context).colorScheme.primary,
            ),
            Positioned(
                top: 5.0,
                left: 5.0,
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                )),
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
              style: Theme.of(context).textTheme.bodySmall,
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
