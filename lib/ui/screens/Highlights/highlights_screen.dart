import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:Gemu/screensmodels/Highlights/highlights_screen_model.dart';
import 'package:Gemu/ui/widgets/clipper_appbar.dart';
import 'package:Gemu/size_config.dart';
import 'package:Gemu/models/categorie.dart';
import 'package:Gemu/ui/widgets/choix_tags_highlights.dart';
import 'package:Gemu/ui/widgets/choix_categories.dart';
import 'package:Gemu/models/categorie_post_model.dart';
import 'package:Gemu/models/data.dart';

class HighlightsScreen extends StatefulWidget {
  const HighlightsScreen({Key key}) : super(key: key);

  HighlightsScreenState createState() => HighlightsScreenState();
}

class HighlightsScreenState extends State<HighlightsScreen>
    with TickerProviderStateMixin {
  TabController _tabController;
  AnimationController _controllerRotate;
  Animation _animationRotate;
  bool padding = true;

  //List pour les tags, à changer dans le futur
  final List<CategoriePost> categorie = categoriePosts;

  double getRadianFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controllerRotate =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _animationRotate = Tween<double>(begin: 0.0, end: 180.0).animate(
        CurvedAnimation(parent: _controllerRotate, curve: Curves.easeOut));
    _controllerRotate.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return ViewModelBuilder<HighlightScreenModel>.reactive(
        viewModelBuilder: () => HighlightScreenModel(),
        builder: (context, model, child) => SlidingUpPanel(
              color: Colors.transparent,
              boxShadow: [BoxShadow(color: Colors.transparent)],
              slideDirection: SlideDirection.DOWN,
              panel: ClipPath(
                clipper: ClipperCustomAppBar(),
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).accentColor
                      ])),
                  child: Padding(
                    padding: padding
                        ? EdgeInsets.only(top: 60.0, bottom: 100.0)
                        : EdgeInsets.only(top: 60.0, bottom: 50.0),
                    child: CustomScrollView(
                      slivers: [
                        SliverPersistentHeader(
                            delegate: _SliverAppBarDelegate(
                          TabBar(
                              controller: _tabController,
                              onTap: (index) {
                                setState(() {
                                  _tabController.index = index;
                                });
                              },
                              labelColor: Theme.of(context).primaryColor,
                              unselectedLabelColor: Colors.grey,
                              isScrollable: true,
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicator: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Theme.of(context).canvasColor),
                              tabs: [
                                Tab(
                                  text: 'Tags',
                                ),
                                Tab(
                                  text: 'Catégories',
                                ),
                              ]),
                        )),
                        SliverToBoxAdapter(
                          child: Container(
                            margin: EdgeInsets.only(top: 10.0),
                            height: MediaQuery.of(context).size.height - 60,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: GridView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: categorie.length,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              childAspectRatio: 2,
                                              crossAxisSpacing: 3),
                                      itemBuilder: (context, index) {
                                        return ChoixTags(
                                          tag: categorie[index],
                                        );
                                      }),
                                ),
                                Align(
                                    alignment: Alignment.topCenter,
                                    child: FutureBuilder(
                                        future: FirebaseFirestore.instance
                                            .collection('categories')
                                            .get(),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return CircularProgressIndicator();
                                          }
                                          return GridView.builder(
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemCount:
                                                  snapshot.data.docs.length,
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 3,
                                                      childAspectRatio: 2,
                                                      crossAxisSpacing: 3),
                                              itemBuilder: (context, index) {
                                                DocumentSnapshot categorie =
                                                    snapshot.data.docs[index];
                                                return ChoixCategories(
                                                    categorie: categorie);
                                              });
                                        }))
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
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
                    bottom: 5.0,
                    left: SizeConfig.screenWidth / 2.25,
                  ),
                  child: Transform(
                      transform: Matrix4.rotationZ(
                          getRadianFromDegree(_animationRotate.value)),
                      alignment: Alignment.center,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black),
                        ),
                        child: Icon(
                          Icons.expand_more,
                          size: 35,
                          color: Colors.black,
                        ),
                      ))),
              footer: Padding(
                padding: EdgeInsets.only(top: 35.0, left: 20.0),
                child: Text(
                  'Que veux-tu voir dans tes highlights aujourd\'hui?',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
              body: Center(
                child: Container(
                  margin: EdgeInsets.only(top: 25.0),
                  child: Text("Create your custom feed"),
                ),
              ),
            ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controllerRotate.dispose();
    super.dispose();
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 5),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
