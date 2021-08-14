import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:algolia/algolia.dart';

class Game {
  final String name;
  final String imageUrl;
  final List? categories;
  final String? documentId;
  final DocumentReference? reference;
  final AlgoliaObjectReference? referenceAlgolia;
  final String? type;

  Game(
      {this.reference,
      this.referenceAlgolia,
      required this.name,
      required this.imageUrl,
      this.categories,
      this.documentId,
      this.type});

  factory Game.fromMap(DocumentSnapshot snapshot, Map<String, dynamic> data) {
    return Game(
        reference: snapshot.reference,
        documentId: snapshot.id,
        name: data['name'],
        imageUrl: data['imageUrl'],
        categories: data['categories']);
  }

  factory Game.fromMapAlgolia(
      AlgoliaObjectSnapshot snapshot, Map<String, dynamic> data) {
    return Game(
        referenceAlgolia: snapshot.ref,
        documentId: data['objectID'],
        name: data['name'],
        imageUrl: data['imageUrl'],
        type: data["type"]);
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'imageUrl': imageUrl};
  }
}
