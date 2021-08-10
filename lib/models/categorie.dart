import 'package:cloud_firestore/cloud_firestore.dart';

class Categorie {
  final DocumentReference reference;
  final String name;

  Categorie({required this.reference, required this.name});

  factory Categorie.fromMap(
      DocumentSnapshot snapshot, Map<String, dynamic> data) {
    return Categorie(reference: snapshot.reference, name: data['name']);
  }
}
