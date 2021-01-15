import 'package:Gemu/screensmodels/Home/home_screen_model.dart';
import 'package:Gemu/ui/widgets/app_bar_animate.dart';
import 'package:Gemu/models/data.dart';
import 'package:Gemu/models/fil_model.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:Gemu/ui/widgets/post_item.dart';
import 'package:Gemu/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Gemu/ui/widgets/top_toolbar.dart';
import 'package:Gemu/ui/widgets/actions_postbar.dart';
import 'package:Gemu/ui/widgets/content_postdescription.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  TabController _tabController, _tabGamesController;
  PageController _pageFollowingController, _pageGamesController;
  int currentTabIndex,
      currentTabGamesIndex,
      currentPageFollowingIndex,
      currentPageGamesIndex;

  final List<Fil> fil = panelFil;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(initialIndex: 1, length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    currentTabIndex = 1;

    _tabGamesController = TabController(length: fil.length, vsync: this);
    _tabGamesController.addListener(_onTabGamesChanged);
    currentTabGamesIndex = 0;

    _pageFollowingController = PageController();
    currentPageFollowingIndex = 0;

    _pageGamesController = PageController();
    currentPageGamesIndex = 0;
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging)
      setState(() {
        print('Changing to Tab: ${_tabController.index}');
        currentTabIndex = _tabController.index;
        currentPageGamesIndex = 0;
      });
  }

  void _onTabGamesChanged() {
    if (!_tabGamesController.indexIsChanging)
      setState(() {
        print('Changing to Tab: ${_tabGamesController.index}');
        currentTabGamesIndex = _tabGamesController.index;
        currentPageGamesIndex = 0;
      });
  }

  Widget get followingContainer => Container(
      height: 100.0,
      //color: Colors.pink,
      width: 225.0,
      margin: EdgeInsets.only(top: 5.0),
      child: Align(
        alignment: Alignment.topCenter,
        child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.transparent,
            tabs: [
              Tab(
                child: currentTabIndex == 0
                    ? Text('Following',
                        style: TextStyle(
                            fontSize: 17.0, fontWeight: FontWeight.bold))
                    : Text(
                        'Following',
                        style: TextStyle(color: Colors.grey),
                      ),
              ),
              Tab(
                child: currentTabIndex == 1
                    ? Text('Games',
                        style: TextStyle(
                            fontSize: 17.0, fontWeight: FontWeight.bold))
                    : Text(
                        'Games',
                        style: TextStyle(color: Colors.grey),
                      ),
              ),
            ]),
      ));

  Widget get middleSectionFollowing => PageView.builder(
      controller: _pageFollowingController,
      scrollDirection: Axis.vertical,
      onPageChanged: (index) => setState(() {
            currentPageFollowingIndex = index;
          }),
      itemCount: 6,
      itemBuilder: (context, index) => Stack(children: [
            /*Center(
                child: Container(
              color: Colors.pink,
            )),*/
            Positioned(left: 0, bottom: 75, child: ContentPostDescription()),
            Positioned(
                right: 0,
                bottom: MediaQuery.of(context).size.height / 5,
                child: ActionsPostBar())
          ]));

  Widget get panelGames => Positioned(
      top: MediaQuery.of(context).size.height / 5,
      child: Container(
          height: MediaQuery.of(context).size.height / 9,
          width: MediaQuery.of(context).size.width,
          child: currentPageGamesIndex == 0
              ? TabBar(
                  controller: _tabGamesController,
                  indicatorColor: Colors.transparent,
                  isScrollable: true,
                  tabs: fil
                      .map((e) => Column(
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
                                    borderRadius: BorderRadius.circular(10.0),
                                    border:
                                        Border.all(color: Color(0xFF222831)),
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: AssetImage(e.imageUrl))),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              Text(
                                '${e.nameFil}',
                                style: TextStyle(
                                  fontSize: 10,
                                ),
                              )
                            ],
                          ))
                      .toList())
              : SizedBox()));

  Widget get middleSectionGames => TabBarView(
      controller: _tabGamesController,
      children: fil
          .map((e) => PageView.builder(
              controller: _pageGamesController,
              scrollDirection: Axis.vertical,
              onPageChanged: (index) => setState(() {
                    currentPageGamesIndex = index;
                    print(
                        'currentPageGamesIndex est à: $currentPageGamesIndex');
                  }),
              itemCount: 6,
              itemBuilder: (context, index) => Stack(children: [
                    /*Container(
                      color: Colors.purple,
                    ),*/
                    Positioned(
                        left: 0, bottom: 75, child: ContentPostDescription()),
                    Positioned(
                        right: 0,
                        bottom: MediaQuery.of(context).size.height / 5,
                        child: ActionsPostBar())
                  ])))
          .toList());

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeScreenModel>.reactive(
      viewModelBuilder: () => HomeScreenModel(),
      //onModelReady: (model) => model.listenToPosts(),
      builder: (context, model, child) => Stack(
        children: <Widget>[
          TabBarView(
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              Container(
                  color: Colors.black,
                  child: middleSectionFollowing), //Following
              Container(
                  color: Colors.black,
                  child: Stack(
                    children: [middleSectionGames, panelGames],
                  )) //Games
            ],
          ),
          Column(
            children: [
              TopToolBar(
                model: model,
                fondBar: Colors.transparent,
                elevationBar: 0,
                currentPageGamesIndex: currentPageGamesIndex,
                currentTabGamesIndex: currentTabGamesIndex,
                fil: fil,
              ),
              followingContainer,
            ],
          ),
        ],
      ),
    );
  }
}
