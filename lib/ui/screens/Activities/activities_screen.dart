import 'package:flutter/material.dart';

import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/ui/providers/conversationProvider.dart';

import 'Notifications/notifications_screen.dart';

class ActivitiesMenuDrawer extends StatefulWidget {
  final String uid;

  ActivitiesMenuDrawer({Key? key, required this.uid}) : super(key: key);

  @override
  _ActivitiesMenuDrawerState createState() => _ActivitiesMenuDrawerState();
}

class _ActivitiesMenuDrawerState extends State<ActivitiesMenuDrawer>
    with TickerProviderStateMixin {
  TabController? _tabController;
  int currentTabIndex = 0;

  late AnimationController _activitiesController, _rotateController;
  late Animation _activitiesAnimation, _rotateAnimation;

  int whatActivity = 0;
  List<String> activities = [
    'All notifications',
    'Comments',
    'Follows',
    'Up&Down'
  ];

  void _onTabChanged() {
    if (!_tabController!.indexIsChanging)
      setState(() {
        print('Changing to Tab: ${_tabController!.index}');
        currentTabIndex = _tabController!.index;
        if (currentTabIndex == 1 && _activitiesController.value == 1) {
          _rotateController.reverse();
          _activitiesController.reverse();
        }
      });
  }

  double getRadianFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  @override
  void initState() {
    super.initState();

    print('init activities');

    _tabController = TabController(length: 2, vsync: this);
    _tabController!.addListener(_onTabChanged);
    currentTabIndex = 0;

    _activitiesController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _rotateController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    _activitiesAnimation = CurvedAnimation(
        parent: _activitiesController, curve: Curves.easeInCubic);
    _rotateAnimation = Tween<double>(begin: 0.0, end: 180.0).animate(
        CurvedAnimation(parent: _rotateController, curve: Curves.easeOut));

    _rotateController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController!.dispose();
    _activitiesController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 6,
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).accentColor
                ])),
          ),
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_ios)),
          title: Text('Activities'),
          bottom: PreferredSize(
              child: Padding(
                padding: EdgeInsets.only(bottom: 5.0),
                child: bottomAppBar(),
              ),
              preferredSize: Size.fromHeight(50)),
        ),
        body: Stack(
          children: [
            TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [
                  NotificationsScreen(
                    whatActivity: activities[whatActivity],
                  ),
                  ConversationProvider(uid: widget.uid)
                ]),
            Align(alignment: Alignment.topCenter, child: activitiesPanel()),
          ],
        ));
  }

  Widget bottomAppBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: Theme.of(context).primaryColor,
      unselectedLabelColor: Colors.grey,
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).canvasColor,
      ),
      tabs: [
        Tab(
            child: currentTabIndex == 0
                ? GestureDetector(
                    onTap: () {
                      if (_rotateController.isCompleted) {
                        _rotateController.reverse();
                        _activitiesController.reverse();
                      } else {
                        _rotateController.forward();
                        _activitiesController.forward();
                      }
                    },
                    child: Row(
                      children: [
                        Text(activities[whatActivity]),
                        Transform(
                            transform: Matrix4.rotationZ(
                                getRadianFromDegree(_rotateAnimation.value)),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.expand_more,
                            ))
                      ],
                    ))
                : Text(activities[whatActivity])),
        Tab(
          text: 'Messages',
        )
      ],
    );
  }

  Widget activitiesPanel() {
    return SizeTransition(
        sizeFactor: _activitiesAnimation as Animation<double>,
        child: ClipRect(
            child: Container(
                height: MediaQuery.of(context).size.height / 3,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).accentColor
                    ])),
                child: Container(
                  color: Theme.of(context).canvasColor.withOpacity(0.5),
                  alignment: Alignment.center,
                  child: ListView(
                    children: [
                      ListTile(
                        onTap: () {
                          _rotateController.reverse();
                          _activitiesController.reverse();
                          setState(() {
                            whatActivity = 0;
                          });
                        },
                        title: Text(
                          activities[0],
                          style: mystyle(12, Colors.white60),
                        ),
                        trailing:
                            whatActivity == 0 ? Icon(Icons.check) : SizedBox(),
                      ),
                      ListTile(
                        onTap: () {
                          _rotateController.reverse();
                          _activitiesController.reverse();
                          setState(() {
                            whatActivity = 1;
                          });
                        },
                        title: Text(activities[1],
                            style: mystyle(12, Colors.white60)),
                        trailing:
                            whatActivity == 1 ? Icon(Icons.check) : SizedBox(),
                      ),
                      ListTile(
                        onTap: () {
                          _rotateController.reverse();
                          _activitiesController.reverse();
                          setState(() {
                            whatActivity = 2;
                          });
                        },
                        title: Text(activities[2],
                            style: mystyle(12, Colors.white60)),
                        trailing:
                            whatActivity == 2 ? Icon(Icons.check) : SizedBox(),
                      ),
                      ListTile(
                        onTap: () {
                          _rotateController.reverse();
                          _activitiesController.reverse();
                          setState(() {
                            whatActivity = 3;
                          });
                        },
                        title: Text(activities[3],
                            style: mystyle(12, Colors.white60)),
                        trailing:
                            whatActivity == 3 ? Icon(Icons.check) : SizedBox(),
                      ),
                    ],
                  ),
                ))));
  }
}
