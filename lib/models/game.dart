import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:algolia/algolia.dart';

class Game {
  final DocumentSnapshot<Map<String, dynamic>>? snapshot;
  final String documentId;
  final String name;
  final String imageUrl;
  final List categories;
  final DocumentReference? reference;
  final AlgoliaObjectReference? referenceAlgolia;
  final String? type;

  Game(
      {this.snapshot,
      this.reference,
      this.referenceAlgolia,
      required this.documentId,
      required this.name,
      required this.imageUrl,
      required this.categories,
      this.type});

  factory Game.fromMap(DocumentSnapshot<Map<String, dynamic>> snapshot,
      Map<String, dynamic> data) {
    return Game(
        snapshot: snapshot,
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
        categories: data['categories'],
        type: data["type"]);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': documentId,
      'name': name,
      'imageUrl': imageUrl,
      'categories': categories
    };
  }
}
