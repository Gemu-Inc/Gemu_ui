import 'package:Gemu/core/data/data.dart';
import 'package:Gemu/core/models/models.dart';
import 'package:flutter/material.dart';

class PanelGamesSliver extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      PanelGamesBarTest();

  @override
  double get maxExtent => 76;

  @override
  double get minExtent => 76;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}

class PanelGamesBarTest extends StatefulWidget {
  PanelGamesBarTest({Key key}) : super(key: key);

  @override
  _PanelGamesBarTestState createState() => _PanelGamesBarTestState();
}

class _PanelGamesBarTestState extends State<PanelGamesBarTest> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return PanelGamesBar(
      games: panelGames,
      selectedIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
    );
  }
}

class PanelGamesBar extends StatelessWidget {
  const PanelGamesBar(
      {Key key,
      @required this.games,
      @required this.selectedIndex,
      @required this.onTap})
      : super(key: key);

  final List<Game> games;
  final int selectedIndex;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: Container(
            width: MediaQuery.of(context).size.width - 25,
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5.0),
                child: Align(
                  alignment: Alignment.center,
                  child: TabBar(
                    isScrollable: true,
                    labelColor: Colors.black,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(200),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).accentColor
                          ],
                        )),
                    tabs: games
                        .map((e) => Tab(
                                child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                e.nameGame,
                                style: TextStyle(fontSize: 15),
                              ),
                            )))
                        .toList(),
                    onTap: onTap,
                  ),
                )),
          ),
        ),
        Divider(
          color: Theme.of(context).primaryColor,
          thickness: 0.75,
        )
      ],
    );
  }
}
