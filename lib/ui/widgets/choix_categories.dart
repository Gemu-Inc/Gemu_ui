import 'package:flutter/material.dart';

class ChoixCategories extends StatefulWidget {
  final String? categorie;
  final List tags;

  ChoixCategories({Key? key, required this.categorie, required this.tags})
      : super(key: key);

  @override
  ChoixCategoriesState createState() => ChoixCategoriesState();
}

class ChoixCategoriesState extends State<ChoixCategories>
    with SingleTickerProviderStateMixin {
  bool? isSelected;

  @override
  void initState() {
    super.initState();
    isSelected = true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(widget.categorie!),
      labelPadding: EdgeInsets.all(6.0),
      selected: isSelected!,
      onSelected: (bool selected) {
        setState(() {
          isSelected = !isSelected!;
          if (isSelected == false) {
            widget.tags.remove(widget.categorie);
          } else {
            widget.tags.add(widget.categorie);
          }
        });
      },
      selectedColor: Theme.of(context).canvasColor,
    );
  }
}
