import 'package:Gemu/data/data.dart';
import 'package:Gemu/models/game_model.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/widgets/widgets.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final List<Game> games = panelGames;

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: games.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        /*SliverPersistentHeader(
            pinned: true,
            delegate: StickyTabBarDelegate(
                child: TabBar(
              controller: _tabController,
              tabs: games.map((e) => Text(e.nameGame)).toList(),
            ))),*/
      ],
    );
  }
}

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar child;

  StickyTabBarDelegate({@required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return this.child;
  }

  @override
  double get maxExtent => this.child.preferredSize.height;

  @override
  double get minExtent => this.child.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
