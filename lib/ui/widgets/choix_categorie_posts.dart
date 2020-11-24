import 'package:Gemu/models/data.dart';
import 'package:Gemu/models/models.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/ui/widgets/widgets.dart';

class ChoixCategorie extends StatefulWidget {
  ChoixCategorie({Key key, @required this.expanded}) : super(key: key);

  final bool expanded;

  @override
  _ChoixCategorieState createState() => _ChoixCategorieState();
}

class _ChoixCategorieState extends State<ChoixCategorie> {
  List<bool> selected;

  @override
  Widget build(BuildContext context) {
    final List<CategoriePost> categorie = categoriePosts;
    return Wrap(
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
            .toList());
  }
}
