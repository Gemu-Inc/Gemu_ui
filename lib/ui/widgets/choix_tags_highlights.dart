import 'package:Gemu/models/data.dart';
import 'package:Gemu/models/models.dart';
import 'package:flutter/material.dart';

class ChoixTags extends StatefulWidget {
  ChoixTags({Key key}) : super(key: key);

  @override
  _ChoixTagsState createState() => _ChoixTagsState();
}

class _ChoixTagsState extends State<ChoixTags> {
  @override
  Widget build(BuildContext context) {
    final List<CategoriePost> categorie = categoriePosts;
    return Container(
      alignment: Alignment.topCenter,
      child: Wrap(
          direction: Axis.horizontal,
          children: categorie
              .map(
                (e) => GestureDetector(
                    child: Container(
                        margin: EdgeInsets.all(5.0),
                        height: 50,
                        width: 120,
                        decoration: BoxDecoration(
                            color: e.selected
                                ? Theme.of(context).cardColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                            border:
                                Border.all(color: Theme.of(context).cardColor)),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text('${e.name}'),
                        )),
                    onTap: () {
                      if (e.selected == false) {
                        setState(() {
                          e.selected = true;
                        });
                      } else if (e.selected == true) {
                        setState(() {
                          e.selected = false;
                        });
                      }
                    }),
              )
              .toList()),
    );
  }
}
