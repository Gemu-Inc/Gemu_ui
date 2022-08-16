import 'package:flutter/material.dart';
import 'package:gemu/constants/constants.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final List<BottomNavigationBarItem> items;
  final ValueChanged<int> onItemSelected;

  CustomNavBar(
      {Key? key,
      required this.selectedIndex,
      required this.items,
      required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
          color: selectedIndex == 0
              ? cBGDarkTheme
              : Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).colorScheme.primary,
                blurRadius: 1,
                spreadRadius: 1)
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) {
          int index = items.indexOf(item);
          return _buildItem(item, selectedIndex == index, context, index);
        }).toList(),
      ),
    );
  }

  Widget _buildItem(BottomNavigationBarItem item, bool isSelected,
      BuildContext context, int index) {
    return Padding(
      padding: index == 1
          ? EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.08)
          : index == 2
              ? EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.08)
              : EdgeInsets.zero,
      child: Container(
        height: 50,
        width: 70,
        alignment: Alignment.center,
        child: InkWell(
          onTap: () {
            onItemSelected(index);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconTheme(
                data: IconThemeData(
                  size: 25.0,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.primary ==
                                  cPrimaryPink
                              ? cInactiveIconPinkDarkTheme
                              : cInactiveIconPurpleDarkTheme
                          : Theme.of(context).colorScheme.primary ==
                                  cPrimaryPink
                              ? cInactiveIconPinkLightTheme
                              : cInactiveIconPurpleLightTheme,
                ),
                child: isSelected ? item.activeIcon : item.icon,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 1.0),
                child: Text(
                  item.label!,
                  style: textStyleCustomBold(
                      isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context).colorScheme.primary ==
                                      cPrimaryPink
                                  ? cInactiveIconPinkDarkTheme
                                  : cInactiveIconPurpleDarkTheme
                              : Theme.of(context).colorScheme.primary ==
                                      cPrimaryPink
                                  ? cInactiveIconPinkLightTheme
                                  : cInactiveIconPurpleLightTheme,
                      11),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
