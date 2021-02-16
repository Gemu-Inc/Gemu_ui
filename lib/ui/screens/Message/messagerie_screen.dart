import 'package:Gemu/constants/route_names.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

class MessagerieMenuDrawer extends StatefulWidget {
  MessagerieMenuDrawer({Key key}) : super(key: key);

  @override
  _MessagerieMenuDrawerState createState() => _MessagerieMenuDrawerState();
}

class _MessagerieMenuDrawerState extends State<MessagerieMenuDrawer>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  int currentTabIndex = 0;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    currentTabIndex = 0;
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging)
      setState(() {
        print('Changing to Tab: ${_tabController.index}');
        currentTabIndex = _tabController.index;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
          child: GradientAppBar(
            automaticallyImplyLeading: false,
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).accentColor
                ]),
            actions: [
              IconButton(
                  icon: Icon(
                    Icons.zoom_out_map_sharp,
                    size: 23,
                  ),
                  onPressed: () =>
                      Navigator.pushNamed(context, MessagerieMenuRoute))
            ],
            bottom: PreferredSize(
                child: Container(
                    height: 50,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: Theme.of(context).primaryColor,
                          unselectedLabelColor: Colors.grey,
                          indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Theme.of(context).canvasColor),
                          tabs: [
                            Tab(
                                child: currentTabIndex == 0
                                    ? Row(
                                        children: [
                                          Text('Activités'),
                                          Icon(Icons.expand_more_sharp)
                                        ],
                                      )
                                    : Text('Activités')),
                            Tab(
                              text: 'Messages',
                            )
                          ]),
                    )),
                preferredSize: Size.fromHeight(50)),
          ),
          preferredSize: Size.fromHeight(80)),
      body: TabBarView(controller: _tabController, children: [
        Center(
          child: Text('Activités'),
        ),
        Center(
          child: Text('Messages'),
        )
      ]),
    ));
  }
}

class MessagerieMenu extends StatefulWidget {
  MessagerieMenu({Key key}) : super(key: key);

  @override
  _MessagerieMenuState createState() => _MessagerieMenuState();
}

class _MessagerieMenuState extends State<MessagerieMenu>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  int currentTabIndex = 0;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    currentTabIndex = 0;
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging)
      setState(() {
        print('Changing to Tab: ${_tabController.index}');
        currentTabIndex = _tabController.index;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: GradientAppBar(
        automaticallyImplyLeading: false,
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).accentColor
            ]),
        leading: IconButton(
            icon: Icon(
              Icons.expand_more,
              size: 40,
            ),
            onPressed: () => Navigator.pushNamed(context, NavScreenRoute)),
        bottom: PreferredSize(
            child: Container(
                height: 60,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Colors.grey,
                      indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).canvasColor),
                      tabs: [
                        Tab(
                            child: currentTabIndex == 0
                                ? Row(
                                    children: [
                                      Text('Activités'),
                                      Icon(Icons.expand_more_sharp)
                                    ],
                                  )
                                : Text('Activités')),
                        Tab(
                          text: 'Messages',
                        )
                      ]),
                )),
            preferredSize: Size.fromHeight(60)),
      ),
      body: TabBarView(controller: _tabController, children: [
        Center(
          child: Text('Activités'),
        ),
        Center(
          child: Text('Messages'),
        )
      ]),
    );
  }
}
