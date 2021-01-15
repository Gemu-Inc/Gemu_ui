import 'package:flutter/foundation.dart';

class Categorie {
  final String name;
  final String documentId;

  Categorie({@required this.name, this.documentId});

  Map<String, dynamic> toMap() {
    return {'name': name};
  }

  static Categorie fromMap(Map<String, dynamic> map, String documentId) {
    if (map == null) return null;

    return Categorie(name: map['name'], documentId: documentId);
  }
}
