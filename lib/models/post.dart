import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  DocumentSnapshot<Map<String, dynamic>>? snapshot;
  DocumentReference reference;
  String id;
  String uid;
  String userName;
  String? imageUrl;
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
  String previewImage;
  String privacy;

  Post(
      {this.snapshot,
      required this.reference,
      required this.id,
      required this.uid,
      required this.userName,
      required this.imageUrl,
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
      required this.previewImage,
      required this.privacy});

  factory Post.fromMap(DocumentSnapshot<Map<String, dynamic>> snapshot,
      Map<String, dynamic> data) {
    return Post(
        snapshot: snapshot,
        reference: snapshot.reference,
        id: data['id'],
        uid: data['uid'],
        userName: data['username'],
        imageUrl: data['imageUrl'],
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
        previewImage: data['previewImage'],
        privacy: data['privacy']);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': userName,
      'imageUrl': imageUrl,
      'type': type,
      'id': id,
      'gameName': gameName,
      'gameImage': gameImage,
      'upcount': upcount,
      'downcount': downcount,
      'commentcount': commentcount,
      'description': description,
      'hashtags': hashtags,
      'postUrl': postUrl,
      'privacy': privacy,
      'viewcount': viewcount,
      'date': date,
      'previewImage': previewImage
    };
  }
}
