import 'package:flutter/foundation.dart';

class Game {
  final String? name;
  final String? imageUrl;
  //final List<String> idCategories;
  final String? documentId;
  bool? selected;

  Game(
      {required this.name,
      required this.imageUrl,
      //@required this.idCategories,
      this.documentId,
      this.selected});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl, /*'idCategories': idCategories*/
    };
  }

  static Game fromMap(Map<String, dynamic> map, String documentId) {
    return Game(
        /*idCategories: List<String>.from(map['idCategories'].map((item) {
          return item;
        }).toList()),*/
        name: map['name'],
        imageUrl: map['imageUrl'],
        documentId: documentId,
        selected: false);
  }
}
