import 'package:Gemu/constants/variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:Gemu/screensmodels/Highlights/highlights_screen_model.dart';
import 'package:Gemu/ui/widgets/clipper_appbar.dart';
import 'package:Gemu/size_config.dart';
import 'package:Gemu/ui/widgets/choix_categories.dart';

import 'search_screen.dart';

class HighlightsScreen extends StatefulWidget {
  const HighlightsScreen({Key key}) : super(key: key);

  HighlightsScreenState createState() => HighlightsScreenState();
}

class HighlightsScreenState extends State<HighlightsScreen>
    with TickerProviderStateMixin {
  AnimationController _controllerRotate;
  PanelController _panelController;
  Animation _animationRotate;
  bool padding = true;

  List tagsRecommended = [];
  List tags = [];
  bool dataIsThere = false;

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
    var documents =
        await FirebaseFirestore.instance.collection('categories').get();
    for (var item in documents.docs) {
      tags.add(item.data()['name']);
      tagsRecommended.add(item.data()['name']);
    }
    print(tags);
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
    SizeConfig().init(context);
    return dataIsThere
        ? ViewModelBuilder<HighlightScreenModel>.reactive(
            viewModelBuilder: () => HighlightScreenModel(),
            builder: (context, model, child) => SlidingUpPanel(
                minHeight: 70,
                controller: _panelController,
                color: Colors.transparent,
                boxShadow: [BoxShadow(color: Colors.transparent)],
                slideDirection: SlideDirection.DOWN,
                backdropTapClosesPanel: true,
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
                            child: CustomScrollView(
                              slivers: [
                                SliverToBoxAdapter(
                                  child: Container(
                                      margin: EdgeInsets.only(top: 10.0),
                                      height:
                                          MediaQuery.of(context).size.height -
                                              60,
                                      child: Align(
                                          alignment: Alignment.topCenter,
                                          child: GridView.builder(
                                              physics:
                                                  NeverScrollableScrollPhysics(),
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
                                )
                              ],
                            ),
                          ),
                        ],
                      )),
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
                body: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(top: 85, bottom: 85),
                    child: Column(
                      children: [
                        search(),
                        SizedBox(
                          height: 20.0,
                        ),
                        popular(context),
                        SizedBox(
                          height: 20.0,
                        ),
                        recommended()
                      ],
                    ),
                  ),
                )))
        : Center(child: CircularProgressIndicator());
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

  Widget popular(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text('Popular', style: mystyle(15)),
        ),
        SizedBox(
          height: 10.0,
        ),
        CarouselSlider.builder(
          itemCount: 3,
          itemBuilder: (context, index, realIndex) {
            return Container(
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
            );
          },
          options: CarouselOptions(
              aspectRatio: 2.0, enlargeCenterPage: true, viewportFraction: 0.8),
        )
      ],
    );
  }

  Widget recommended() {
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text('Recommended', style: mystyle(15)),
        ),
        SizedBox(
          height: 10.0,
        ),
        GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: tagsRecommended.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 3,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6),
            itemBuilder: (BuildContext context, int index) {
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
                        Text(tagsRecommended[index].toString())
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  Container(
                    height: 150,
                    width: MediaQuery.of(context).size.width / 1.50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: 15,
                      itemBuilder: (BuildContext contex, int index) {
                        return Container(
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
                              borderRadius: BorderRadius.circular(10.0)),
                        );
                      },
                    ),
                  ),
                ],
              );
            })
      ],
    );
  }
}
