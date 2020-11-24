import 'package:Gemu/screensmodels/Home/home_screen_model.dart';
import 'package:Gemu/ui/widgets/app_bar_animate.dart';
import 'package:Gemu/models/data.dart';
import 'package:Gemu/models/game_model.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final List<Game> games = panelGames;
  int selectedIndex = 0;

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(vsync: this, length: games.length, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeScreenModel>.reactive(
        viewModelBuilder: () => HomeScreenModel(),
        builder: (context, model, child) => CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: AppBarAnimate(),
                ),
                SliverToBoxAdapter(
                    child: PreferredSize(
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                height: MediaQuery.of(context).size.height / 10,
                                width: MediaQuery.of(context).size.width - 25,
                                child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 5.0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: TabBar(
                                        isScrollable: true,
                                        controller: _tabController,
                                        labelColor: Colors.black,
                                        indicatorSize: TabBarIndicatorSize.tab,
                                        indicator: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Theme.of(context).primaryColor,
                                                Theme.of(context).accentColor
                                              ],
                                            )),
                                        tabs: games
                                            .map((e) => Container(
                                                  height: 55,
                                                  width: 55,
                                                  child: Tab(
                                                    child: Container(
                                                      height: 50,
                                                      width: 50,
                                                      margin:
                                                          EdgeInsets.all(5.0),
                                                      decoration: BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                            colors: [
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                              Theme.of(context)
                                                                  .accentColor
                                                            ],
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.0),
                                                          image: DecorationImage(
                                                              fit: BoxFit.cover,
                                                              image: AssetImage(
                                                                  e.imageUrl))),
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                        onTap: (index) => setState(
                                            () => selectedIndex = index),
                                      ),
                                    )),
                              ),
                            ),
                            Divider(
                              color: Theme.of(context).primaryColor,
                              thickness: 0.75,
                            )
                          ],
                        ),
                        preferredSize: Size.fromHeight(100))),
                SliverFillRemaining(
                    child: TabBarView(
                  controller: _tabController,
                  children: games
                      .map((e) => Center(
                            child: Text('${e.nameGame} content'),
                          ))
                      .toList(),
                ))
              ],
            ));
  }
}
