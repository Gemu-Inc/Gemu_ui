import 'package:Gemu/ui/widgets/choix_categories.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/ui/widgets/widgets.dart';
import 'package:Gemu/models/categorie.dart';
import 'package:Gemu/locator.dart';
import 'package:Gemu/services/firestore_service.dart';
import 'package:Gemu/screensmodels/Highlights/highlights_screen_model.dart';
import 'package:Gemu/models/user.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

class AppBarAnimate extends StatefulWidget {
  final HighlightScreenModel model;

  AppBarAnimate({Key key, @required this.model}) : super(key: key);

  @override
  _AppBarAnimateState createState() => _AppBarAnimateState();
}

class _AppBarAnimateState extends State<AppBarAnimate>
    with TickerProviderStateMixin {
  TabController _tabController;
  AnimationController controllerRotate, controller;
  Animation animationRotate, animation;

  bool expanded = false;

  final FirestoreService _firestoreService = locator<FirestoreService>();

  double getRadianFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  bool _animateAppBar() {
    expanded ? controller.reverse() : controller.forward();
    expanded = !expanded;
    return expanded;
  }

  List<Categorie> _categories;
  List<Categorie> get categories => _categories;

  void listenToCategories() {
    _firestoreService.listenToCategoriesRealTime().listen((categoriesData) {
      List<Categorie> updatedCategories = categoriesData;
      if (updatedCategories != null && updatedCategories.length > 0) {
        _categories = updatedCategories;
      }
    });
  }

  @override
  void initState() {
    controllerRotate =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    animationRotate = Tween<double>(begin: 0.0, end: 180.0).animate(
        CurvedAnimation(parent: controllerRotate, curve: Curves.easeOut));
    controller = new AnimationController(
        duration: new Duration(milliseconds: 500), vsync: this);
    animation = new CurvedAnimation(parent: controller, curve: Curves.easeIn);
    _tabController = TabController(length: 2, vsync: this);
    listenToCategories();
    super.initState();
    controllerRotate.addListener(() {
      setState(() {});
    });
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controllerRotate.dispose();
    controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _sizeTween = new Tween<double>(
        begin: 150.0, end: (MediaQuery.of(context).size.height) - 60);
    return PreferredSize(
      preferredSize: new Size.fromHeight(_sizeTween.evaluate(animation)),
      child: Container(
        height: _sizeTween.evaluate(animation),
        child: GestureDetector(
            onTap: () {
              if (controllerRotate.isCompleted) {
                controllerRotate.reverse();
              } else {
                controllerRotate.forward();
              }
              _animateAppBar();
            },
            child: ClipPath(
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
                  child: expanded
                      ? NestedScrollView(
                          headerSliverBuilder:
                              (BuildContext context, bool innerBoxIsScrolled) {
                            return <Widget>[
                              SliverAppBar(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                leading: StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(FirebaseAuth
                                            .instance.currentUser.uid)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return snapshot.data['photoURL'] == null
                                            ? GestureDetector(
                                                onTap: () => widget.model
                                                    .navigateToProfil(),
                                                child: Container(
                                                  margin: EdgeInsets.all(3.0),
                                                  height: 50,
                                                  width: 50,
                                                  decoration: BoxDecoration(
                                                      color: Color(0xFF222831),
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                          color: Color(
                                                              0xFF222831))),
                                                  child: Icon(
                                                    Icons.person,
                                                    size: 40,
                                                  ),
                                                ),
                                              )
                                            : ProfilButtonHighlights(
                                                currentUser:
                                                    snapshot.data['photoURL'],
                                                width: 50,
                                                height: 50,
                                                colorFond: Colors.transparent,
                                                colorBorder: Color(0xFF222831),
                                                onPress: () => widget.model
                                                    .navigateToProfil());
                                      } else {
                                        return CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor: AlwaysStoppedAnimation(
                                              Theme.of(context).primaryColor),
                                        );
                                      }
                                    }),
                                title: Transform(
                                    transform: Matrix4.rotationZ(
                                        getRadianFromDegree(
                                            animationRotate.value)),
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
                                    )),
                                centerTitle: true,
                                actions: [
                                  Builder(
                                    builder: (context) => GestureDetector(
                                      onTap: () =>
                                          Scaffold.of(context).openEndDrawer(),
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            top: 7.5, bottom: 7.5, right: 5.0),
                                        height: 45,
                                        width: 45,
                                        decoration: BoxDecoration(
                                            color: Color(0xFF222831),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                                color: Color(0xFF222831))),
                                        child: Icon(Icons.bubble_chart_outlined,
                                            size: 28,
                                            color:
                                                Theme.of(context).accentColor),
                                      ),
                                    ),
                                  ),
                                ],
                                floating: true,
                                expandedHeight: 75.0,
                                forceElevated: innerBoxIsScrolled,
                              ),
                              SliverPadding(
                                  padding: EdgeInsets.only(top: 15.0)),
                              SliverToBoxAdapter(
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Text(
                                    'Que veux-tu voir dans tes highlights aujourd\'hui?',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              SliverPadding(
                                  padding: EdgeInsets.only(top: 15.0)),
                              SliverToBoxAdapter(
                                  child: Align(
                                alignment: Alignment.center,
                                child: TabBar(
                                    controller: _tabController,
                                    onTap: (index) {
                                      setState(() {
                                        _tabController.index = index;
                                      });
                                    },
                                    isScrollable: true,
                                    indicatorSize: TabBarIndicatorSize.tab,
                                    indicator: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Color(0xFF222831)),
                                    tabs: [
                                      Tab(
                                        text: 'Tags',
                                      ),
                                      Tab(
                                        text: 'Catégories',
                                      ),
                                    ]),
                              )),
                              SliverPadding(
                                  padding: EdgeInsets.only(top: 15.0)),
                            ];
                          },
                          body: SingleChildScrollView(
                            child: Container(
                              height: MediaQuery.of(context).size.height - 60,
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  ChoixTags(),
                                  Align(
                                    alignment: Alignment.topCenter,
                                    child: Wrap(
                                      direction: Axis.horizontal,
                                      children: categories.map((e) {
                                        return ChoixCategories(
                                          key: UniqueKey(),
                                          e: e,
                                        );
                                      }).toList(),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ))
                      : GradientAppBar(
                          elevation: 0,
                          gradient: LinearGradient(colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).accentColor
                          ]),
                          leading: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser.uid)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return snapshot.data['photoURL'] == null
                                      ? GestureDetector(
                                          onTap: () =>
                                              widget.model.navigateToProfil(),
                                          child: Container(
                                            margin: EdgeInsets.all(3.0),
                                            height: 50,
                                            width: 50,
                                            decoration: BoxDecoration(
                                                color: Color(0xFF222831),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Color(0xFF222831))),
                                            child: Icon(
                                              Icons.person,
                                              size: 40,
                                            ),
                                          ),
                                        )
                                      : ProfilButtonHighlights(
                                          currentUser:
                                              snapshot.data['photoURL'],
                                          width: 50,
                                          height: 50,
                                          colorFond: Colors.transparent,
                                          colorBorder: Color(0xFF222831),
                                          onPress: () =>
                                              widget.model.navigateToProfil());
                                } else {
                                  return CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation(
                                        Theme.of(context).primaryColor),
                                  );
                                }
                              }),
                          title: Transform(
                              transform: Matrix4.rotationZ(
                                  getRadianFromDegree(animationRotate.value)),
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
                              )),
                          centerTitle: true,
                          actions: [
                            Builder(
                              builder: (context) => GestureDetector(
                                onTap: () =>
                                    Scaffold.of(context).openEndDrawer(),
                                child: Container(
                                  margin: EdgeInsets.only(
                                      top: 7.5, bottom: 7.5, right: 5.0),
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                      color: Color(0xFF222831),
                                      borderRadius: BorderRadius.circular(15),
                                      border:
                                          Border.all(color: Color(0xFF222831))),
                                  child: Icon(Icons.bubble_chart_outlined,
                                      size: 28,
                                      color: Theme.of(context).accentColor),
                                ),
                              ),
                            ),
                          ],
                        )),
            )),
      ),
    );
  }
}
