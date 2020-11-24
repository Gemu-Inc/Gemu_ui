import 'package:flutter/material.dart';

class MenuClansSliver extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      MenuClans();

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}

class MenuClans extends StatefulWidget {
  MenuClans({Key key}) : super(key: key);

  @override
  _MenuClansState createState() => _MenuClansState();
}

class _MenuClansState extends State<MenuClans> {
  @override
  Widget build(BuildContext context) {
    return TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: [Tab(text: 'Parcourir'), Tab(text: 'Clans')]);
  }
}
