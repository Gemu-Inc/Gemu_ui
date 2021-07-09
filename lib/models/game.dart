import 'package:cloud_firestore/cloud_firestore.dart';

class Game {
  final String name;
  final String imageUrl;
  final List categories;
  final String? documentId;

  Game(
      {required this.name,
      required this.imageUrl,
      required this.categories,
      this.documentId});

  factory Game.fromMap(DocumentSnapshot snapshot, Map<String, dynamic> map) {
    return Game(
      name: map['name'],
      imageUrl: map['imageUrl'],
      categories: map['categories'],
      documentId: snapshot.id,
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'imageUrl': imageUrl, 'categories': categories};
  }
}
