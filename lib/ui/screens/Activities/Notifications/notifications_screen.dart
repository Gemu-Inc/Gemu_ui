import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'notification_tile.dart';

class NotificationsScreen extends StatefulWidget {
  final String? whatActivity;

  NotificationsScreen({this.whatActivity});

  @override
  NotificationsScreenState createState() => NotificationsScreenState();
}

class NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("singleNotif")
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.data.docs.length == 0) {
          return Center(
            child: Text('Pas de notifications'),
          );
        }

        List<DocumentSnapshot<Map<String, dynamic>>> documents =
            snapshot.data.docs;
        switch (widget.whatActivity) {
          case "All activities":
            return notificationsAllActivities(documents);
          case "Comments":
            return notificationsComments(documents);
          case "Follows":
            return notificationsFollows(documents);
          case "Up&Down":
            return notificationsUpDown(documents);
          default:
            return SizedBox();
        }
      },
    );
  }

  Widget notificationsAllActivities(
      List<DocumentSnapshot<Map<String, dynamic>>> notifications) {
    return ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return NotifTile(notification: notifications[index]);
        });
  }

  Widget notificationsComments(
      List<DocumentSnapshot<Map<String, dynamic>>> notifications) {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        switch (notifications[index].data()!['type']) {
          case "comment":
            return NotifTile(notification: notifications[index]);
          default:
            return SizedBox();
        }
      },
    );
  }

  Widget notificationsFollows(
      List<DocumentSnapshot<Map<String, dynamic>>> notifications) {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        switch (notifications[index].data()!['type']) {
          case "follow":
            return NotifTile(notification: notifications[index]);
          default:
            return SizedBox();
        }
      },
    );
  }

  Widget notificationsUpDown(
      List<DocumentSnapshot<Map<String, dynamic>>> notifications) {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        switch (notifications[index].data()!['type']) {
          case "updown":
            return NotifTile(notification: notifications[index]);
          default:
            return SizedBox();
        }
      },
    );
  }
}
