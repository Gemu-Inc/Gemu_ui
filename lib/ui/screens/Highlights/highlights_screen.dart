import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/ui/widgets/bouncing_button.dart';
import 'package:gemu/models/hashtag.dart';
import 'package:gemu/models/post.dart';
import 'package:gemu/ui/screens/Highlights/discover_screen.dart';

import '../Search/search_screen.dart';
import 'highlights_posts_view.dart';

class HighlightsScreen extends StatefulWidget {
  final String uid;

  const HighlightsScreen({Key? key, required this.uid}) : super(key: key);

  HighlightsScreenState createState() => HighlightsScreenState();
}

class HighlightsScreenState extends State<HighlightsScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late TabController _tabController;
  int currentTabIndex = 0;

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        currentTabIndex = _tabController.index;
      });
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(initialIndex: currentTabIndex, length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void deactivate() {
    _tabController.removeListener(_onTabChanged);
    super.deactivate();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double getRadianFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'Highlights',
                style: mystyle(20),
              ),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          search(),
          SizedBox(
            height: 20.0,
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).canvasColor,
                    boxShadow: [
                      BoxShadow(
                          color: Theme.of(context).shadowColor,
                          blurRadius: 3,
                          spreadRadius: 3)
                    ]),
                tabs: [
                  Tab(
                    text: 'Référencements',
                  ),
                  Tab(
                    text: 'Discover',
                  )
                ]),
          ),
          SizedBox(
            height: 10.0,
          ),
          Expanded(child: tabBarView())
        ],
      ),
    );
  }

  Widget search() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: BouncingButton(
        content: Row(
          children: [
            SizedBox(width: 15.0),
            Icon(
              Icons.search,
              size: 23.0,
            ),
            SizedBox(
              width: 15.0,
            ),
            Text(
              'Recherche user, game, hashtag',
              style: mystyle(15),
            )
          ],
        ),
        height: 45,
        width: MediaQuery.of(context).size.width,
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SearchScreen()));
        },
      ),
    );
  }

  Widget tabBarView() {
    return TabBarView(
        controller: _tabController,
        physics: NeverScrollableScrollPhysics(),
        children: [referencements(), discover()]);
  }

  Widget referencements() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('hashtags')
              .orderBy('postsCount', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              );
            }
            if (snapshot.data.docs.length == 0) {
              return Center(
                child: Text(
                  'Pas encore d\'hashtags',
                  style: mystyle(15),
                ),
              );
            }
            return GridView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data.docs.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 3,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6),
                itemBuilder: (BuildContext context, int index) {
                  Hashtag hashtag = Hashtag.fromMap(snapshot.data.docs[index],
                      snapshot.data.docs[index].data());
                  return Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width / 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Theme.of(context).primaryColor,
                                          Theme.of(context).accentColor
                                        ]),
                                    shape: BoxShape.circle),
                                child: Icon(Icons.tag),
                              ),
                              SizedBox(
                                height: 2.0,
                              ),
                              Text(hashtag.name),
                              Text(
                                  '${hashtag.postsCount.toString()} publications')
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                          child: PostsByHashtags(
                        hashtag: hashtag,
                      ))
                    ],
                  );
                });
          }),
    );
  }

  Widget discover() {
    return DiscoverScreen();
  }
}

class PostsByHashtags extends StatefulWidget {
  final Hashtag hashtag;

  PostsByHashtags({required this.hashtag});

  @override
  PostsByHashtagsState createState() => PostsByHashtagsState();
}

class PostsByHashtagsState extends State<PostsByHashtags>
    with AutomaticKeepAliveClientMixin {
  bool dataIsThere = false;

  late Hashtag hashtag;

  late StreamSubscription postsHahstags;
  List<Post> posts = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    hashtag = widget.hashtag;

    postsHahstags =
        hashtag.reference!.collection('posts').snapshots().listen((data) async {
      if (posts.length != 0) {
        posts.clear();
      }
      for (var item in data.docs) {
        try {
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(item.id)
              .get()
              .then((value) => posts.add(Post.fromMap(value, value.data()!)));
        } catch (e) {
          print(e);
        }
      }

      if (!dataIsThere) {
        setState(() {
          dataIsThere = true;
        });
      }
    });
  }

  @override
  void dispose() {
    posts.clear();
    postsHahstags.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      height: 150,
      child: dataIsThere
          ? ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: posts.length,
              itemBuilder: (context, index) {
                Post post = posts[index];
                return post.type == 'picture'
                    ? picture(hashtag, index, post, posts)
                    : video(hashtag, index, post, posts);
              })
          : Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
    );
  }

  Widget picture(
    Hashtag hashtag,
    int indexPost,
    Post post,
    List<Post> posts,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HashtagPostsView(
                      hashtag: hashtag,
                      index: indexPost,
                      posts: posts,
                    )));
      },
      child: Container(
        margin: EdgeInsets.all(5.0),
        width: 100,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).accentColor
                ]),
            borderRadius: BorderRadius.circular(10.0),
            image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(post.postUrl))),
      ),
    );
  }

  Widget video(Hashtag hashtag, int indexPost, Post post, List<Post> posts) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => HashtagPostsView(
                      hashtag: hashtag,
                      index: indexPost,
                      posts: posts,
                    )));
      },
      child: Container(
        margin: EdgeInsets.all(5.0),
        width: 100,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).accentColor
                ]),
            borderRadius: BorderRadius.circular(10.0),
            image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(post.previewImage!))),
        child: Align(
          alignment: Alignment.topRight,
          child: Icon(
            Icons.play_arrow,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
