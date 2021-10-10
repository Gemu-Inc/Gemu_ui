import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationUser {
  final DocumentSnapshot<Map<String, dynamic>> snapshot;
  final DocumentReference reference;
  final String id;
  final int date;
  final String from;
  final bool seen;
  final String text;
  final String type;

  NotificationUser(
      {required this.snapshot,
      required this.reference,
      required this.id,
      required this.date,
      required this.from,
      required this.seen,
      required this.text,
      required this.type});

  factory NotificationUser.fromMap(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      Map<String, dynamic> data) {
    return NotificationUser(
        snapshot: snapshot,
        reference: snapshot.reference,
        id: snapshot.id,
        date: data['date'],
        from: data['from'],
        seen: data['seen'],
        text: data['text'],
        type: data['type']);
  }
}
