import 'package:flutter/material.dart';
import 'package:gemu/constants/constants.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final List<PersistentBottomNavBarItem> items;
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
              ? Color(0xFF22213C)
              : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).colorScheme.primary,
                blurRadius: selectedIndex == 0 ? 1 : 2,
                spreadRadius: 1,
                blurStyle: BlurStyle.solid)
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

  Widget _buildItem(PersistentBottomNavBarItem item, bool isSelected,
      BuildContext context, int index) {
    return Padding(
      padding: index == 1
          ? EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.08)
          : index == 2
              ? EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.08)
              : EdgeInsets.zero,
      child: Container(
        height: 60,
        width: 60,
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
                    size: 26.0,
                    color: isSelected
                        ? item.activeColorPrimary
                        : item.inactiveColorPrimary),
                child: isSelected ? item.icon : item.inactiveIcon!,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  item.title!,
                  style: textStyleCustomBold(
                      isSelected
                          ? item.activeColorPrimary
                          : item.inactiveColorPrimary!,
                      12),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
