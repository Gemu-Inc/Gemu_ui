import 'package:cloud_firestore/cloud_firestore.dart';

class Response {
  final DocumentReference reference;
  final String uid;
  final String response;
  final int upcount;
  final int downcount;
  final int date;
  final String id;

  Response(
      {required this.reference,
      required this.uid,
      required this.response,
      required this.upcount,
      required this.downcount,
      required this.date,
      required this.id});

  factory Response.fromMap(
      DocumentSnapshot snapshot, Map<String, dynamic> data) {
    return Response(
        reference: snapshot.reference,
        uid: data['uid'],
        response: data['response'],
        upcount: data['upcount'],
        downcount: data['downcount'],
        date: data['date'],
        id: data['id']);
  }
}
