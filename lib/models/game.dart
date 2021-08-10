import 'package:cloud_firestore/cloud_firestore.dart';

class Game {
  final String name;
  final String imageUrl;
  final List? categories;
  final String? documentId;
  final DocumentReference reference;

  Game(
      {required this.reference,
      required this.name,
      required this.imageUrl,
      this.categories,
      this.documentId});

  factory Game.fromMap(DocumentSnapshot snapshot, Map<String, dynamic> data) {
    return Game(
        name: data['name'],
        imageUrl: data['imageUrl'],
        categories: data['categories'],
        documentId: snapshot.id,
        reference: snapshot.reference);
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'imageUrl': imageUrl};
  }
}
