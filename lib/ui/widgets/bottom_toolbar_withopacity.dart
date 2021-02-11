import 'package:flutter/material.dart';

class BottomToolBarWithOpa extends StatelessWidget {
  final List<IconData> icons;
  final TabController controller;

  const BottomToolBarWithOpa(
      {Key key, @required this.icons, @required this.controller})
      : super(key: key);

  static const double NavigationIconSize = 25.0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Positioned(
        left: 0,
        bottom: 0,
        child: Container(
          /*decoration: BoxDecoration(
              color:
                  Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5)),*/
          width: size.width,
          height: 55,
          child: TabBar(
            indicatorColor: Colors.transparent,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(
                icon: Icon(
                  icons[0],
                  size: NavigationIconSize,
                  color: controller.index == 0
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                child: Text(
                  'Home',
                  style: TextStyle(
                    fontSize: 8,
                    color: controller.index == 0
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                ),
              ),
              Tab(
                  iconMargin: EdgeInsets.only(bottom: 10.0, right: 20.0),
                  icon: Icon(
                    icons[1],
                    size: NavigationIconSize,
                    color: controller.index == 1
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(right: 19.0),
                    child: Text(
                      'Highlights',
                      style: TextStyle(
                          fontSize: 8,
                          color: controller.index == 1
                              ? Theme.of(context).primaryColor
                              : Colors.grey),
                    ),
                  )),
              Tab(
                  iconMargin: EdgeInsets.only(bottom: 10.0, left: 20.0),
                  icon: Icon(
                    icons[2],
                    size: NavigationIconSize,
                    color: controller.index == 2
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Text(
                      'Games',
                      style: TextStyle(
                          fontSize: 8,
                          color: controller.index == 2
                              ? Theme.of(context).primaryColor
                              : Colors.grey),
                    ),
                  )),
              Tab(
                icon: Icon(
                  icons[3],
                  size: NavigationIconSize,
                  color: controller.index == 3
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                child: Text(
                  'Direct',
                  style: TextStyle(
                      fontSize: 8,
                      color: controller.index == 3
                          ? Theme.of(context).primaryColor
                          : Colors.grey),
                ),
              ),
            ],
            controller: controller,
          ),
        ));
  }
}
