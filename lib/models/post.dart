import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  DocumentSnapshot<Map<String, dynamic>>? snapshot;
  DocumentReference? reference;
  String id;
  String description;
  int upCount;
  int downCount;
  int commentCount;
  int averageUpDown;
  int date;
  String privacy;
  String previewPictureUrl;
  String postUrl;
  String type;
  String uid;
  String idGame;
  Map<String, dynamic>? userPost;
  Map<String, dynamic>? gamePost;

  Post(
      {this.snapshot,
      this.reference,
      required this.id,
      required this.description,
      required this.downCount,
      required this.upCount,
      required this.averageUpDown,
      required this.commentCount,
      required this.date,
      required this.postUrl,
      required this.type,
      required this.previewPictureUrl,
      required this.privacy,
      required this.uid,
      required this.idGame,
      this.userPost,
      this.gamePost});

  factory Post.fromMap(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      Map<String, dynamic> dataPost,
      Map<String, dynamic> dataUser,
      Map<String, dynamic> dataGame) {
    return Post(
        snapshot: snapshot,
        reference: snapshot.reference,
        id: dataPost['id'],
        commentCount: dataPost['commentCount'],
        date: dataPost['date'],
        description: dataPost['description'],
        postUrl: dataPost['postUrl'],
        type: dataPost['type'],
        downCount: dataPost['downCount'],
        upCount: dataPost['upCount'],
        averageUpDown: dataPost['averageUpDown'],
        previewPictureUrl: dataPost['previewPictureUrl'],
        privacy: dataPost['privacy'],
        uid: dataPost['uid'],
        idGame: dataPost['idGame'],
        userPost: dataUser,
        gamePost: dataGame);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'upCount': upCount,
      'downCount': downCount,
      "averageUpDown": averageUpDown,
      'commentCount': commentCount,
      'description': description,
      'postUrl': postUrl,
      'privacy': privacy,
      'date': date,
      'previewPictureUrl': previewPictureUrl,
      'type': type,
      'uid': uid,
      'idGame': idGame
    };
  }
}
