import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:algolia/algolia.dart';

class Hashtag {
  final DocumentSnapshot<Map<String, dynamic>>? snapshot;
  final DocumentReference? reference;
  final AlgoliaObjectReference? referenceAlgolia;
  String? documentId;
  final String name;
  final int postsCount;
  final String? type;

  Hashtag(
      {this.snapshot,
      this.reference,
      this.referenceAlgolia,
      this.documentId,
      required this.name,
      required this.postsCount,
      this.type});

  factory Hashtag.fromMap(DocumentSnapshot<Map<String, dynamic>> snapshot,
      Map<String, dynamic> data) {
    return Hashtag(
        snapshot: snapshot,
        reference: snapshot.reference,
        documentId: snapshot.id,
        name: data['name'],
        postsCount: data['postsCount'],
        type: data["type"] ?? "hashtag");
  }

  factory Hashtag.fromMapAlgolia(
      AlgoliaObjectSnapshot snapshot, Map<String, dynamic> data) {
    return Hashtag(
        referenceAlgolia: snapshot.ref,
        documentId: data["objectID"],
        name: data["name"],
        postsCount: data["postsCount"],
        type: data["type"]);
  }
}
