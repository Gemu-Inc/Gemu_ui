import 'package:Gemu/screensmodels/Home/home_screen_model.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Gemu/ui/widgets/top_toolbar.dart';
import 'package:Gemu/ui/widgets/actions_postbar.dart';
import 'package:Gemu/ui/widgets/content_postdescription.dart';
import 'package:Gemu/models/game.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  TabController _tabController;
  PageController _pageFollowingController, _pageGamesController;
  int currentTabIndex,
      currentTabGamesIndex,
      currentPageFollowingIndex,
      currentPageGamesIndex;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(initialIndex: 1, length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    currentTabIndex = 1;
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

  Widget get followingContainer => Container(
      height: 100.0,
      width: 225.0,
      margin: EdgeInsets.only(top: 5.0),
      child: Align(
        alignment: Alignment.topCenter,
        child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.transparent,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
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
            Container(
              decoration: BoxDecoration(color: Colors.black),
            ),
            Positioned(left: 0, bottom: 75, child: ContentPostDescription()),
            Positioned(
                right: 0,
                bottom: MediaQuery.of(context).size.height / 5,
                child: ActionsPostBar())
          ]));

  @override
  Widget build(BuildContext context) {
    List<Game> gamesList = Provider.of<List<Game>>(context);
    return ViewModelBuilder<HomeScreenModel>.reactive(
      disposeViewModel: false,
      viewModelBuilder: () => HomeScreenModel(),
      //onModelReady: (model) => model.listenToPosts(),
      builder: (context, model, child) => Stack(
        children: <Widget>[
          TabBarView(controller: _tabController, children: [
            middleSectionFollowing, //Following
            gamesList != null
                ? DefaultTabController(
                    initialIndex: currentTabGamesIndex,
                    length: gamesList.length,
                    child: Stack(children: [
                      TabBarView(
                          physics: NeverScrollableScrollPhysics(),
                          children: gamesList.map((game) {
                            return PageView.builder(
                                controller: _pageGamesController,
                                scrollDirection: Axis.vertical,
                                onPageChanged: (index) => setState(() {
                                      currentPageGamesIndex = index;
                                      print(
                                          'currentPageGamesIndex est à: $currentPageGamesIndex');
                                    }),
                                itemCount: 6,
                                itemBuilder: (context, index) =>
                                    Stack(children: [
                                      Container(
                                          decoration: BoxDecoration(
                                              color: Colors.black)),
                                      Positioned(
                                          left: 0,
                                          bottom: 75,
                                          child: ContentPostDescription()),
                                      Positioned(
                                          right: 0,
                                          bottom: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              5,
                                          child: ActionsPostBar())
                                    ]));
                          }).toList()),
                      currentPageGamesIndex == 0
                          ? Positioned(
                              top: MediaQuery.of(context).size.height / 5,
                              child: Container(
                                  height:
                                      MediaQuery.of(context).size.height / 9,
                                  width: MediaQuery.of(context).size.width,
                                  child: Center(
                                    child: TabBar(
                                        indicatorColor: Colors.transparent,
                                        labelColor:
                                            Theme.of(context).primaryColor,
                                        unselectedLabelColor: Colors.grey,
                                        isScrollable: true,
                                        onTap: (index) {
                                          setState(() {
                                            currentTabGamesIndex = index;
                                            print(currentTabGamesIndex);
                                          });
                                        },
                                        tabs: gamesList.map((game) {
                                          return Column(
                                            children: [
                                              Container(
                                                height: 50,
                                                width: 50,
                                                decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                        colors: [
                                                          Theme.of(context)
                                                              .primaryColor,
                                                          Theme.of(context)
                                                              .accentColor
                                                        ]),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    border: Border.all(
                                                        color:
                                                            Color(0xFF222831)),
                                                    image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image:
                                                            CachedNetworkImageProvider(
                                                                game.imageUrl))),
                                              ),
                                              SizedBox(
                                                height: 5.0,
                                              ),
                                              Text(
                                                '${game.name}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                ),
                                              )
                                            ],
                                          );
                                        }).toList()),
                                  )))
                          : SizedBox(),
                    ]))
                : Center(
                    child: CircularProgressIndicator(),
                  )
          ]),
          Column(
            children: [
              TopToolBarHome(
                  model: model,
                  gradient1: Colors.transparent,
                  gradient2: Colors.transparent,
                  elevationBar: 0,
                  currentPageGamesIndex: currentPageGamesIndex,
                  currentTabGamesIndex: currentTabGamesIndex,
                  currentTabIndex: currentTabIndex,
                  game: gamesList),
              followingContainer
            ],
          ),
        ],
      ),
    );
  }
}
