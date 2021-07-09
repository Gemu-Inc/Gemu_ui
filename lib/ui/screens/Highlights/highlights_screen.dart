import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:gemu/ui/widgets/clipper_custom.dart';
import 'package:gemu/ui/constants/size_config.dart';
import 'package:gemu/ui/screens/Highlights/choix_categories.dart';
import 'package:gemu/ui/constants/constants.dart';

import 'search_screen.dart';
import 'hashtag_post_view.dart';
import 'spotlights_screen.dart';
import 'trendings_screen.dart';
import 'discover_screen.dart';

class HighlightsScreen extends StatefulWidget {
  final String uid;

  const HighlightsScreen({Key? key, required this.uid}) : super(key: key);

  HighlightsScreenState createState() => HighlightsScreenState();
}

class HighlightsScreenState extends State<HighlightsScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late AnimationController _controllerRotate;
  late PanelController _panelController;
  late Animation _animationRotate;
  bool padding = true;

  List tagsRecommended = [];
  List tags = [];
  bool dataIsThere = false;

  List carousselIcon = [Icons.light, Icons.trending_up, Icons.new_releases];
  List carousselTitle = ['Spotlights', 'Trendings', 'Discover'];
  List carousselDescription = [
    'Tous les nouveaux posts',
    'Les posts les plus populaires',
    'Les posts pouvant vous interesser'
  ];
  List carousselNavigation = [
    SpotlightsScreen(),
    TrendingsScreen(),
    DiscoverScreen()
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    getData();

    _panelController = PanelController();
    _controllerRotate =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _animationRotate = Tween<double>(begin: 0.0, end: 180.0).animate(
        CurvedAnimation(parent: _controllerRotate, curve: Curves.easeOut));
    _controllerRotate.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controllerRotate.dispose();
    super.dispose();
  }

  getData() async {
    var documents = await FirebaseFirestore.instance
        .collection('hashtags')
        .orderBy('postsCount', descending: true)
        .get();
    for (var item in documents.docs) {
      tags.add(item.data()['name']);
      tagsRecommended.add(item);
      print(tagsRecommended);
    }
    setState(() {
      dataIsThere = true;
    });
  }

  double getRadianFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    SizeConfig().init(context);
    return dataIsThere
        ? SlidingUpPanel(
            minHeight: 70,
            controller: _panelController,
            color: Colors.transparent,
            boxShadow: [BoxShadow(color: Colors.transparent)],
            slideDirection: SlideDirection.DOWN,
            backdropTapClosesPanel: true,
            panel: panel(),
            onPanelSlide: (value) {
              if (value == 0.0) {
                _controllerRotate.reverse();
                setState(() {
                  padding = true;
                });
              }
              if (value == 1.0) {
                _controllerRotate.forward();
                setState(() {
                  padding = false;
                });
              }
            },
            header: Padding(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width / 4 + 70.0),
              child: GestureDetector(
                onTap: () {
                  if (_controllerRotate.isCompleted) {
                    _panelController.close();
                    _controllerRotate.reverse();
                    setState(() {
                      padding = true;
                    });
                  } else {
                    _panelController.open();
                    _controllerRotate.forward();
                    setState(() {
                      padding = false;
                    });
                  }
                },
                child: Transform(
                  transform: Matrix4.rotationZ(
                      getRadianFromDegree(_animationRotate.value)),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.expand_more,
                    size: 35,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            body: Padding(
              padding: EdgeInsets.only(top: 85, bottom: 85),
              child: Column(
                children: [
                  search(),
                  SizedBox(
                    height: 40.0,
                  ),
                  slider(context),
                  SizedBox(
                    height: 30.0,
                  ),
                  Expanded(child: referencements())
                ],
              ),
            ),
          )
        : Center(child: CircularProgressIndicator());
  }

  Widget panel() {
    return ClipPath(
      clipper: ClipperCustom(),
      child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).accentColor
              ])),
          child: Stack(
            children: [
              SafeArea(
                child: Container(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        'Custom your highlights',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              ),
              Padding(
                  padding: padding
                      ? EdgeInsets.only(top: 60.0, bottom: 100.0)
                      : EdgeInsets.only(top: 60.0, bottom: 50.0),
                  child: Container(
                      height: MediaQuery.of(context).size.height - 60,
                      child: tags.length == 0
                          ? Center(
                              child:
                                  Text('Pas encore de customisation possible'),
                            )
                          : GridView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: tags.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      childAspectRatio: 2,
                                      crossAxisSpacing: 3),
                              itemBuilder: (context, index) {
                                return ChoixCategories(
                                  categorie: tags[index],
                                  tags: tagsRecommended,
                                );
                              }))),
            ],
          )),
    );
  }

  Widget search() {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => SearchScreen())),
      child: Container(
        margin: EdgeInsets.only(left: 10.0, right: 20.0),
        height: 35,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor,
                offset: Offset(-5.0, 5.0),
              )
            ]),
        child: Row(
          children: [
            SizedBox(width: 5.0),
            Icon(
              Icons.search,
              size: 20.0,
            ),
            SizedBox(
              width: 10.0,
            ),
            Text(
              'Rechercher',
              style: TextStyle(fontSize: 15.0),
            )
          ],
        ),
      ),
    );
  }

  Widget slider(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: 3,
      itemBuilder: (context, index, realIndex) {
        return GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => carousselNavigation[index])),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).accentColor
                  ]),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Stack(
              children: [
                Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 25.0),
                      child: Icon(
                        carousselIcon[index],
                        color: Colors.white,
                        size: 30,
                      ),
                    )),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 25.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            carousselTitle[index],
                            style: mystyle(15),
                          ),
                          Text(
                            carousselDescription[index],
                            style: mystyle(11),
                          )
                        ],
                      )),
                )
              ],
            ),
          ),
        );
      },
      options: CarouselOptions(
          aspectRatio: 2.2,
          enlargeCenterPage: true,
          viewportFraction: 0.8,
          autoPlay: true,
          autoPlayInterval: Duration(seconds: 6),
          autoPlayAnimationDuration: Duration(seconds: 2)),
    );
  }

  Widget referencements() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: Text('Référencements', style: mystyle(15)),
          ),
        ),
        tagsRecommended.length == 0
            ? Expanded(
                child: Container(
                child: Center(
                  child: Text('Pas encore de hashtags'),
                ),
              ))
            : Expanded(
                child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: tagsRecommended.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 3,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6),
                    itemBuilder: (BuildContext context, int index) {
                      DocumentSnapshot<Map<String, dynamic>> hashtag =
                          tagsRecommended[index];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
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
                                Text(hashtag.data()!['name']),
                                Text(
                                    '${hashtag.data()!['postsCount'].toString()} publications')
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          Container(
                            height: 150,
                            width: MediaQuery.of(context).size.width / 1.50,
                            child: StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('hashtags')
                                    .doc(hashtag.data()!['name'])
                                    .collection('posts')
                                    .orderBy('time', descending: true)
                                    .snapshots(),
                                builder: (context, AsyncSnapshot snapshot) {
                                  if (!snapshot.hasData) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  return ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemCount: snapshot.data.docs.length,
                                    itemBuilder:
                                        (BuildContext contex, int index) {
                                      DocumentSnapshot<Map<String, dynamic>>
                                          documentSnapshot =
                                          snapshot.data.docs[index];

                                      return documentSnapshot
                                                  .data()!['pictureUrl'] !=
                                              null
                                          ? picture(hashtag, index,
                                              documentSnapshot, snapshot)
                                          : video(hashtag, index,
                                              documentSnapshot, snapshot);
                                    },
                                  );
                                }),
                          ),
                        ],
                      );
                    }))
      ],
    );
  }

  Widget picture(
      DocumentSnapshot<Map<String, dynamic>> hashtag,
      int indexPost,
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot,
      AsyncSnapshot snapshot) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HashtagPostView(
                    hashtag: hashtag,
                    index: indexPost,
                    snapshot: snapshot,
                  ))),
      child: Container(
        margin: EdgeInsets.all(5.0),
        width: 100,
        decoration: BoxDecoration(
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
                image: CachedNetworkImageProvider(
                    documentSnapshot.data()!['pictureUrl']))),
      ),
    );
  }

  Widget video(
      DocumentSnapshot<Map<String, dynamic>> hashtag,
      int indexPost,
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot,
      AsyncSnapshot snapshot) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => HashtagPostView(
                    hashtag: hashtag,
                    index: indexPost,
                    snapshot: snapshot,
                  ))),
      child: Container(
        margin: EdgeInsets.all(5.0),
        width: 100,
        decoration: BoxDecoration(
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
                image: CachedNetworkImageProvider(
                    documentSnapshot.data()!['previewImage']))),
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
