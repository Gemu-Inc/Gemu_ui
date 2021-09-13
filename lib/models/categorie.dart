import 'package:cloud_firestore/cloud_firestore.dart';

class Categorie {
  final DocumentSnapshot snapshot;
  final DocumentReference reference;
  final String name;
  final int games;

  Categorie(
      {required this.reference,
      required this.snapshot,
      required this.name,
      required this.games});

  factory Categorie.fromMap(
      DocumentSnapshot snapshot, Map<String, dynamic> data) {
    return Categorie(
        reference: snapshot.reference,
        snapshot: snapshot,
        name: data['name'],
        games: data['gamesCount']);
  }
}
