import 'package:Gemu/models/models.dart';
import 'package:flutter/material.dart';

class ChoixTags extends StatefulWidget {
  final CategoriePost tag;

  ChoixTags({Key key, this.tag}) : super(key: key);

  @override
  _ChoixTagsState createState() => _ChoixTagsState();
}

class _ChoixTagsState extends State<ChoixTags>
    with SingleTickerProviderStateMixin {
  bool isSelected;

  @override
  void initState() {
    super.initState();
    isSelected = true;
  }

  @override
  Widget build(BuildContext context) {
    return FilterChip(
        label: Text(widget.tag.name),
        labelPadding: EdgeInsets.all(6.0),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            isSelected = !isSelected;
          });
        },
        selectedColor: Theme.of(context).canvasColor);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
