import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  final List<IconData> icons;
  final TabController controller;

  const CustomTabBar({Key key, @required this.icons, @required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      indicatorPadding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 5.0),
      indicatorColor: Theme.of(context).accentColor,
      tabs: icons
          .asMap()
          .map(
            (i, e) => MapEntry(
              i,
              Tab(
                icon: Icon(
                  e,
                  size: 30,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          )
          .values
          .toList(),
      controller: controller,
    );
  }
}
