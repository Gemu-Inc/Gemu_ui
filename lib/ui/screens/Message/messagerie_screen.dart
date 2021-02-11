import 'package:flutter/material.dart';

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
    return Drawer(
        child: Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
          child: Container(
              height: 100,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).accentColor
                  ])),
              child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(top: 20.0),
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
                  ))),
          preferredSize: Size.fromHeight(100)),
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
