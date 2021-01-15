import 'package:flutter/foundation.dart';

class Game {
  final String name;
  final String imageUrl;
  final String idCategorie;
  final String documentId;

  Game(
      {@required this.name,
      @required this.imageUrl,
      @required this.idCategorie,
      this.documentId});

  Map<String, dynamic> toMap() {
    return {'name': name, 'imageUrl': imageUrl, 'idCategorie': idCategorie};
  }

  static Game fromMap(Map<String, dynamic> map, String documentId) {
    if (map == null) return null;

    return Game(
        name: map['name'],
        imageUrl: map['imageUrl'],
        idCategorie: map['idCategorie'],
        documentId: documentId);
  }
}
