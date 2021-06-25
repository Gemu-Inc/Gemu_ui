import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SelectCategory extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>> category;
  final List gameCategories;

  SelectCategory({required this.category, required this.gameCategories});

  @override
  SelectCategoryState createState() => SelectCategoryState();
}

class SelectCategoryState extends State<SelectCategory> {
  bool isSelect = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 100,
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isSelect = !isSelect;
                  });
                  if (isSelect == true &&
                      !widget.gameCategories
                          .contains(widget.category.data()!['name'])) {
                    widget.gameCategories.add(widget.category.data()!['name']);
                  }
                  if (isSelect == false &&
                      widget.gameCategories
                          .contains(widget.category.data()!['name'])) {
                    widget.gameCategories
                        .remove(widget.category.data()!['name']);
                  }
                },
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10.0),
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).accentColor
                          ])),
                  child: Icon(Icons.category),
                ),
              ),
              isSelect
                  ? Icon(
                      Icons.check,
                      color: Colors.green[100],
                    )
                  : SizedBox(),
            ],
          ),
          SizedBox(
            height: 15.0,
          ),
          Text(widget.category.data()!['name'])
        ],
      ),
    );
  }
}
