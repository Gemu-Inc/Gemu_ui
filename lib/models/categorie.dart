import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Categorie {
  final String name;
  final List<String> idGames;
  final String documentId;

  Categorie({
    @required this.name,
    @required this.idGames,
    this.documentId,
  });

  Map<String, dynamic> toMap() {
    return {'name': name, 'idGames': idGames};
  }

  static Categorie fromMap(Map<String, dynamic> map, String documentId) {
    if (map == null) return null;

    return Categorie(
      name: map['name'],
      idGames: List<String>.from(map['idGames'].map((item) {
        return item;
      }).toList()),
      documentId: documentId,
    );
  }
}
