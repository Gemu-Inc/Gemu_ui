import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  final List<IconData> icons;
  final int selectedIndex;
  final Function(int) onTap;

  const CustomTabBar({
    Key key,
    @required this.icons,
    @required this.selectedIndex,
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0))),
      child: TabBar(
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
        onTap: onTap,
      ),
    );
  }
}
