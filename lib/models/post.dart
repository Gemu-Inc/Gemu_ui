import 'package:flutter/foundation.dart';

class Post {
  final String? game;
  final String? section;
  final String? content;
  final String? imageUrl;
  final String? userId;
  final String? documentId;
  final String? imageFileName;

  Post({
    required this.userId,
    required this.game,
    required this.section,
    required this.content,
    this.documentId,
    this.imageUrl,
    this.imageFileName,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'game': game,
      'section': section,
      'content': content,
      'imageUrl': imageUrl,
      'imageFileName': imageFileName,
    };
  }

  static Post fromMap(Map<String, dynamic> map, String documentId) {
    return Post(
      game: map['game'],
      section: map['section'],
      content: map['content'],
      imageUrl: map['imageUrl'],
      userId: map['userId'],
      imageFileName: map['imageFileName'],
      documentId: documentId,
    );
  }
}
