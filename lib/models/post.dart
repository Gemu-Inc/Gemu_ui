import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:gemu/services/cache_manager_service.dart';

class Post {
  DocumentReference reference;
  String id;
  String uid;
  int commentcount;
  int date;
  String description;
  String gameName;
  String gameImage;
  List hashtags;
  int upcount;
  int downcount;
  String postUrl;
  String type;
  int viewcount;
  String? previewImage;

  Post(
      {required this.reference,
      required this.id,
      required this.uid,
      required this.commentcount,
      required this.date,
      required this.description,
      required this.gameName,
      required this.gameImage,
      required this.hashtags,
      required this.postUrl,
      required this.type,
      required this.downcount,
      required this.upcount,
      required this.viewcount,
      this.previewImage});

  factory Post.fromMap(DocumentSnapshot snapshot, Map<String, dynamic> data) {
    return Post(
        reference: snapshot.reference,
        id: data['id'],
        uid: data['uid'],
        commentcount: data['commentcount'],
        date: data['date'],
        description: data['description'],
        gameName: data['gameName'],
        gameImage: data['gameImage'],
        hashtags: data['hashtags'],
        postUrl: data['postUrl'],
        type: data['type'],
        downcount: data['downcount'],
        upcount: data['upcount'],
        viewcount: data['viewcount'],
        previewImage: data['previewImage']);
  }
}
