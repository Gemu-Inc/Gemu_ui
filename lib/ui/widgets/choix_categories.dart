import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChoixCategories extends StatefulWidget {
  final DocumentSnapshot categorie;

  ChoixCategories({
    Key key,
    @required this.categorie,
  }) : super(key: key);

  @override
  ChoixCategoriesState createState() => ChoixCategoriesState();
}

class ChoixCategoriesState extends State<ChoixCategories>
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
      label: Text(widget.categorie['name']),
      labelPadding: EdgeInsets.all(6.0),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          isSelected = !isSelected;
        });
      },
      selectedColor: Theme.of(context).canvasColor,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
