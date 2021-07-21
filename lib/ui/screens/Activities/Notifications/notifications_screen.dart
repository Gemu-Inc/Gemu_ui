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

class NotificationsScreenState extends State<NotificationsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
          case "All notifications":
            return notificationsAllNotifications(documents);
          case "Comments":
            return notificationsComments(documents);
          case "Follows":
            return notificationsFollows(documents);
          case "Up&Down":
            return notificationsUpDown(documents);
          default:
            return Center(child: Text('Pas de notifications actuellement'));
        }
      },
    );
  }

  Widget notificationsAllNotifications(
      List<DocumentSnapshot<Map<String, dynamic>>> notifications) {
    return ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return NotifTile(notification: notifications[index]);
        });
  }

  Widget notificationsComments(
      List<DocumentSnapshot<Map<String, dynamic>>> notifications) {
    List<DocumentSnapshot<Map<String, dynamic>>> notifComments = [];
    for (var notif in notifications) {
      if (notif.data()!['type'] == "comment") {
        notifComments.add(notif);
      }
    }

    if (notifComments.length == 0) {
      return Center(
        child: Text('Pas de notifications Comments'),
      );
    }
    return ListView.builder(
      itemCount: notifComments.length,
      itemBuilder: (context, index) {
        return NotifTile(notification: notifComments[index]);
      },
    );
  }

  Widget notificationsFollows(
      List<DocumentSnapshot<Map<String, dynamic>>> notifications) {
    List<DocumentSnapshot<Map<String, dynamic>>> notifFollows = [];
    for (var notif in notifFollows) {
      if (notif.data()!['type'] == 'follow') {
        notifFollows.add(notif);
      }
    }

    if (notifFollows.length == 0) {
      return Center(
        child: Text('Pas de notifications Follows'),
      );
    }
    return ListView.builder(
      itemCount: notifFollows.length,
      itemBuilder: (context, index) {
        return NotifTile(notification: notifFollows[index]);
      },
    );
  }

  Widget notificationsUpDown(
      List<DocumentSnapshot<Map<String, dynamic>>> notifications) {
    List<DocumentSnapshot<Map<String, dynamic>>> notifUpDown = [];
    for (var notif in notifications) {
      if (notif.data()!['type'] == 'updown') {
        notifUpDown.add(notif);
      }
    }

    if (notifUpDown.length == 0) {
      return Center(
        child: Text('Pas de notifications Up&Down'),
      );
    }
    return ListView.builder(
      itemCount: notifUpDown.length,
      itemBuilder: (context, index) {
        return NotifTile(notification: notifUpDown[index]);
      },
    );
  }
}
