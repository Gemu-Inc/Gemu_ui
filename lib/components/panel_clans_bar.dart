import 'package:Gemu/core/models/models.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/core/data/data.dart';

class PanelClansSliver extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      PanelClansBarTest();

  @override
  double get maxExtent => 80;

  @override
  double get minExtent => 80;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}

class PanelClansBarTest extends StatefulWidget {
  PanelClansBarTest({Key key}) : super(key: key);

  @override
  _PanelClansBarTestState createState() => _PanelClansBarTestState();
}

class _PanelClansBarTestState extends State<PanelClansBarTest> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return PanelClansBar(
      clans: panelClans,
      selectedIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
    );
  }
}

class PanelClansBar extends StatelessWidget {
  const PanelClansBar(
      {Key key,
      @required this.clans,
      @required this.selectedIndex,
      @required this.onTap})
      : super(key: key);

  final List<Clan> clans;
  final int selectedIndex;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.0),
      child: Container(
          height: 50,
          color: Colors.pink,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 500.0),
            child: TabBar(
              isScrollable: true,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(200),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF7C79A5), Color(0xFFDC804F)],
                  )),
              tabs: clans
                  .map(
                    (e) => Tab(
                        child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        e.nameClan,
                        style: TextStyle(fontSize: 30),
                      ),
                    )),
                  )
                  .toList(),
              onTap: onTap,
            ),
          )),
    );
  }
}
