import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:algolia/algolia.dart';

class Game {
  final DocumentSnapshot<Map<String, dynamic>>? snapshot;
  final String name;
  final String imageUrl;
  final List? categories;
  final String? documentId;
  final DocumentReference? reference;
  final AlgoliaObjectReference? referenceAlgolia;
  final String? type;
  final String? idDemandeur;

  Game(
      {this.snapshot,
      this.reference,
      this.referenceAlgolia,
      required this.name,
      required this.imageUrl,
      this.categories,
      this.documentId,
      this.type,
      this.idDemandeur});

  factory Game.fromMap(DocumentSnapshot<Map<String, dynamic>> snapshot,
      Map<String, dynamic> data) {
    return Game(
        snapshot: snapshot,
        reference: snapshot.reference,
        documentId: snapshot.id,
        name: data['name'],
        imageUrl: data['imageUrl'],
        categories: data['categories'],
        idDemandeur: data['idDemandeur']);
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
