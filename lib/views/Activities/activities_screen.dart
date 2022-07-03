import 'package:flutter/material.dart';

import 'Notifications/notifications_screen.dart';

class ActivitiesMenuDrawer extends StatefulWidget {
  final String uid;

  ActivitiesMenuDrawer({Key? key, required this.uid}) : super(key: key);

  @override
  _ActivitiesMenuDrawerState createState() => _ActivitiesMenuDrawerState();
}

class _ActivitiesMenuDrawerState extends State<ActivitiesMenuDrawer>
    with TickerProviderStateMixin {
  late AnimationController _activitiesController, _rotateController;
  late Animation _activitiesAnimation, _rotateAnimation;

  late ScrollController notifScrollController;

  double positionScroll = 0.0;

  int whatActivity = 0;
  List<String> activities = [
    'All notifications',
    'Comments',
    'Follows',
    'Up&Down'
  ];

  double getRadianFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  @override
  void initState() {
    super.initState();
    _activitiesController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _rotateController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    _activitiesAnimation = CurvedAnimation(
        parent: _activitiesController, curve: Curves.easeInCubic);
    _rotateAnimation = Tween<double>(begin: 0.0, end: 180.0).animate(
        CurvedAnimation(parent: _rotateController, curve: Curves.easeOut));

    notifScrollController = ScrollController();

    _rotateController.addListener(() {
      setState(() {});
    });

    notifScrollController.addListener(() {
      positionScroll = notifScrollController.position.pixels;
    });
  }

  @override
  void deactivate() {
    _rotateController.removeListener(() {});
    notifScrollController.removeListener(() {});
    super.deactivate();
  }

  @override
  void dispose() {
    notifScrollController.dispose();
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
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary
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
            NotificationsScreen(
              whatActivity: activities[whatActivity],
              notifScrollController: notifScrollController,
            ),
            Align(alignment: Alignment.topCenter, child: activitiesPanel()),
          ],
        ));
  }

  Widget bottomAppBar() {
    return Center(
        child: GestureDetector(
            onTap: () {
              if (_rotateController.isCompleted) {
                _rotateController.reverse();
                _activitiesController.reverse();
              } else {
                _rotateController.forward();
                _activitiesController.forward();
              }
            },
            child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width / 2,
              decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10.0)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    activities[whatActivity],
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Transform(
                      transform: Matrix4.rotationZ(
                          getRadianFromDegree(_rotateAnimation.value)),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.expand_more,
                        color: Theme.of(context).colorScheme.primary,
                      ))
                ],
              ),
            )));
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
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary
                    ])),
                child: Container(
                  color: Theme.of(context).canvasColor.withOpacity(0.5),
                  alignment: Alignment.center,
                  child: ListView(
                    children: [
                      ListTile(
                        onTap: () async {
                          _rotateController.reverse();
                          _activitiesController.reverse();
                          print('${notifScrollController.offset}');
                          if (notifScrollController.offset != 0) {
                            print('remise a zéro');
                            notifScrollController.jumpTo(0.0);
                          }
                          await Future.delayed(Duration(milliseconds: 500));
                          setState(() {
                            whatActivity = 0;
                          });
                        },
                        title: Text(
                          activities[0],
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing:
                            whatActivity == 0 ? Icon(Icons.check) : SizedBox(),
                      ),
                      ListTile(
                        onTap: () async {
                          _rotateController.reverse();
                          _activitiesController.reverse();

                          if (positionScroll != 0) {
                            notifScrollController.jumpTo(0);
                          }
                          await Future.delayed(Duration(milliseconds: 500));
                          setState(() {
                            whatActivity = 1;
                          });
                        },
                        title: Text(activities[1],
                            style: Theme.of(context).textTheme.bodySmall),
                        trailing:
                            whatActivity == 1 ? Icon(Icons.check) : SizedBox(),
                      ),
                      ListTile(
                        onTap: () async {
                          _rotateController.reverse();
                          _activitiesController.reverse();

                          if (positionScroll != 0) {
                            notifScrollController.jumpTo(0);
                          }
                          await Future.delayed(Duration(milliseconds: 500));
                          setState(() {
                            whatActivity = 2;
                          });
                        },
                        title: Text(activities[2],
                            style: Theme.of(context).textTheme.bodySmall),
                        trailing:
                            whatActivity == 2 ? Icon(Icons.check) : SizedBox(),
                      ),
                      ListTile(
                        onTap: () async {
                          _rotateController.reverse();
                          _activitiesController.reverse();
                          if (positionScroll != 0) {
                            notifScrollController.jumpTo(0);
                          }
                          await Future.delayed(Duration(milliseconds: 500));
                          setState(() {
                            whatActivity = 3;
                          });
                        },
                        title: Text(activities[3],
                            style: Theme.of(context).textTheme.bodySmall),
                        trailing:
                            whatActivity == 3 ? Icon(Icons.check) : SizedBox(),
                      ),
                    ],
                  ),
                ))));
  }
}
