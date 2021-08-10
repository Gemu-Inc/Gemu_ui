import 'package:cloud_firestore/cloud_firestore.dart';

class Hashtag {
  final DocumentReference reference;
  final String name;
  final int postsCount;

  Hashtag(
      {required this.reference, required this.name, required this.postsCount});

  factory Hashtag.fromMap(
      DocumentSnapshot snapshot, Map<String, dynamic> data) {
    return Hashtag(
        reference: snapshot.reference,
        name: data['name'],
        postsCount: data['postsCount']);
  }
}
