import 'package:cloud_firestore/cloud_firestore.dart';

class Commentaire {
  final DocumentReference reference;
  final String username;
  final String uid;
  final String? profilPicture;
  final String comment;
  final int upcount;
  final int downcount;
  final int date;
  final String id;

  Commentaire(
      {required this.reference,
      required this.username,
      required this.uid,
      required this.profilPicture,
      required this.comment,
      required this.upcount,
      required this.downcount,
      required this.date,
      required this.id});

  factory Commentaire.fromMap(
      DocumentSnapshot snapshot, Map<String, dynamic> data) {
    return Commentaire(
        reference: snapshot.reference,
        username: data['username'],
        uid: data['uid'],
        profilPicture: data['profilpicture'],
        comment: data['comment'],
        upcount: data['upcount'],
        downcount: data['downcount'],
        date: data['date'],
        id: data['id']);
  }
}
