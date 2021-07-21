import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';

import 'package:gemu/ui/constants/constants.dart';

class ContentPostDescription extends StatelessWidget {
  final String? idUser, username, caption;
  final List? hashtags;

  ContentPostDescription(
      {this.idUser, this.username, this.caption, this.hashtags});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.pink,
      width: MediaQuery.of(context).size.width / 2,
      child: ExpandableTheme(
          data: ExpandableThemeData(
            iconColor: Colors.white,
            useInkWell: true,
          ),
          child: ExpandableNotifier(
              child: Card(
            color: Colors.transparent,
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                    onTap: () {}, child: Text(username!, style: mystyle(15))),
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    theme: ExpandableThemeData(
                        tapBodyToCollapse: true, tapBodyToExpand: true),
                    collapsed: Text(
                      caption!,
                      style: TextStyle(color: Colors.grey),
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            caption!,
                            style: TextStyle(color: Colors.grey),
                            softWrap: true,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                        Container(
                          child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3, childAspectRatio: 3),
                              shrinkWrap: true,
                              itemCount: hashtags!.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: EdgeInsets.symmetric(horizontal: 1.0),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white)),
                                  child: Text(
                                    '#${hashtags![index]}',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                );
                              }),
                        ),
                      ],
                    ),
                    builder: (_, collapsed, expanded) {
                      return Expandable(
                        collapsed: collapsed,
                        expanded: expanded,
                        theme: ExpandableThemeData(crossFadePoint: 0),
                      );
                    },
                  ),
                )
              ],
            ),
          ))),
    );
  }
}
