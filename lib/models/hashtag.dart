import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:algolia/algolia.dart';

class Hashtag {
  final DocumentReference? reference;
  final AlgoliaObjectReference? referenceAlgolia;
  final String name;
  final int postsCount;
  final String? type;

  Hashtag(
      {this.reference,
      this.referenceAlgolia,
      required this.name,
      required this.postsCount,
      this.type});

  factory Hashtag.fromMap(
      DocumentSnapshot snapshot, Map<String, dynamic> data) {
    return Hashtag(
        reference: snapshot.reference,
        name: data['name'],
        postsCount: data['postsCount']);
  }

  factory Hashtag.fromMapAlgolia(
      AlgoliaObjectSnapshot snapshot, Map<String, dynamic> data) {
    return Hashtag(
        referenceAlgolia: snapshot.ref,
        name: data["name"],
        postsCount: data["postsCount"],
        type: data["type"]);
  }
}
